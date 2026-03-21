"""make users.email nullable

Revision ID: 3eb5d9d71faf
Revises: f5e79dec121f
Create Date: 2026-01-10 16:26:36.798566

"""
from typing import Sequence, Union

from alembic import op


# revision identifiers, used by Alembic.
revision: str = '3eb5d9d71faf'
down_revision: Union[str, Sequence[str], None] = 'f5e79dec121f'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    op.alter_column("users", "email", nullable=True)

def downgrade():
    op.alter_column("users", "email", nullable=False)

