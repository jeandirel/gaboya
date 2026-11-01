"""GABOYA API: SMS authentication and approved driver lookup."""
import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from . import auth, drivers, payments
from .config import settings
from .database import get_engine


@asynccontextmanager
async def lifespan(_app):
    settings()
    yield
    get_engine().dispose()


app = FastAPI(title="GABOYA API", version="0.2.0", lifespan=lifespan,
              docs_url="/docs" if os.getenv("APP_ENV") != "production" else None)
origins = [v.strip() for v in os.getenv("CORS_ORIGINS", "").split(",") if v.strip()]
if origins:
    if "*" in origins:
        raise RuntimeError("CORS_ORIGINS doit lister les origines explicitement")
    app.add_middleware(CORSMiddleware, allow_origins=origins,
                       allow_methods=["GET", "POST", "PUT"],
                       allow_headers=["Authorization", "Content-Type", "Idempotency-Key"])


@app.middleware("http")
async def security_headers(request, call_next):
    response = await call_next(request)
    response.headers["Cache-Control"] = "no-store"
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["Referrer-Policy"] = "no-referrer"
    if os.getenv("APP_ENV") == "production":
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    return response


@app.get("/healthz")
def health():
    return {"service": "gaboya-api", "status": "up"}


@app.get("/readyz")
def ready():
    with get_engine().connect() as connection:
        connection.execute(text("SELECT 1"))
        connection.execute(text("SELECT id FROM sessions LIMIT 1"))
    return {"status": "ready"}


@app.get("/v1/capabilities")
def capabilities():
    conf = settings()
    return {"project": "GABOYA", "currency": "XAF", "region": "Grand Libreville",
            "otp_ready": conf.sms_provider != "disabled", "sms_mode": conf.sms_provider,
            "google_login_enabled": False, "payments_ready": False, "payments_live": False}


app.include_router(auth.router)
app.include_router(drivers.router)
app.include_router(payments.router)
