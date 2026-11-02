"""Public geography catalogue; all service coverage is opt-in."""
import os
from fastapi import APIRouter, HTTPException, Query
from sqlalchemy import select
from .database import make_session
from .geo_models import Province, City, TransportPoint

router = APIRouter(prefix="/v1/geo", tags=["geography"])

def query_db(statement):
    if not os.getenv("DATABASE_URL"):
        raise HTTPException(status_code=503, detail="Catalogue géographique non configuré")
    try:
        with make_session()() as db:
            return db.execute(statement).scalars().all()
    except Exception:
        raise HTTPException(status_code=503, detail="Catalogue géographique indisponible")

@router.get("/provinces")
def provinces():
    rows = query_db(select(Province).order_by(Province.name))
    return [{"id": p.id, "name": p.name, "code": p.code} for p in rows]

@router.get("/cities")
def cities(province_id: int | None = None, available_only: bool = True, limit: int = Query(100, ge=1, le=500)):
    stmt = select(City)
    if province_id is not None:
        stmt = stmt.where(City.province_id == province_id)
    if available_only:
        stmt = stmt.where(City.service_enabled.is_(True))
    rows = query_db(stmt.order_by(City.name).limit(limit))
    return [{"id": c.id, "name": c.name, "province_id": c.province_id, "latitude": c.latitude, "longitude": c.longitude, "service_enabled": c.service_enabled} for c in rows]

@router.get("/transport-points")
def points(city_id: int, limit: int = Query(100, ge=1, le=500)):
    stmt = select(TransportPoint).where(TransportPoint.city_id == city_id, TransportPoint.verified.is_(True), TransportPoint.service_enabled.is_(True)).order_by(TransportPoint.name).limit(limit)
    rows = query_db(stmt)
    return [{"id": x.id, "name": x.name, "kind": x.kind, "latitude": x.latitude, "longitude": x.longitude} for x in rows]

@router.get("/coverage")
def coverage():
    rows = query_db(select(City).where(City.service_enabled.is_(True)).order_by(City.name))
    return {"country": "GA", "active_city_ids": [r.id for r in rows], "active_city_count": len(rows)}
