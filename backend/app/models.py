"""Schéma initial : pas de portefeuille réglementé actif."""
import uuid
from datetime import datetime, timezone
from sqlalchemy import String, ForeignKey, Integer, DateTime, CheckConstraint, UniqueConstraint, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .database import Base

def now():
    return datetime.now(timezone.utc)

def new_id():
    return str(uuid.uuid4())

class User(Base):
    __tablename__ = "users"
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    phone_e164: Mapped[str] = mapped_column(String(20), unique=True, nullable=False)
    display_name: Mapped[str] = mapped_column(String(160), default="", nullable=False)
    enabled: Mapped[bool] = mapped_column(default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now, nullable=False)

class RoleAssignment(Base):
    __tablename__ = "user_roles"
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), primary_key=True)
    role: Mapped[str] = mapped_column(String(30), primary_key=True)
    __table_args__ = (CheckConstraint("role IN ('passenger','driver','company','controller','admin')", name="ck_gaboya_role"),)

class Driver(Base):
    __tablename__ = "drivers"
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), unique=True, nullable=False)
    status: Mapped[str] = mapped_column(String(24), default="pending_review", nullable=False)
    __table_args__ = (CheckConstraint("status IN ('pending_review','approved','suspended','rejected')", name="ck_driver_status"),)
    owner: Mapped[User] = relationship()

class Vehicle(Base):
    __tablename__ = "vehicles"
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    driver_id: Mapped[str] = mapped_column(ForeignKey("drivers.id"), nullable=False)
    license_plate: Mapped[str] = mapped_column(String(40), nullable=False)
    description: Mapped[str] = mapped_column(String(140), default="", nullable=False)
    is_active: Mapped[bool] = mapped_column(default=True, nullable=False)

class DriverCode(Base):
    __tablename__ = "driver_codes"
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    driver_id: Mapped[str] = mapped_column(ForeignKey("drivers.id"), nullable=False)
    code: Mapped[str] = mapped_column(String(24), unique=True, nullable=False)
    active: Mapped[bool] = mapped_column(default=True, nullable=False)
    __table_args__ = (Index("ix_driver_code_lookup", "code", "active"),)

class PaymentIntent(Base):
    __tablename__ = "payment_intents"
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    passenger_id: Mapped[str] = mapped_column(ForeignKey("users.id"), nullable=False)
    driver_id: Mapped[str] = mapped_column(ForeignKey("drivers.id"), nullable=False)
    amount_xaf: Mapped[int] = mapped_column(Integer, nullable=False)
    fee_xaf: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    provider: Mapped[str] = mapped_column(String(30), nullable=False)
    provider_reference: Mapped[str | None] = mapped_column(String(160), unique=True)
    idempotency_key: Mapped[str] = mapped_column(String(128), unique=True, nullable=False)
    status: Mapped[str] = mapped_column(String(24), default="pending", nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now, nullable=False)
    __table_args__ = (
        CheckConstraint("amount_xaf > 0", name="ck_payment_amount_positive"),
        CheckConstraint("fee_xaf >= 0", name="ck_payment_fee_nonnegative"),
        CheckConstraint("status IN ('pending','succeeded','failed','expired','refunded')", name="ck_payment_status"),
    )

class ProviderEvent(Base):
    __tablename__ = "payment_provider_events"
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    provider: Mapped[str] = mapped_column(String(30), nullable=False)
    provider_event_id: Mapped[str] = mapped_column(String(160), nullable=False)
    intent_id: Mapped[str | None] = mapped_column(ForeignKey("payment_intents.id"))
    raw_sha256: Mapped[str] = mapped_column(String(64), nullable=False)
    received_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now, nullable=False)
    __table_args__ = (UniqueConstraint("provider", "provider_event_id", name="uq_provider_event"),)

class LedgerEntry(Base):
    __tablename__ = "ledger_entries"
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    intent_id: Mapped[str] = mapped_column(ForeignKey("payment_intents.id"), nullable=False)
    account: Mapped[str] = mapped_column(String(60), nullable=False)
    direction: Mapped[str] = mapped_column(String(6), nullable=False)
    amount_xaf: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now, nullable=False)
    __table_args__ = (
        CheckConstraint("amount_xaf > 0", name="ck_ledger_amount_positive"),
        CheckConstraint("direction IN ('debit','credit')", name="ck_ledger_direction"),
    )
