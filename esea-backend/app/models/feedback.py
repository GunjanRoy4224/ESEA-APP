import uuid
from sqlalchemy import Column, String, Text, DateTime, ForeignKey
from datetime import datetime
from sqlalchemy.dialects.postgresql import UUID

from app.database import Base

class Feedback(Base):
    __tablename__ = "feedbacks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    category = Column(String(50), nullable=False, default="general")
    message = Column(Text, nullable=False)
    status = Column(String(20), nullable=False, default="pending")
    created_at = Column(DateTime, default=datetime.utcnow)
