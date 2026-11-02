"""Geographic catalogue, no active transport services by default.

Revision ID: 0002_geo_catalog
Revises: 0001_initial
"""
from alembic import op
from sqlalchemy import inspect
from app.geo_models import Province, City, TransportPoint
revision = "0002_geo_catalog"
down_revision = "0001_initial"
branch_labels = None
depends_on = None

def upgrade():
    # 0001_initial uses Base.metadata.create_all dynamically: guard fresh installs.
    bind = op.get_bind()
    for table in (Province.__table__, City.__table__, TransportPoint.__table__):
        table.create(bind=bind, checkfirst=True)

def downgrade():
    bind = op.get_bind()
    for table in (TransportPoint.__table__, City.__table__, Province.__table__):
        table.drop(bind=bind, checkfirst=True)
