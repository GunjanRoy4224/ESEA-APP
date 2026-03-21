"""add crowdsourced internship system

Revision ID: add_crowdsourced_internship
Revises: previous_revision_id
Create Date: 2026-03-04
"""

from alembic import op
import sqlalchemy as sa


# revision identifiers
revision = "add_crowdsourced_internship"
down_revision = "a843723288ec"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column(
        "contents",
        sa.Column("is_verified", sa.Boolean(), nullable=True)
    )

    op.add_column(
        "contents",
        sa.Column("created_by", sa.String(), nullable=True)
    )

    op.add_column(
        "contents",
        sa.Column("verified_by", sa.String(), nullable=True)
    )

    op.add_column(
        "contents",
        sa.Column("verified_at", sa.DateTime(), nullable=True)
    )

    op.add_column(
        "contents",
        sa.Column("public_release_date", sa.DateTime(), nullable=True)
    )

    # Default old content to verified
    op.execute("UPDATE contents SET is_verified = TRUE")

    # Make column non-nullable after update
    op.alter_column(
        "contents",
        "is_verified",
        nullable=False
    )


def downgrade():
    op.drop_column("contents", "public_release_date")
    op.drop_column("contents", "verified_at")
    op.drop_column("contents", "verified_by")
    op.drop_column("contents", "created_by")
    op.drop_column("contents", "is_verified")