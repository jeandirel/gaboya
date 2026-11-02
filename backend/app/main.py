"""API initiale GABOYA : aucun faux paiement n'est possible."""
import os
import re
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import joinedload
from .database import make_session
from .models import Driver, DriverCode, Vehicle
from .geography import router as geography_router

app = FastAPI(title="GABOYA API", version="0.1.0", docs_url="/docs" if os.getenv("APP_ENV") != "production" else None)
app.include_router(geography_router)
origins = [v.strip() for v in os.getenv("CORS_ORIGINS", "").split(",") if v.strip()]
if origins:
    app.add_middleware(CORSMiddleware, allow_origins=origins, allow_methods=["GET", "POST"], allow_headers=["Authorization", "Content-Type", "Idempotency-Key"])

class PaymentRequest(BaseModel):
    driver_code: str = Field(min_length=6, max_length=24)
    amount_xaf: int = Field(gt=0, le=250000)

@app.get("/healthz")
def health():
    return {"service": "gaboya-api", "status": "up", "database_configured": bool(os.getenv("DATABASE_URL"))}

@app.get("/v1/capabilities")
def capabilities():
    return {
        "project": "GABOYA",
        "currency": "XAF",
        "region": "Gabon",
        "national_catalogue": True,
        "operational_coverage_from": "/v1/geo/coverage",
        "otp_ready": False,
        "payments_ready": False,
        "payments_live": False,
        "message": "Infrastructure en construction : aucun paiement réel n'est disponible.",
    }

@app.post("/v1/auth/otp/request", status_code=503)
def request_otp():
    raise HTTPException(status_code=503, detail="Fournisseur SMS non configuré. Aucun OTP envoyé.")

@app.get("/v1/drivers/resolve/{code}")
def resolve_driver(code: str):
    if not re.fullmatch(r"GBY-[A-Z0-9]{4,16}", code):
        raise HTTPException(status_code=422, detail="Code chauffeur invalide")
    if not os.getenv("DATABASE_URL"):
        raise HTTPException(status_code=503, detail="Base de données GABOYA non configurée")
    try:
        with make_session()() as db:
            data = db.execute(select(DriverCode).where(DriverCode.code == code, DriverCode.active.is_(True))).scalar_one_or_none()
            if data is None:
                raise HTTPException(status_code=404, detail="Code chauffeur introuvable")
            driver = db.execute(select(Driver).options(joinedload(Driver.owner)).where(Driver.id == data.driver_id)).scalar_one_or_none()
            if driver is None or driver.status != "approved" or not driver.owner.enabled:
                raise HTTPException(status_code=404, detail="Chauffeur non disponible")
            vehicle = db.execute(select(Vehicle).where(Vehicle.driver_id == driver.id, Vehicle.is_active.is_(True))).scalar_one_or_none()
            return {"driver_id": driver.id, "display_name": driver.owner.display_name, "vehicle": {"license_plate": vehicle.license_plate, "description": vehicle.description} if vehicle else None, "verified": True}
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=503, detail="Service chauffeur momentanément indisponible")

@app.post("/v1/payments/intents", status_code=503)
def create_intent(_payload: PaymentRequest):
    raise HTTPException(status_code=503, detail="Paiement pawaPay indisponible : intégration sandbox non configurée.")
