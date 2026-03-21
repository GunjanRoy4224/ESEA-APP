"""make users.email nullable

Revision ID: 4612de5b70b9
Revises: 3eb5d9d71faf
Create Date: 2026-01-10 16:27:13.713548

"""
from typing import Sequence, Union



# revision identifiers, used by Alembic.
revision: str = '4612de5b70b9'
down_revision: Union[str, Sequence[str], None] = '3eb5d9d71faf'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
