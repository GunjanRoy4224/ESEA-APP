
from sqlalchemy import Column, String, Text, Date, DateTime, Boolean
from sqlalchemy.sql import func
from app.database import Base
import uuid

class Content(Base):
    __tablename__ = "contents"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    type = Column(String, nullable=False)

    title = Column(String, nullable=False)
    short_description = Column(Text, nullable=False)
    full_description = Column(Text)

    image_url = Column(String)
    file_url = Column(String)
    external_link = Column(String)
  
    event_venue = Column(String)
    event_date = Column(Date)
    event_time = Column(String)
    deadline = Column(Date)

    is_verified = Column(Boolean, default=True)  

    created_by = Column(String, nullable=True)
    verified_by = Column(String, nullable=True)
    verified_at = Column(DateTime, nullable=True)

    public_release_date = Column(DateTime, nullable=True)
    published_at = Column(DateTime, server_default=func.now())
