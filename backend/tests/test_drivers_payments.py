from concurrent.futures import ThreadPoolExecutor
import pytest
from sqlalchemy import select, func
from app.database import make_session
from app.models import LedgerEntry, PaymentIntent


def test_full_flow_approved_driver_qr_and_pending_payment(client, approved_driver):
    flow = approved_driver
    code = flow["driver"]["qr_code"]
    result = client.get("/v1/drivers/resolve/" + code, headers=flow["passenger_headers"])
    assert result.status_code == 200
    assert result.json()["verified"] is True
    assert result.json()["vehicle"]["license_plate"] == "TEST-GA-001"
    assert "phone" not in result.json() and "user_id" not in result.json()
    qr = client.get("/v1/drivers/me/qr.svg", headers=flow["driver_headers"])
    assert qr.status_code == 200 and "image/svg+xml" in qr.headers["Content-Type"]
    assert client.get("/v1/me", headers=flow["driver_headers"]).json()["roles"] == ["driver", "passenger"]
    body = {"driver_code": code, "amount_xaf": 1000}
    headers = {**flow["passenger_headers"], "Idempotency-Key": "test-intent-key-0001"}
    intent = client.post("/v1/payments/intents", headers=headers, json=body)
    assert intent.status_code == 201, intent.text
    assert intent.json()["status"] == "pending"
    assert intent.json()["can_pay"] is False and intent.json()["provider_confirmed"] is False
    assert client.post("/v1/payments/intents", headers=headers, json=body).json()["id"] == intent.json()["id"]
    assert client.post("/v1/payments/intents", headers=headers, json={**body, "amount_xaf": 1001}).status_code == 409
    assert client.get("/v1/payments/intents/" + intent.json()["id"], headers=flow["driver_headers"]).status_code == 404
    with make_session()() as db:
        assert db.scalar(select(func.count()).select_from(PaymentIntent)) == 1
        assert db.scalar(select(func.count()).select_from(LedgerEntry)) == 0


def test_pending_and_self_approval_are_blocked(client, account):
    _, headers = account(admin=True)
    driver = client.post("/v1/drivers", headers=headers, json={"display_name": "Test chauffeur",
                      "vehicle": {"license_plate": "TEST-002", "description": "Véhicule test"}}).json()
    assert driver["status"] == "pending_review" and driver["qr_code"] is None
    assert client.get("/v1/drivers/me/qr.svg", headers=headers).status_code == 409
    assert client.post(f"/v1/admin/drivers/{driver['driver_id']}/review", headers=headers,
                       json={"status": "approved", "note": "Self review"}).status_code == 403
    assert client.post("/v1/drivers", headers=headers, json={"display_name": "Duplicata",
                      "vehicle": {"license_plate": "TEST-003", "description": "Autre véhicule"}}).status_code == 409


def test_suspension_and_vehicle_change_invalidate_qr(client, approved_driver):
    flow = approved_driver
    code = flow["driver"]["qr_code"]
    changed = client.put("/v1/drivers/me", headers=flow["driver_headers"], json={
        "display_name": "Chauffeur modifié", "vehicle": {"license_plate": "TEST-004", "description": "Nouveau véhicule"}})
    assert changed.status_code == 200
    assert changed.json()["status"] == "pending_review" and changed.json()["qr_code"] is None
    assert client.get("/v1/drivers/resolve/" + code, headers=flow["passenger_headers"]).status_code == 404
    assert "driver" not in client.get("/v1/me", headers=flow["driver_headers"]).json()["roles"]
    response = client.post(f"/v1/admin/drivers/{flow['driver']['driver_id']}/review", headers=flow["admin_headers"],
                           json={"status": "suspended", "note": "Suspendu pour test"})
    assert response.status_code == 200 and response.json()["verified"] is False


@pytest.mark.parametrize("amount", [0, -1, 250001, 1.5, "500", True])
def test_invalid_fcfa_amounts(client, approved_driver, amount):
    flow = approved_driver
    assert client.post("/v1/payments/intents", headers={**flow["passenger_headers"], "Idempotency-Key": "invalid-amount-key"},
                       json={"driver_code": flow["driver"]["qr_code"], "amount_xaf": amount}).status_code == 422


def test_concurrent_duplicate_intents_are_single_record(client, approved_driver):
    flow = approved_driver
    def request(_):
        return client.post("/v1/payments/intents", headers={**flow["passenger_headers"], "Idempotency-Key": "concurrent-intent-key"},
                           json={"driver_code": flow["driver"]["qr_code"], "amount_xaf": 500})
    with ThreadPoolExecutor(max_workers=4) as pool:
        responses = list(pool.map(request, range(4)))
    assert all(response.status_code == 201 for response in responses)
    assert len({response.json()["id"] for response in responses}) == 1


def test_unauthorized_admin_and_extra_fields_rejected(client, approved_driver):
    flow = approved_driver
    assert client.get("/v1/admin/drivers", headers=flow["passenger_headers"]).status_code == 403
    assert client.post("/v1/admin/drivers/" + flow["driver"]["driver_id"] + "/review", headers=flow["driver_headers"],
                       json={"status": "approved", "note": "Test"}).status_code == 403
    assert client.post("/v1/payments/intents", headers={**flow["passenger_headers"], "Idempotency-Key": "extra-fields-test-key"},
                       json={"driver_code": flow["driver"]["qr_code"], "amount_xaf": 500, "status": "succeeded"}).status_code == 422
