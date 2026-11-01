import re
import secrets
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, update, delete
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from .auth import admin_user, current_user, profile
from .database import get_db
from .models import AuditLog, Driver, DriverCode, RoleAssignment, User, Vehicle, now
from .schemas import DriverInput, DriverReview, RoleInput

router = APIRouter(prefix="/v1", tags=["drivers"])


def driver_data(db: Session, driver: Driver, private: bool = False) -> dict:
    owner = db.get(User, driver.user_id)
    vehicle = db.scalar(select(Vehicle).where(Vehicle.driver_id == driver.id, Vehicle.is_active.is_(True)))
    data = {"driver_id": driver.id, "display_name": owner.display_name, "status": driver.status,
            "verified": driver.status == "approved" and owner.enabled,
            "vehicle": {"id": vehicle.id, "license_plate": vehicle.license_plate,
                        "description": vehicle.description} if vehicle else None}
    if private:
        code = db.scalar(select(DriverCode.code).where(DriverCode.driver_id == driver.id, DriverCode.active.is_(True)))
        data.update(user_id=driver.user_id, review_note=driver.review_note, qr_code=code,
                    qr_payload=code, reviewed_at=driver.reviewed_at)
    return data


def resolve(db: Session, code: str, lock: bool = False) -> Driver:
    if not re.fullmatch(r"GBY-[A-Z0-9]{4,16}", code):
        raise HTTPException(422, "Code chauffeur invalide")
    query = select(Driver).join(DriverCode).join(User, Driver.user_id == User.id).where(
        DriverCode.code == code, DriverCode.active.is_(True), Driver.status == "approved", User.enabled.is_(True))
    if lock:
        query = query.with_for_update(of=Driver)
    driver = db.scalar(query)
    if (not driver or not db.get(RoleAssignment, (driver.user_id, "driver"))
            or not db.scalar(select(Vehicle.id).where(Vehicle.driver_id == driver.id, Vehicle.is_active.is_(True)))):
        raise HTTPException(404, "Chauffeur non disponible")
    return driver


@router.post("/drivers", status_code=201)
def apply_driver(payload: DriverInput, user: User = Depends(current_user), db: Session = Depends(get_db)):
    db.scalar(select(User).where(User.id == user.id).with_for_update())
    if db.scalar(select(Driver.id).where(Driver.user_id == user.id)):
        raise HTTPException(409, "Profil chauffeur déjà créé")
    user.display_name = payload.display_name
    driver = Driver(user_id=user.id)
    db.add(driver)
    db.flush()
    db.add(Vehicle(driver_id=driver.id, license_plate=payload.vehicle.license_plate.upper(),
                   description=payload.vehicle.description))
    db.add(AuditLog(actor_id=user.id, action="driver.submitted", target_id=driver.id))
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, "Véhicule déjà enregistré") from None
    return driver_data(db, driver, True)


@router.get("/drivers/me")
def my_driver(user: User = Depends(current_user), db: Session = Depends(get_db)):
    driver = db.scalar(select(Driver).where(Driver.user_id == user.id))
    if not driver:
        raise HTTPException(404, "Aucun profil chauffeur")
    return driver_data(db, driver, True)


@router.put("/drivers/me")
def update_driver(payload: DriverInput, user: User = Depends(current_user), db: Session = Depends(get_db)):
    driver = db.scalar(select(Driver).where(Driver.user_id == user.id).with_for_update())
    if not driver:
        raise HTTPException(404, "Aucun profil chauffeur")
    if driver.status == "suspended":
        raise HTTPException(403, "Contactez un administrateur pour modifier un profil suspendu")
    vehicle = db.scalar(select(Vehicle).where(Vehicle.driver_id == driver.id, Vehicle.is_active.is_(True)))
    user.display_name = payload.display_name
    vehicle.license_plate = payload.vehicle.license_plate.upper()
    vehicle.description = payload.vehicle.description
    driver.status = "pending_review"
    driver.reviewed_at = None
    driver.reviewed_by = None
    driver.review_note = ""
    with db.no_autoflush:
        db.execute(update(DriverCode).where(DriverCode.driver_id == driver.id).values(active=False))
        db.execute(delete(RoleAssignment).where(RoleAssignment.user_id == user.id, RoleAssignment.role == "driver"))
    db.add(AuditLog(actor_id=user.id, action="driver.updated", target_id=driver.id))
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, "Véhicule déjà enregistré") from None
    return driver_data(db, driver, True)


