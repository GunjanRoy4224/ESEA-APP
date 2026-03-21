from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime

class ContentCreate(BaseModel):
    type: str
    title: str
    short_description: str
    full_description: Optional[str] = None
    image_url: Optional[str] = None
    file_url: Optional[str] = None
    external_link: Optional[str] = None
    event_venue: Optional[str] = None
    event_date: Optional[date] = None
    event_time: Optional[str] = None
    deadline: Optional[datetime] = None

class ContentResponse(ContentCreate):
    id: str
    published_at: datetime

    class Config:
         from_attributes = True