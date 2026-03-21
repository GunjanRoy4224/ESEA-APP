from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models.content import Content
from app.schemas.content import ContentResponse

router = APIRouter(prefix="/content", tags=["Student Content"])

def fetch_content(db: Session, content_type: str):
    return (
        db.query(Content)
        .filter(Content.type == content_type)
        .order_by(Content.published_at.desc())
        .all()
    )

# Announcements
@router.get("/announcements", response_model=List[ContentResponse])
def get_announcements(db: Session = Depends(get_db)):
    return fetch_content(db, "announcement")

#events
@router.get("/events", response_model=List[ContentResponse])
def get_events(db: Session = Depends(get_db)):
    return fetch_content(db, "event")

# Research Blogs
@router.get("/research", response_model=List[ContentResponse])
def get_research_blogs(db: Session = Depends(get_db)):
    return fetch_content(db, "research")

#internships
@router.get("/internships", response_model=List[ContentResponse])
def get_internships(db: Session = Depends(get_db)):
    return fetch_content(db, "internship")

#newsletters
@router.get("/newsletters", response_model=List[ContentResponse])
def get_newsletters(db: Session = Depends(get_db)):
    return fetch_content(db, "newsletter")