@router.get("/drivers/resolve/{code}")
def resolve_driver(code: str, _user: User = Depends(current_user), db: Session = Depends(get_db)):
    return driver_data(db, resolve(db, code))


@router.get("/drivers/me/qr.svg")
def driver_qr(user: User = Depends(current_user), db: Session = Depends(get_db)):
    from fastapi.responses import Response
    import qrcode
    import qrcode.image.svg
    data = my_driver(user, db)
    if not data["qr_code"] or not data["verified"]:
        raise HTTPException(409, "Approbation administrative requise")
    image = qrcode.make(data["qr_code"], image_factory=qrcode.image.svg.SvgPathImage)
    return Response(image.to_string(), media_type="image/svg+xml", headers={"Cache-Control": "no-store"})


@router.get("/admin/drivers")
def list_drivers(_admin: User = Depends(admin_user), db: Session = Depends(get_db),
                 offset: int = 0, limit: int = 50):
    if not 0 <= offset or not 1 <= limit <= 100:
        raise HTTPException(422, "Pagination invalide")
    return [driver_data(db, row, True) for row in db.scalars(select(Driver).order_by(Driver.id).offset(offset).limit(limit))]


@router.post("/admin/drivers/{driver_id}/review")
def review_driver(driver_id: str, payload: DriverReview, admin: User = Depends(admin_user),
                  db: Session = Depends(get_db)):
    driver = db.scalar(select(Driver).where(Driver.id == driver_id).with_for_update())
    if not driver:
        raise HTTPException(404, "Chauffeur introuvable")
    if driver.user_id == admin.id:
        raise HTTPException(403, "Un administrateur ne peut pas approuver son propre profil")
    if payload.status == "approved" and not driver_data(db, driver)["vehicle"]:
        raise HTTPException(409, "Véhicule requis")
    driver.status = payload.status
    driver.reviewed_by, driver.reviewed_at, driver.review_note = admin.id, now(), payload.note
    db.execute(update(DriverCode).where(DriverCode.driver_id == driver.id).values(active=False))
    role = db.get(RoleAssignment, (driver.user_id, "driver"))
    if payload.status == "approved":
        if not role:
            db.add(RoleAssignment(user_id=driver.user_id, role="driver"))
        db.add(DriverCode(driver_id=driver.id, code="GBY-" + secrets.token_hex(8).upper()))
    elif role:
        db.delete(role)
    db.add(AuditLog(actor_id=admin.id, action="driver." + payload.status, target_id=driver.id))
    db.commit()
    return driver_data(db, driver, True)


@router.post("/admin/users/{user_id}/roles")
def assign_role(user_id: str, payload: RoleInput, admin: User = Depends(admin_user),
                db: Session = Depends(get_db)):
    user = db.scalar(select(User).where(User.id == user_id).with_for_update())
    if not user:
        raise HTTPException(404, "Utilisateur introuvable")
    if user.id == admin.id and payload.role == "admin" and not payload.enabled:
        raise HTTPException(409, "Retrait de votre propre rôle administrateur interdit")
    assignment = db.get(RoleAssignment, (user.id, payload.role))
    if payload.enabled and not assignment:
        db.add(RoleAssignment(user_id=user.id, role=payload.role))
    elif not payload.enabled and assignment:
        db.delete(assignment)
    db.add(AuditLog(actor_id=admin.id, action="role." + payload.role + (".granted" if payload.enabled else ".revoked"), target_id=user.id))
    db.commit()
    return profile(db, user)
