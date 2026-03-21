"""add esea_id and remove year from users

Revision ID: e7b95906f38e
Revises: 4612de5b70b9
Create Date: 2026-01-14 22:54:32.596805

"""
from typing import Sequence, Union



# revision identifiers, used by Alembic.
revision: str = 'e7b95906f38e'
down_revision: Union[str, Sequence[str], None] = '4612de5b70b9'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
