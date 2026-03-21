"""add missing user profile columns

Revision ID: f5e79dec121f
Revises: <PUT_PREVIOUS_REVISION_ID_HERE>
Create Date: 2026-01-10
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = "f5e79dec121f"
down_revision = "c4385439e0e9"
branch_labels = None
depends_on = None

def upgrade():
    # Add missing columns
    op.add_column("users", sa.Column("username", sa.String(), nullable=True))
    op.add_column("users", sa.Column("first_name", sa.String(), nullable=True))
    op.add_column("users", sa.Column("last_name", sa.String(), nullable=True))
    op.add_column("users", sa.Column("join_year", sa.Integer(), nullable=True))
    op.add_column("users", sa.Column("graduation_year", sa.Integer(), nullable=True))


def downgrade():
    op.drop_column("users", "graduation_year")
    op.drop_column("users", "join_year")
    op.drop_column("users", "last_name")
    op.drop_column("users", "first_name")
    op.drop_column("users", "username")