import os
from datetime import timedelta
from pathlib import Path
import pytest
from sqlalchemy import select, func
from app.config import settings
from app.database import make_session
from app.models import OtpChallenge, Session, User, now


def challenge(client, phone="+24177123456"):
    response = client.post("/v1/auth/otp/request", json={"phone": phone})
    assert response.status_code == 202, response.text
    data = response.json()
    assert "code" not in data and data["delivery"] == "test_inbox"
    code = (Path(os.environ["TEST_SMS_DIR"]) / (data["challenge_id"] + ".txt")).read_text()
    return data["challenge_id"], code


def test_registration_normalizes_phone_and_never_stores_tokens_or_otp(client):
    ident, code = challenge(client, "077 12 34 56")
    response = client.post("/v1/auth/otp/verify", json={"challenge_id": ident, "code": code, "display_name": "Passager"})
    assert response.status_code == 200
    data = response.json()
    assert data["user"]["phone"] == "+24177123456"
    assert data["user"]["roles"] == ["passenger"]
    with make_session()() as db:
        assert db.get(OtpChallenge, ident).code_hash != code
        session = db.scalar(select(Session))
        assert session.access_hash != data["access_token"]
        assert session.refresh_hash != data["refresh_token"]
    assert client.post("/v1/auth/otp/verify", json={"challenge_id": ident, "code": code}).status_code == 400


@pytest.mark.parametrize("phone", ["+33612345678", "+241071234567", "+2417712", "77123456", "+24111123456"])
def test_reject_foreign_or_ambiguous_numbers(client, phone):
    assert client.post("/v1/auth/otp/request", json={"phone": phone}).status_code == 422


def test_failed_attempts_are_persistent_and_limit_correct_code(client):
    ident, code = challenge(client)
    wrong = "000000" if code != "000000" else "999999"
    for _ in range(5):
        assert client.post("/v1/auth/otp/verify", json={"challenge_id": ident, "code": wrong}).status_code == 400
    assert client.post("/v1/auth/otp/verify", json={"challenge_id": ident, "code": code}).status_code == 400
    with make_session()() as db:
        assert db.get(OtpChallenge, ident).attempts == 5


def test_expired_otp_and_resend_cooldown(client):
    ident, code = challenge(client)
    assert client.post("/v1/auth/otp/request", json={"phone": "+24177123456"}).status_code == 429
    with make_session()() as db:
        db.get(OtpChallenge, ident).expires_at = now() - timedelta(seconds=1)
        db.commit()
    assert client.post("/v1/auth/otp/verify", json={"challenge_id": ident, "code": code}).status_code == 400


def test_refresh_rotation_reuse_revokes_family(client, account):
    data, headers = account()
    assert client.get("/v1/me", headers=headers).status_code == 200
    new = client.post("/v1/auth/refresh", json={"refresh_token": data["refresh_token"]})
    assert new.status_code == 200
    assert new.json()["access_token"] != data["access_token"]
    assert client.get("/v1/me", headers=headers).status_code == 401
    assert client.post("/v1/auth/refresh", json={"refresh_token": data["refresh_token"]}).status_code == 401
    assert client.get("/v1/me", headers={"Authorization": "Bearer " + new.json()["access_token"]}).status_code == 401


def test_logout_revokes_refresh(client, account):
    data, headers = account()
    assert client.post("/v1/auth/logout", headers=headers).status_code == 204
    assert client.get("/v1/me", headers=headers).status_code == 401
    assert client.post("/v1/auth/refresh", json={"refresh_token": data["refresh_token"]}).status_code == 401


def test_login_existing_phone_does_not_duplicate_or_escalate(client, account):
    first, headers = account(phone="+24177123456")
    with make_session()() as db:
        from app.models import AuthRateLimit
        for row in db.scalars(select(AuthRateLimit)):
            row.last_at = now() - timedelta(minutes=2)
        db.commit()
    second, _ = account(phone="+24177123456")
    assert second["user"]["id"] == first["user"]["id"]
    assert client.post("/v1/admin/users/" + first["user"]["id"] + "/roles", headers=headers,
                       json={"role": "admin", "enabled": True}).status_code == 403
    with make_session()() as db:
        assert db.scalar(select(func.count()).select_from(User)) == 1


def test_disabled_user_cannot_use_session_or_refresh(client, account):
    data, headers = account()
    with make_session()() as db:
        db.get(User, data["user"]["id"]).enabled = False
        db.commit()
    assert client.get("/v1/me", headers=headers).status_code == 401
    assert client.post("/v1/auth/refresh", json={"refresh_token": data["refresh_token"]}).status_code == 401


@pytest.mark.parametrize("overrides", [
    {"APP_ENV": "production"}, {"APP_ENV": "development"}, {"ALLOW_TEST_SMS": "0"},
    {"DATABASE_URL": "postgresql://user:placeholder@remote.example/gaboya_test"},
    {"DATABASE_URL": "postgresql://user:placeholder@localhost/gaboya"}, {"RENDER": "true"}])
def test_sms_test_mode_cannot_escape_local_test_database(monkeypatch, overrides):
    for key, value in overrides.items():
        monkeypatch.setenv(key, value)
    with pytest.raises(RuntimeError):
        settings()
