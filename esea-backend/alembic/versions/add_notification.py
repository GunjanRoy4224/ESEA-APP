from alembic import op
import sqlalchemy as sa


revision = "add_notification_tasks"
down_revision = "add_crowdsourced_internship"


def upgrade():

    op.create_table(
        "notification_tasks",

        sa.Column("id", sa.String(), primary_key=True),

        sa.Column("content_id", sa.String(), nullable=False),

        sa.Column("content_type", sa.String(), nullable=False),

        sa.Column("title", sa.String(), nullable=False),

        sa.Column("send_at", sa.DateTime(), nullable=False),

        sa.Column("topic", sa.String(), nullable=False),

        sa.Column("sent", sa.Boolean(), default=False),

        sa.Column("created_at", sa.DateTime(), server_default=sa.func.now())
    )


def downgrade():
    op.drop_table("notification_tasks")