"""Preparation only. No provider request, callback or settlement is enabled."""
from fastapi import APIRouter, Depends, Header, HTTPException
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from .auth import current_user, digest
from .database import get_db
from .drivers import resolve
from .models import PaymentIntent, User
from .schemas import PaymentRequest

router = APIRouter(prefix="/v1", tags=["payments"])


def intent_data(intent: PaymentIntent):
    return {"id": intent.id, "driver_id": intent.driver_id, "amount_xaf": intent.amount_xaf,
            "currency": "XAF", "status": intent.status, "provider": intent.provider,
            "can_pay": False, "provider_confirmed": False,
            "message": "Intention enregistrée. Aucun débit : intégration pawaPay indisponible."}


@router.post("/payments/intents", status_code=201)
def create_intent(payload: PaymentRequest, user: User = Depends(current_user),
                  idempotency_key: str = Header(min_length=16, max_length=128),
                  db: Session = Depends(get_db)):
    driver = resolve(db, payload.driver_code, lock=True)
    if driver.user_id == user.id:
        raise HTTPException(422, "Vous ne pouvez pas vous payer vous-même")
    key = digest(f"intent:{user.id}:{idempotency_key}")
    existing = db.scalar(select(PaymentIntent).where(PaymentIntent.idempotency_key == key))
    if existing:
        if existing.driver_id != driver.id or existing.amount_xaf != payload.amount_xaf:
            raise HTTPException(409, "Clé d’idempotence déjà utilisée pour un autre paiement")
        return intent_data(existing)
    intent = PaymentIntent(passenger_id=user.id, driver_id=driver.id, amount_xaf=payload.amount_xaf,
                           provider="unconfigured", idempotency_key=key, status="pending")
    db.add(intent)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        existing = db.scalar(select(PaymentIntent).where(PaymentIntent.idempotency_key == key))
        if not existing or existing.driver_id != driver.id or existing.amount_xaf != payload.amount_xaf:
            raise HTTPException(409, "Conflit d’idempotence") from None
        return intent_data(existing)
    return intent_data(intent)


@router.get("/payments/intents/{intent_id}")
def get_intent(intent_id: str, user: User = Depends(current_user), db: Session = Depends(get_db)):
    intent = db.scalar(select(PaymentIntent).where(PaymentIntent.id == intent_id, PaymentIntent.passenger_id == user.id))
    if not intent:
        raise HTTPException(404, "Intention introuvable")
    return intent_data(intent)
