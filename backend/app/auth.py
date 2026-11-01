import hashlib
import hmac
import secrets
from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select, update
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.orm import Session as DbSession
from .config import settings
from .database import get_db
from .models import AuthRateLimit, OtpChallenge, RoleAssignment, Session, User, new_id, now
from .schemas import OtpRequest, OtpVerify, RefreshRequest
from . import sms

router = APIRouter(prefix="/v1", tags=["authentication"])
bearer = HTTPBearer(auto_error=False)


def digest(value: str) -> str:
    return hmac.new(settings().secret.encode(), value.encode(), hashlib.sha256).hexdigest()


def roles(db: DbSession, user: User) -> list[str]:
    return sorted(db.scalars(select(RoleAssignment.role).where(RoleAssignment.user_id == user.id)).all())


def profile(db: DbSession, user: User) -> dict:
    return {"id": user.id, "phone": user.phone_e164, "display_name": user.display_name,
            "roles": roles(db, user)}


def issue_session(db: DbSession, user: User, family_id: str | None = None,
                  refresh_deadline=None) -> dict:
    access, refresh = secrets.token_urlsafe(48), secrets.token_urlsafe(48)
    session = Session(user_id=user.id, family_id=family_id or new_id(),
                      access_hash=digest(access), refresh_hash=digest(refresh),
                      access_expires_at=now() + timedelta(minutes=15),
                      refresh_expires_at=refresh_deadline or now() + timedelta(days=30))
    db.add(session)
    db.flush()
    return {"access_token": access, "refresh_token": refresh, "token_type": "bearer",
            "expires_in": 900, "user": profile(db, user)}


def limit(db: DbSession, key: str, maximum: int, cooldown: int = 0):
    timestamp = now()
    db.execute(insert(AuthRateLimit).values(key=key, window_start=timestamp, count=0,
                                            last_at=timestamp - timedelta(days=1))
               .on_conflict_do_nothing(index_elements=["key"]))
    row = db.scalar(select(AuthRateLimit).where(AuthRateLimit.key == key).with_for_update())
    if timestamp - row.window_start >= timedelta(minutes=15):
        row.count = 0
        row.window_start = timestamp
    if row.count >= maximum or timestamp - row.last_at < timedelta(seconds=cooldown):
        db.commit()
        raise HTTPException(429, "Trop de tentatives. R�essayez plus tard.", headers={"Retry-After": "60"})
    row.count += 1
    row.last_at = timestamp


@router.post("/auth/otp/request", status_code=202)
def request_otp(payload: OtpRequest, request: Request, db: DbSession = Depends(get_db)):
    conf = settings()
    # Never trust user-supplied X-Forwarded-For. Configure trusted proxies at ASGI level.
    limit(db, "ip:" + digest(request.client.host if request.client else "unknown"), 30)
    limit(db, "phone:" + digest(payload.phone), 5, 60)
    db.execute(update(OtpChallenge).where(OtpChallenge.phone == payload.phone,
                                         OtpChallenge.consumed_at.is_(None)).values(consumed_at=now()))
    challenge = OtpChallenge(id=new_id(), phone=payload.phone, provider=conf.sms_provider,
                             expires_at=now() + timedelta(minutes=5))
    # Persist rate limits even if the SMS provider fails.
    db.add(challenge)
    db.commit()
    try:
        reference, code = sms.send_verification(payload.phone, challenge.id)
    except HTTPException:
        challenge.consumed_at = now()
        db.commit()
        raise
    challenge.provider_reference = reference
    if code is not None:
        challenge.code_hash = digest(f"otp:{challenge.id}:{payload.phone}:{code}")
    db.commit()
    return {"challenge_id": challenge.id, "expires_in": 300,
            "delivery": "test_inbox" if conf.sms_provider == "test" else "sms"}


