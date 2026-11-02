"""Preview OpenStreetMap transport stops, optionally store unverified candidates."""
import argparse
import json
import os
from urllib.parse import urlencode
from urllib.request import Request, urlopen
from sqlalchemy import select
from app.database import make_session
from app.geo_models import City, TransportPoint

def load_points(lat, lon, radius):
    statement = '[out:json][timeout:25];(node(around:%d,%f,%f)["highway"="bus_stop"];node(around:%d,%f,%f)["amenity"="bus_station"];way(around:%d,%f,%f)["amenity"="bus_station"];);out center;' % (radius, lat, lon, radius, lat, lon, radius, lat, lon)
    request = Request("https://overpass-api.de/api/interpreter", data=urlencode({"data": statement}).encode(), headers={"User-Agent": "GaboyaGeoImporter/1.0"})
    with urlopen(request, timeout=45) as response:
        return json.load(response)["elements"]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--city-id", required=True, type=int)
    parser.add_argument("--radius", type=int, default=5000)
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    if args.radius < 100 or args.radius > 15000:
        parser.error("radius must be between 100 and 15000 metres")
    if not os.getenv("DATABASE_URL"):
        parser.error("DATABASE_URL required")
    with make_session()() as session:
        city = session.get(City, args.city_id)
        if city is None or city.latitude is None or city.longitude is None:
            parser.error("Unknown city or missing coordinates")
        stops = load_points(city.latitude, city.longitude, args.radius)
        print("Candidates:", len(stops))
        if not args.apply:
            for stop in stops[:20]:
                print(stop["type"], stop["id"], stop.get("tags", {}).get("name", "(unnamed)"))
            return
        for stop in stops:
            ident = stop["id"]
            kind = stop["type"]
            existing = session.execute(select(TransportPoint).where(TransportPoint.osm_type == kind, TransportPoint.osm_id == ident)).scalar_one_or_none()
            if existing:
                continue
            coords = stop.get("center") or stop
            session.add(TransportPoint(osm_type=kind, osm_id=ident, city_id=city.id, name=stop.get("tags", {}).get("name", "Arrêt sans nom")[:180], kind="bus_station" if stop.get("tags", {}).get("amenity") == "bus_station" else "bus_stop", latitude=coords.get("lat"), longitude=coords.get("lon"), verified=False, service_enabled=False))
        session.commit()
        print("Saved unverified points; none are public.")

if __name__ == "__main__":
    main()
