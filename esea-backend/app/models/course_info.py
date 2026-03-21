from sqlalchemy import Column, String, DateTime, JSON
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
import uuid

from app.database import Base

class CourseInfo(Base):
    __tablename__ = "course_info"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    course_code = Column(String, nullable=False, index=True)
    course_title = Column(String, nullable=False)
    instructor = Column(String, nullable=True)

    # syllabus, resources, pyqs (drive links)
    info = Column(JSON, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
