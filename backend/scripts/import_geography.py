"""Import GeoNames Gabon gazetteer. Preview by default, --apply writes to DB.

Sources: https://download.geonames.org/export/dump/GA.zip and
https://download.geonames.org/export/dump/admin1CodesASCII.txt.
Imported places are NOT automatically enabled as Gaboya transport services.
"""
import argparse
import csv
import io
import os
import urllib.request
import zipfile

from sqlalchemy import select
from app.database import make_session
from app.geo_models import Province, City

BASE = "https://download.geonames.org/export/dump/"
PROVINCES = {
    "01": "Estuaire", "02": "Haut-Ogooué", "03": "Moyen-Ogooué",
    "04": "Ngounié", "05": "Nyanga", "06": "Ogooué-Ivindo",
    "07": "Ogooué-Lolo", "08": "Ogooué-Maritime", "09": "Woleu-Ntem",
}

def fetch(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "GaboyaGeoImporter/1.0 (admin reference data)"}), timeout=40) as resp:
        return resp.read()

def parse_places(data):
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        with archive.open("GA.txt") as source:
            for row in csv.reader(io.TextIOWrapper(source, encoding="utf-8"), delimiter="\t"):
                if len(row) < 15 or row[6] != "P" or row[7] not in {"PPL", "PPLA", "PPLA2", "PPLC", "PPLX"}:
                    continue
                code = row[10].zfill(2)
                if code not in PROVINCES:
                    continue
                yield {"geonames_id": int(row[0]), "name": row[1], "province_code": code, "latitude": float(row[4]), "longitude": float(row[5])}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="Write reference data to DATABASE_URL")
    args = parser.parse_args()
    places = list(parse_places(fetch(BASE + "GA.zip")))
    print(f"GeoNames Gabon: {len(places)} candidate populated places, 9 configured provinces")
    if not args.apply:
        print("Preview only. Add --apply to import, after verifying province codes.")
        return
    if not os.getenv("DATABASE_URL"):
        raise SystemExit("DATABASE_URL required")
    with make_session()() as db:
        for code, name in PROVINCES.items():
            province = db.execute(select(Province).where(Province.code == code)).scalar_one_or_none()
            if province is None:
                db.add(Province(id=int(code), code=code, name=name))
        db.flush()
        for p in places:
            city = db.execute(select(City).where(City.geonames_id == p["geonames_id"])).scalar_one_or_none()
            if city is None:
                db.add(City(geonames_id=p["geonames_id"], name=p["name"], province_id=int(p["province_code"]), latitude=p["latitude"], longitude=p["longitude"], service_enabled=False))
            else:
                city.name = p["name"]
                city.latitude = p["latitude"]
                city.longitude = p["longitude"]
                # Never turn on a city's transport service as a side effect of importing.
        db.commit()
    print("Reference data imported; no services activated.")

if __name__ == "__main__":
    main()
