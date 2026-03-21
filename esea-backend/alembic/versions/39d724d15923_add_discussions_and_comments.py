"""add discussions and comments

Revision ID: 39d724d15923
Revises: e7b95906f38e
Create Date: 2026-02-12 17:52:01.569365

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '39d724d15923'
down_revision: Union[str, Sequence[str], None] = 'e7b95906f38e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "discussions",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("title", sa.String(), nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("author_id", sa.Integer(), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("category", sa.String(), nullable=True),
        sa.Column("upvotes_count", sa.Integer(), default=0),
        sa.Column("comments_count", sa.Integer(), default=0),
        sa.Column("is_pinned", sa.Boolean(), default=False),
        sa.Column("is_locked", sa.Boolean(), default=False),
        sa.Column("created_at", sa.DateTime(), nullable=True),
        sa.Column("updated_at", sa.DateTime(), nullable=True),
    )

    op.create_table(
        "comments",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("discussion_id", sa.Integer(), sa.ForeignKey("discussions.id"), nullable=False),
        sa.Column("author_id", sa.Integer(), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("parent_comment_id", sa.Integer(), nullable=True),
        sa.Column("upvotes_count", sa.Integer(), default=0),
        sa.Column("created_at", sa.DateTime(), nullable=True),
    )



def downgrade() -> None:
    op.drop_table("comments")
    op.drop_table("discussions")
