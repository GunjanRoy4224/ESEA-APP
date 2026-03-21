from pydantic import BaseModel
from typing import List, Dict, Optional
from uuid import UUID
from datetime import datetime


class InfoItem(BaseModel):
    title: str
    link: str


class PYQItem(BaseModel):
    year: str
    link: str


class CourseInfoBase(BaseModel):
    course_code: str
    course_title: str
    instructor: Optional[str] = None

    info : Dict[str, List[Dict]]  
    # keys: syllabus, resources, pyqs


class CourseInfoCreate(CourseInfoBase):
    pass


class CourseInfoResponse(CourseInfoBase):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
