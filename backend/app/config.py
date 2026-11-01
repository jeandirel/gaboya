"""Fail closed: test SMS can never authenticate against a deployed database."""
import os
from dataclasses import dataclass
from pathlib import Path
from sqlalchemy.engine import make_url


@dataclass(frozen=True)
class Settings:
    environment: str
    secret: str
    sms_provider: str
    test_sms_dir: Path
    twilio_account_sid: str
    twilio_auth_token: str
    twilio_verify_service_sid: str


def settings() -> Settings:
    env = os.getenv("APP_ENV", "development")
    secret = os.getenv("APP_SECRET", "")
    provider = os.getenv("SMS_PROVIDER", "disabled")
    if env not in {"test", "development", "production"}:
        raise RuntimeError("APP_ENV invalide")
    if len(secret) < 32:
        raise RuntimeError("APP_SECRET doit contenir au moins 32 caract�res al�atoires")
    if provider not in {"disabled", "test", "twilio_verify"}:
        raise RuntimeError("SMS_PROVIDER invalide")
    if provider == "test":
        url = make_url(os.getenv("DATABASE_URL", ""))
        if (env != "test" or os.getenv("ALLOW_TEST_SMS") != "1"
                or not (url.database or "").endswith("_test")
                or url.host not in {"localhost", "127.0.0.1", "::1"}
                or os.getenv("RENDER")):
            raise RuntimeError("SMS de test limit� � APP_ENV=test et PostgreSQL local *_test")
    result = Settings(env, secret, provider,
                      Path(os.getenv("TEST_SMS_DIR", ".otp-inbox")),
                      os.getenv("TWILIO_ACCOUNT_SID", ""),
                      os.getenv("TWILIO_AUTH_TOKEN", ""),
                      os.getenv("TWILIO_VERIFY_SERVICE_SID", ""))
    if provider == "twilio_verify" and not all((result.twilio_account_sid,
                                               result.twilio_auth_token,
                                               result.twilio_verify_service_sid)):
        raise RuntimeError("Identifiants Twilio Verify manquants")
    return result
