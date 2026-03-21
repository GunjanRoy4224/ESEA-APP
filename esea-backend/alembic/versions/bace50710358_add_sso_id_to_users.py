"""add sso_id to users

Revision ID: bace50710358
Revises: 
Create Date: 2026-01-10 15:54:14.530775

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'bace50710358'
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    op.add_column(
        "users",
        sa.Column("sso_id", sa.Integer(), nullable=True)
    )

    op.execute("UPDATE users SET sso_id = id")

    op.alter_column("users", "sso_id", nullable=False)

    op.create_index(
        "ix_users_sso_id",
        "users",
        ["sso_id"],
        unique=True
    )


def downgrade() -> None:
    """Downgrade schema."""
    pass
