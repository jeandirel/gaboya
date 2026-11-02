from fastapi.testclient import TestClient
from app.main import app

def test_geo_unconfigured(monkeypatch):
    monkeypatch.delenv('DATABASE_URL', raising=False)
    client = TestClient(app)
    assert client.get('/v1/geo/provinces').status_code == 503
    assert client.get('/v1/geo/coverage').status_code == 503

