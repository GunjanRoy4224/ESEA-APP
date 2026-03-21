"""add vote

Revision ID: a843723288ec
Revises: 39d724d15923
Create Date: 2026-02-12 20:09:12.432203

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'a843723288ec'
down_revision: Union[str, Sequence[str], None] = '39d724d15923'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
   op.create_table(
    "discussion_votes",
    sa.Column("id", sa.Integer(), primary_key=True),
    sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id"), nullable=False),
    sa.Column("discussion_id", sa.Integer(), sa.ForeignKey("discussions.id"), nullable=False),
    sa.Column("value", sa.Integer(), nullable=False),
    sa.UniqueConstraint("user_id", "discussion_id", name="uq_user_discussion_vote"),
)



def downgrade() -> None:
    op.drop_table("discussion_votes")
