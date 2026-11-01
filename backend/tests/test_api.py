"""Contrats vérifiables sans accès à Neon ou pawaPay."""
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health():
    data = client.get("/healthz").json()
    assert data["status"] == "up"
    assert data["service"] == "gaboya-api"

def test_capabilities_never_claim_live_payments():
    data = client.get("/v1/capabilities").json()
    assert data["currency"] == "XAF"
    assert data["payments_ready"] is False
    assert data["payments_live"] is False

def test_no_fake_payment_success():
    response = client.post("/v1/payments/intents", json={"driver_code": "GBY-123456", "amount_xaf": 500})
    assert response.status_code == 503
    assert "indisponible" in response.json()["detail"]

def test_invalid_driver_code():
    assert client.get("/v1/drivers/resolve/INVALID").status_code == 422

def test_otp_is_not_faked():
    response = client.post("/v1/auth/otp/request")
    assert response.status_code == 503
