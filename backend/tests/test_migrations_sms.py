import httpx
from alembic import command
from alembic.config import Config
from sqlalchemy import inspect
from app.database import get_engine
from app.sms import send_verification, check_verification


def test_migration_round_trip_and_model_drift():
    config = Config("alembic.ini")
    command.check(config)
    command.downgrade(config, "base")
    assert "users" not in inspect(get_engine()).get_table_names()
    command.upgrade(config, "head")
    assert {"users", "drivers", "sessions", "otp_challenges"} <= set(inspect(get_engine()).get_table_names())
    command.check(config)


def test_twilio_verify_contract_without_sending_sms(monkeypatch):
    monkeypatch.setenv("SMS_PROVIDER", "twilio_verify")
    monkeypatch.setenv("TWILIO_ACCOUNT_SID", "AC" + "0" * 32)
    monkeypatch.setenv("TWILIO_AUTH_TOKEN", "synthetic-test-credential")
    monkeypatch.setenv("TWILIO_VERIFY_SERVICE_SID", "VA" + "0" * 32)
    calls = []
    def respond(request):
        calls.append(request)
        assert request.url.host == "verify.twilio.com"
        if request.url.path.endswith("/Verifications"):
            assert b"Channel=sms" in request.content
            assert b"%2B24177123456" in request.content
            return httpx.Response(201, json={"status": "pending", "sid": "VE-test"})
        assert b"VerificationSid=VE-test" in request.content
        return httpx.Response(200, json={"status": "approved"})
    real_client = httpx.Client
    monkeypatch.setattr("app.sms.httpx.Client", lambda **kwargs: real_client(transport=httpx.MockTransport(respond), **kwargs))
    assert send_verification("+24177123456", "challenge-test") == ("VE-test", None)
    assert check_verification("VE-test", "123456") is True
    assert len(calls) == 2
