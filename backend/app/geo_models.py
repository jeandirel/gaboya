"""Geographic reference data, kept separate from operational transport coverage."""
from sqlalchemy import Boolean, Float, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column
from .database import Base

class Province(Base):
    __tablename__ = "geo_provinces"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    code: Mapped[str] = mapped_column(String(20), unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String(120), nullable=False)

class City(Base):
    __tablename__ = "geo_cities"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    geonames_id: Mapped[int | None] = mapped_column(Integer, unique=True)
    province_id: Mapped[int] = mapped_column(ForeignKey("geo_provinces.id"), nullable=False)
    name: Mapped[str] = mapped_column(String(160), nullable=False)
    latitude: Mapped[float | None] = mapped_column(Float)
    longitude: Mapped[float | None] = mapped_column(Float)
    service_enabled: Mapped[bool] = mapped_column(Boolean, default=False, server_default="false", nullable=False)

class TransportPoint(Base):
    __tablename__ = "geo_transport_points"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    osm_type: Mapped[str | None] = mapped_column(String(20))
    osm_id: Mapped[int | None] = mapped_column(Integer)
    city_id: Mapped[int] = mapped_column(ForeignKey("geo_cities.id"), nullable=False)
    name: Mapped[str] = mapped_column(String(180), nullable=False)
    kind: Mapped[str] = mapped_column(String(40), nullable=False)
    latitude: Mapped[float | None] = mapped_column(Float)
    longitude: Mapped[float | None] = mapped_column(Float)
    verified: Mapped[bool] = mapped_column(Boolean, default=False, server_default="false", nullable=False)
    service_enabled: Mapped[bool] = mapped_column(Boolean, default=False, server_default="false", nullable=False)
    __table_args__ = (UniqueConstraint("osm_type", "osm_id", name="uq_geo_point_osm"),)
