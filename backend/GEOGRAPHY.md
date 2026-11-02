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

The first importer uses GeoNames GA.zip. A province-code mapping must be checked against the actual source before applying. Do not infer completeness from imported counts. OpenStreetMap/Overpass transport point candidate ingestion is available (see below). It requires provenance, deduplication and human verification before enabling. The /v1/geo/transport-points endpoint only exposes verified and activated points.

Admin service activation is intentionally not public. Use audited server-side authorization for later admin APIs. Do not expose a privileged Supabase key to FlutterFlow.

## OpenStreetMap candidate import

From backend/ after importing GeoNames and applying migrations:

```sh
python -m scripts.import_osm_points --city-id 1 --radius 5000
python -m scripts.import_osm_points --city-id 1 --radius 5000 --apply
```

Replace city ID with an existing Gaboya geo_cities ID. Rate-limit import runs and respect Overpass public server policies. Importing does not verify or activate stops; a secured admin review flow must enable them. For production scale use a hosted or self-hosted Overpass instance and respect ODbL attribution.

## FlutterFlow integration

Set the API base URL to the Render FastAPI service. Fetch /v1/geo/provinces for the province selector, then /v1/geo/cities?province_id=ID&available_only=true for live passenger journeys. For exploration of forthcoming locations, use available_only=false but label disabled items as unavailable. Never infer working transport coverage from geographic reference data alone.
