"""add_search_vectors

Revision ID: f1376d3f7c96
Revises: perf_opt_indexes
Create Date: 2026-06-08 16:36:32.981855

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'f1376d3f7c96'
down_revision: Union[str, Sequence[str], None] = 'perf_opt_indexes'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Discussions FTS
    op.execute("""
        ALTER TABLE discussions 
        ADD COLUMN search_vector tsvector 
        GENERATED ALWAYS AS (
            setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
            setweight(to_tsvector('english', coalesce(content, '')), 'B')
        ) STORED;
    """)
    op.execute("CREATE INDEX ix_discussions_search ON discussions USING GIN (search_vector);")

    # Contents FTS
    op.execute("""
        ALTER TABLE contents 
        ADD COLUMN search_vector tsvector 
        GENERATED ALWAYS AS (
            setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
            setweight(to_tsvector('english', coalesce(short_description, '')), 'B') ||
            setweight(to_tsvector('english', coalesce(full_description, '')), 'C')
        ) STORED;
    """)
    op.execute("CREATE INDEX ix_contents_search ON contents USING GIN (search_vector);")


def downgrade() -> None:
    op.execute("DROP INDEX IF EXISTS ix_contents_search;")
    op.execute("ALTER TABLE contents DROP COLUMN IF EXISTS search_vector;")
    
    op.execute("DROP INDEX IF EXISTS ix_discussions_search;")
    op.execute("ALTER TABLE discussions DROP COLUMN IF EXISTS search_vector;")
