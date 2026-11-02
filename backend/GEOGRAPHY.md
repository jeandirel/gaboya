# Gaboya national geography

This change adds GeoNames reference data and a ready-to-extend OSM point catalogue.
A populated city is not an operational coverage area. All cities and stations
default to disabled; points must be verified by Gaboya before public display.

## Run
From backend/, configure a dedicated Gaboya PostgreSQL DATABASE_URL.
Do not use any existing application's database.

```sh
alembic upgrade head
python -m scripts.import_geography
python -m scripts.import_geography --apply
pytest
uvicorn app.main:app
```

Public endpoints:
- GET /v1/geo/provinces
- GET /v1/geo/cities?province_id=1&available_only=false
- GET /v1/geo/transport-points?city_id=1
- GET /v1/geo/coverage

The first importer uses GeoNames GA.zip. A province-code mapping must be checked against the actual source before applying. Do not infer completeness from imported counts. OpenStreetMap/Overpass transport point ingestion remains a follow-on task; it requires provenance, deduplication and human validation. The /v1/geo/transport-points endpoint only exposes verified and activated points.

Admin service activation is intentionally not public. Use audited server-side authorization for later admin APIs. Do not expose a privileged Supabase key to FlutterFlow.
