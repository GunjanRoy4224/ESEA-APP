from sqlalchemy import Column, String, DateTime, Boolean
from sqlalchemy.sql import func
from app.database import Base
import uuid


class NotificationTask(Base):
    __tablename__ = "notification_tasks"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))

    content_id = Column(String)
    content_type = Column(String)

    title = Column(String)

    send_at = Column(DateTime)

    topic = Column(String)  # all_users / esea_members

    sent = Column(Boolean, default=False)

    created_at = Column(DateTime, server_default=func.now())