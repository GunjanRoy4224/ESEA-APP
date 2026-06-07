from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.schemas.content import ContentResponse
from app.services.content_service import get_all_content
from app.dependencies import get_current_user_optional
router = APIRouter(prefix="/content", tags=["Student Content"])

# Announcements
@router.get("/announcements", response_model=List[ContentResponse])
def get_announcements(db: Session = Depends(get_db)):
    return get_all_content(db, "announcement")

#events
@router.get("/events", response_model=List[ContentResponse])
def get_events(db: Session = Depends(get_db)):
    return get_all_content(db, "event")

# Research Blogs
@router.get("/research", response_model=List[ContentResponse])
def get_research_blogs(db: Session = Depends(get_db)):
    return get_all_content(db, "research")

#internships
@router.get("/internships", response_model=List[ContentResponse])
def get_internships(db: Session = Depends(get_db), user = Depends(get_current_user_optional)):
    return get_all_content(db, "internship", user=user)

#newsletters
@router.get("/newsletters", response_model=List[ContentResponse])
def get_newsletters(db: Session = Depends(get_db)):
    return get_all_content(db, "newsletter")
