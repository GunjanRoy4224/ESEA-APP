"""add sso_id to users

Revision ID: c4385439e0e9
Revises: bace50710358
Create Date: 2026-01-10 16:03:01.652816

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'c4385439e0e9'
down_revision: Union[str, Sequence[str], None] = 'bace50710358'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None




def upgrade():
    op.add_column(
        "users",
        sa.Column("sso_id", sa.Integer(), nullable=True)
    )


def downgrade():
    op.drop_column("users", "sso_id")
