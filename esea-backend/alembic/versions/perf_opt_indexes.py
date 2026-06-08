"""performance optimization indexes

Revision ID: perf_opt_indexes
Revises: add_notification_tasks
Create Date: 2026-06-08

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'perf_opt_indexes'
down_revision = 'add_notification_tasks'
branch_labels = None
depends_on = None

disable_ddl_transaction = True

def upgrade() -> None:
    # Break out of Alembic's transaction block so CONCURRENTLY works
    op.execute("COMMIT")

    # 1. Comments Indexes
    op.execute("CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_comments_discussion_id ON comments (discussion_id)")
    op.execute("CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_comments_author_id ON comments (author_id)")
    op.execute("CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_comments_parent_comment_id ON comments (parent_comment_id)")

    # 2. Discussions Indexes
    op.execute("CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_discussions_author_id ON discussions (author_id)")
    op.execute("CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_discussions_created_at ON discussions (created_at DESC)")
    op.execute("CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_discussions_upvotes_count ON discussions (upvotes_count DESC)")

    # 3. Contents Indexes (Composite)
    op.execute("CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_contents_type_published_at ON contents (type, published_at DESC)")

    # 4. Notification Task Index
    op.execute("CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_notification_tasks_sent_send_at ON notification_tasks (sent, send_at)")

    # 5. Exam Timetable Index
    op.execute("CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_exam_timetable_date ON exam_timetable (date ASC)")

    # 6. Audit Logs Index
    op.execute("CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_audit_logs_timestamp ON audit_logs (timestamp DESC)")

    # 7. Users Alumni Composite
    op.execute("CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_users_role_status ON users (role, status)")

    # 8. Drop Redundant Index
    op.execute("DROP INDEX CONCURRENTLY IF EXISTS idx_poll_vote_discussion")

    # Re-open the transaction block so Alembic can safely commit its alembic_version update
    op.execute("BEGIN")


def downgrade() -> None:
    op.execute("COMMIT")

    # 8. Recreate redundant index
    op.execute("CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_poll_vote_discussion ON discussion_poll_votes (discussion_id)")

    # 7. Drop Users Composite
    op.execute("DROP INDEX CONCURRENTLY IF EXISTS ix_users_role_status")

    # 6. Drop Audit Logs Index
    op.execute("DROP INDEX CONCURRENTLY IF EXISTS ix_audit_logs_timestamp")

    # 5. Drop Exam Timetable Index
    op.execute("DROP INDEX CONCURRENTLY IF EXISTS ix_exam_timetable_date")

    # 4. Drop Notification Task Index
    op.execute("DROP INDEX CONCURRENTLY IF EXISTS ix_notification_tasks_sent_send_at")

    # 3. Drop Contents Indexes
    op.execute("DROP INDEX CONCURRENTLY IF EXISTS ix_contents_type_published_at")

    # 2. Drop Discussions Indexes
    op.execute("DROP INDEX CONCURRENTLY IF EXISTS ix_discussions_upvotes_count")
    op.execute("DROP INDEX CONCURRENTLY IF EXISTS ix_discussions_created_at")
    op.execute("DROP INDEX CONCURRENTLY IF EXISTS ix_discussions_author_id")

    # 1. Drop Comments Indexes
    op.execute("DROP INDEX CONCURRENTLY IF EXISTS ix_comments_parent_comment_id")
    op.execute("DROP INDEX CONCURRENTLY IF EXISTS ix_comments_author_id")
    op.execute("DROP INDEX CONCURRENTLY IF EXISTS ix_comments_discussion_id")

    op.execute("BEGIN")
