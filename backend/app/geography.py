"""Public read-only geographic catalogue, using Supabase REST or PostgreSQL."""
import json
import os
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen
from fastapi import APIRouter, HTTPException, Query
from sqlalchemy import select
from .database import make_session
from .geo_models import Province, City, TransportPoint

router = APIRouter(prefix="/v1/geo", tags=["geography"])

def rest_read(table, params):
    url = os.getenv("SUPABASE_URL", "").rstrip("/")
    key = os.getenv("SUPABASE_PUBLISHABLE_KEY", "")
    if not url or not key:
        raise HTTPException(503, "Catalogue géographique non configuré")
    request = Request(
        url + "/rest/v1/" + table + "?" + urlencode(params),
        headers={"apikey": key, "Accept": "application/json"},
    )
    try:
        with urlopen(request, timeout=12) as result:
            return json.load(result)
    except (HTTPError, URLError, ValueError, TimeoutError):
        raise HTTPException(503, "Catalogue géographique indisponible")

def query_db(statement):
    if not os.getenv("DATABASE_URL"):
        raise HTTPException(503, "Catalogue géographique non configuré")
    try:
        with make_session()() as db:
            return db.execute(statement).scalars().all()
    except Exception:
        raise HTTPException(503, "Catalogue géographique indisponible")

@router.get("/provinces")
def provinces():
    if os.getenv("SUPABASE_URL"):
        return rest_read("geo_provinces", {"select": "id,name,code", "order": "name.asc"})
    rows = query_db(select(Province).order_by(Province.name))
    return [{"id": p.id, "name": p.name, "code": p.code} for p in rows]

@router.get("/cities")
def cities(province_id: int | None = None, available_only: bool = True, limit: int = Query(100, ge=1, le=500)):
    if os.getenv("SUPABASE_URL"):
        params = {"select": "id,name,province_id,latitude,longitude,service_enabled", "order": "name.asc", "limit": str(limit)}
        if province_id is not None:
            params["province_id"] = "eq." + str(province_id)
        if available_only:
            params["service_enabled"] = "eq.true"
        return rest_read("geo_cities", params)
    stmt = select(City)
    if province_id is not None:
        stmt = stmt.where(City.province_id == province_id)
    if available_only:
        stmt = stmt.where(City.service_enabled.is_(True))
    rows = query_db(stmt.order_by(City.name).limit(limit))
    return [{"id": c.id, "name": c.name, "province_id": c.province_id, "latitude": c.latitude, "longitude": c.longitude, "service_enabled": c.service_enabled} for c in rows]

@router.get("/transport-points")
def points(city_id: int, limit: int = Query(100, ge=1, le=500)):
    if os.getenv("SUPABASE_URL"):
        return rest_read("geo_transport_points", {"select": "id,name,kind,latitude,longitude", "city_id": "eq." + str(city_id), "verified": "eq.true", "service_enabled": "eq.true", "order": "name.asc", "limit": str(limit)})
    stmt = select(TransportPoint).where(TransportPoint.city_id == city_id, TransportPoint.verified.is_(True), TransportPoint.service_enabled.is_(True)).order_by(TransportPoint.name).limit(limit)
    rows = query_db(stmt)
    return [{"id": x.id, "name": x.name, "kind": x.kind, "latitude": x.latitude, "longitude": x.longitude} for x in rows]

@router.get("/coverage")
def coverage():
    if os.getenv("SUPABASE_URL"):
        rows = rest_read("geo_cities", {"select": "id", "service_enabled": "eq.true", "order": "id.asc"})
        return {"country": "GA", "active_city_ids": [r["id"] for r in rows], "active_city_count": len(rows)}
    rows = query_db(select(City).where(City.service_enabled.is_(True)).order_by(City.name))
    return {"country": "GA", "active_city_ids": [r.id for r in rows], "active_city_count": len(rows)}
