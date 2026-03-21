from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from datetime import datetime
from app.database import Base

class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    user_email = Column(String, nullable=False)

    action = Column(String, nullable=False)
    entity = Column(String, nullable=False)   # timetable / content
    entity_id = Column(String, nullable=True) # content_id if applicable

    timestamp = Column(DateTime(timezone=True), default=datetime.utcnow)
