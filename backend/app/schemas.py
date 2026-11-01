import re
from typing import Literal
from pydantic import BaseModel, ConfigDict, Field, field_validator


def normalize_phone(value: str) -> str:
    # ARCEP/ITU: 9 digits locally, omit the initial 0 after +241.
    value = re.sub(r"[\s().-]", "", value)
    if value.startswith("00241"):
        value = "+241" + value[5:]
    if re.fullmatch(r"0[67]\d{7}", value):
        value = "+241" + value[1:]
    if not re.fullmatch(r"\+241[67]\d{7}", value):
        raise ValueError("Num�ro mobile gabonais attendu : +241 suivi de 8 chiffres (6 ou 7)")
    return value


class Payload(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)


class OtpRequest(Payload):
    phone: str = Field(max_length=32)
    _phone = field_validator("phone")(normalize_phone)


class OtpVerify(Payload):
    challenge_id: str = Field(pattern=r"^[0-9a-f-]{36}$")
    code: str = Field(pattern=r"^\d{6}$")
    display_name: str = Field(default="", max_length=160)


class RefreshRequest(Payload):
    refresh_token: str = Field(min_length=40, max_length=200)


class VehicleInput(Payload):
    license_plate: str = Field(min_length=3, max_length=40)
    description: str = Field(min_length=3, max_length=140)


class DriverInput(Payload):
    display_name: str = Field(min_length=2, max_length=160)
    vehicle: VehicleInput


class DriverReview(Payload):
    status: Literal["approved", "rejected", "suspended"]
    note: str = Field(min_length=3, max_length=500)


class RoleInput(Payload):
    role: Literal["passenger", "company", "controller", "admin"]
    enabled: bool


class PaymentRequest(Payload):
    driver_code: str = Field(pattern=r"^GBY-[A-Z0-9]{4,16}$")
    amount_xaf: int = Field(strict=True, gt=0, le=250000)