@router.post("/auth/otp/verify")
def verify_otp(payload: OtpVerify, request: Request, db: DbSession = Depends(get_db)):
    limit(db, "verify:" + digest(request.client.host if request.client else "unknown"), 60)
    # Separate commit retains IP limits for invalid challenges as well.
    db.commit()
    challenge = db.scalar(select(OtpChallenge).where(OtpChallenge.id == payload.challenge_id).with_for_update())
    if not challenge or challenge.consumed_at or challenge.expires_at <= now() or challenge.attempts >= 5:
        raise HTTPException(400, "Code invalide, expir� ou d�j� utilis�")
    challenge.attempts += 1
    valid = False
    if challenge.provider == settings().sms_provider == "test" and challenge.code_hash:
        valid = hmac.compare_digest(challenge.code_hash, digest(f"otp:{challenge.id}:{challenge.phone}:{payload.code}"))
    elif challenge.provider == settings().sms_provider == "twilio_verify" and challenge.provider_reference:
        try:
            valid = sms.check_verification(challenge.provider_reference, payload.code)
        except HTTPException:
            db.commit()
            raise
    if not valid:
        db.commit()
        raise HTTPException(400, "Code invalide, expir� ou d�j� utilis�")
    challenge.consumed_at = now()
    db.execute(insert(User).values(id=new_id(), phone_e164=challenge.phone,
                                   display_name=payload.display_name, enabled=True, created_at=now())
               .on_conflict_do_nothing(index_elements=["phone_e164"]))
    user = db.scalar(select(User).where(User.phone_e164 == challenge.phone).with_for_update())
    if not user.enabled:
        db.commit()
        raise HTTPException(403, "Compte d�sactiv�")
    db.execute(insert(RoleAssignment).values(user_id=user.id, role="passenger").on_conflict_do_nothing())
    data = issue_session(db, user)
    db.commit()
    return data


def current_session(credentials: HTTPAuthorizationCredentials | None = Depends(bearer),
                    db: DbSession = Depends(get_db)) -> Session:
    if not credentials or len(credentials.credentials) > 200:
        raise HTTPException(401, "Connexion requise", headers={"WWW-Authenticate": "Bearer"})
    session = db.scalar(select(Session).where(Session.access_hash == digest(credentials.credentials)))
    if not session or session.revoked_at or session.access_expires_at <= now():
        raise HTTPException(401, "Session expir�e ou r�voqu�e", headers={"WWW-Authenticate": "Bearer"})
    user = db.get(User, session.user_id)
    if not user or not user.enabled:
        raise HTTPException(401, "Compte indisponible")
    return session


def current_user(session: Session = Depends(current_session), db: DbSession = Depends(get_db)) -> User:
    return db.get(User, session.user_id)


def admin_user(user: User = Depends(current_user), db: DbSession = Depends(get_db)) -> User:
    if "admin" not in roles(db, user):
        raise HTTPException(403, "Autorisation administrateur requise")
    return user


@router.get("/me")
def me(user: User = Depends(current_user), db: DbSession = Depends(get_db)):
    return profile(db, user)


@router.post("/auth/refresh")
def refresh(payload: RefreshRequest, db: DbSession = Depends(get_db)):
    old = db.scalar(select(Session).where(Session.refresh_hash == digest(payload.refresh_token)))
    if not old:
        raise HTTPException(401, "Session invalide")
    # Serialize every operation in this family through the account row.
    user = db.scalar(select(User).where(User.id == old.user_id).with_for_update())
    old = db.scalar(select(Session).where(Session.id == old.id).with_for_update().execution_options(populate_existing=True))
    if old.revoked_at or old.refresh_expires_at <= now() or not user.enabled:
        db.execute(update(Session).where(Session.family_id == old.family_id).values(revoked_at=now()))
        db.commit()
        raise HTTPException(401, "Session r�voqu�e ; reconnectez-vous")
    old.revoked_at = now()
    result = issue_session(db, user, old.family_id, old.refresh_expires_at)
    db.commit()
    return result


@router.post("/auth/logout", status_code=204)
def logout(session: Session = Depends(current_session), db: DbSession = Depends(get_db)):
    db.scalar(select(User).where(User.id == session.user_id).with_for_update())
    db.execute(update(Session).where(Session.family_id == session.family_id).values(revoked_at=now()))
    db.commit()


@router.post("/auth/logout-all", status_code=204)
def logout_all(user: User = Depends(current_user), db: DbSession = Depends(get_db)):
    db.scalar(select(User).where(User.id == user.id).with_for_update())
    db.execute(update(Session).where(Session.user_id == user.id).values(revoked_at=now()))
    db.commit()
