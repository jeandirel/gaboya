"""Connexion PostgreSQL côté serveur uniquement."""
import os
from functools import lru_cache
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

class Base(DeclarativeBase):
    pass

@lru_cache(maxsize=1)
def get_engine():
    url = os.getenv("DATABASE_URL", "").strip()
    if not url:
        raise RuntimeError("DATABASE_URL absent")
    # Neon retourne souvent postgresql:// ; utiliser psycopg 3 en backend.
    if url.startswith("postgresql://"):
        url = url.replace("postgresql://", "postgresql+psycopg://", 1)
    if not url.startswith(("postgresql+psycopg://", "sqlite://")):
        raise RuntimeError("Seules les URLs PostgreSQL et SQLite de test sont admises")
    return create_engine(url, pool_pre_ping=True, hide_parameters=True)

def make_session():
    return sessionmaker(bind=get_engine(), expire_on_commit=False)


def get_db():
    with make_session()() as db:
        try:
            yield db
        finally:
            db.rollback()
