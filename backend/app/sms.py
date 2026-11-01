"""Twilio Verify adapter and an explicit, local-only SMS inbox for tests."""
import os
import secrets
import httpx
from fastapi import HTTPException
from .config import settings


def twilio_call(path: str, data: dict) -> dict:
    conf = settings()
    try:
        with httpx.Client(timeout=10.0) as client:
            response = client.post(
                f"https://verify.twilio.com/v2/Services/{conf.twilio_verify_service_sid}/{path}",
                auth=(conf.twilio_account_sid, conf.twilio_auth_token), data=data)
        # A check for an expired/used verification returns 404.
        if response.status_code == 404 and path == "VerificationCheck":
            return {"status": "expired"}
        response.raise_for_status()
        return response.json()
    except (httpx.HTTPError, ValueError):
        raise HTTPException(503, "Service SMS indisponible. R�essayez plus tard.") from None


def send_verification(phone: str, challenge_id: str) -> tuple[str | None, str | None]:
    conf = settings()
    if conf.sms_provider == "disabled":
        raise HTTPException(503, "Fournisseur SMS non configur�. Aucun OTP envoy�.")
    if conf.sms_provider == "twilio_verify":
        response = twilio_call("Verifications", {"To": phone, "Channel": "sms", "Locale": "fr"})
        if response.get("status") != "pending" or not response.get("sid"):
            raise HTTPException(503, "Envoi SMS non confirm� par le fournisseur")
        return response["sid"], None
    code = f"{secrets.randbelow(1000000):06d}"
    conf.test_sms_dir.mkdir(mode=0o700, parents=True, exist_ok=True)
    # Never returned over HTTP, never logged; only synthetic, isolated test data.
    path = conf.test_sms_dir / f"{challenge_id}.txt"
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, "w") as stream:
        stream.write(code)
    return None, code


def check_verification(reference: str, code: str) -> bool:
    return twilio_call("VerificationCheck", {"VerificationSid": reference, "Code": code}).get("status") == "approved"
