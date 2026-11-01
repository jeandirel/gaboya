import os
from pathlib import Path
import pytest
from alembic import command
from alembic.config import Config
from fastapi.testclient import TestClient
from sqlalchemy import text
from sqlalchemy.engine import make_url
from app.database import Base, get_engine, make_session
from app.main import app
from app.models import RoleAssignment


@pytest.fixture(scope="session", autouse=True)
def migrated_database():
    url = make_url(os.environ["DATABASE_URL"])
    if url.host not in {"localhost", "127.0.0.1", "::1"} or not (url.database or "").endswith("_test"):
        raise RuntimeError("Tests destructifs réservés à une base PostgreSQL locale *_test")
    if os.environ.get("APP_ENV") != "test":
        raise RuntimeError("APP_ENV=test requis")
    command.upgrade(Config("alembic.ini"), "head")
    yield
    get_engine().dispose()


@pytest.fixture(autouse=True)
def clean_database(migrated_database, monkeypatch, tmp_path):
    monkeypatch.setenv("SMS_PROVIDER", "test")
    monkeypatch.setenv("ALLOW_TEST_SMS", "1")
    monkeypatch.setenv("TEST_SMS_DIR", str(tmp_path / "sms"))
    tables = ", ".join('"' + table.name + '"' for table in Base.metadata.sorted_tables)
    with get_engine().begin() as connection:
        connection.execute(text("TRUNCATE " + tables + " CASCADE"))
    yield
    with get_engine().begin() as connection:
        connection.execute(text("TRUNCATE " + tables + " CASCADE"))


@pytest.fixture
def client():
    with TestClient(app) as instance:
        yield instance


@pytest.fixture
def account(client):
    counter = 0

    def create(*, admin=False, phone=None):
        nonlocal counter
        counter += 1
        phone = phone or f"+2417710{counter:04d}"
        response = client.post("/v1/auth/otp/request", json={"phone": phone})
        assert response.status_code == 202, response.text
        challenge = response.json()["challenge_id"]
        code = (Path(os.environ["TEST_SMS_DIR"]) / f"{challenge}.txt").read_text()
        result = client.post("/v1/auth/otp/verify", json={"challenge_id": challenge, "code": code,
                                                       "display_name": f"Compte test {counter}"})
        assert result.status_code == 200, result.text
        data = result.json()
        if admin:
            with make_session()() as db:
                db.add(RoleAssignment(user_id=data["user"]["id"], role="admin"))
                db.commit()
        return data, {"Authorization": "Bearer " + data["access_token"]}

    return create


@pytest.fixture
def approved_driver(client, account):
    _, admin_headers = account(admin=True)
    driver_account, driver_headers = account()
    passenger, passenger_headers = account()
    data = client.post("/v1/drivers", headers=driver_headers, json={
        "display_name": "Chauffeur de test", "vehicle": {"license_plate": "TEST-GA-001",
                                                       "description": "Toyota Corolla verte"}})
    assert data.status_code == 201, data.text
    driver_id = data.json()["driver_id"]
    approved = client.post(f"/v1/admin/drivers/{driver_id}/review", headers=admin_headers,
                           json={"status": "approved", "note": "Documents de test contrôlés"})
    assert approved.status_code == 200, approved.text
    return {"driver": approved.json(), "driver_headers": driver_headers, "driver_account": driver_account,
            "passenger_headers": passenger_headers, "passenger": passenger,
            "admin_headers": admin_headers}
