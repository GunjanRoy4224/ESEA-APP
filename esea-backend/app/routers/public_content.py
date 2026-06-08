from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.schemas.content import ContentResponse
from app.services.content_service import get_all_content, get_content_by_id
from app.dependencies import get_current_user_optional
from fastapi import HTTPException, Response
router = APIRouter(prefix="/content", tags=["Student Content"])

# Announcements
@router.get("/announcements", response_model=List[ContentResponse])
def get_announcements(response: Response, limit: int = 20, offset: int = 0, db: Session = Depends(get_db)):
    data = get_all_content(db, "announcement", limit=limit, offset=offset)
    response.headers["X-Has-More"] = "true" if len(data) == limit else "false"
    return data

#events
@router.get("/events", response_model=List[ContentResponse])
def get_events(response: Response, limit: int = 20, offset: int = 0, db: Session = Depends(get_db)):
    data = get_all_content(db, "event", limit=limit, offset=offset)
    response.headers["X-Has-More"] = "true" if len(data) == limit else "false"
    return data

# Research Blogs
@router.get("/research", response_model=List[ContentResponse])
def get_research_blogs(response: Response, limit: int = 20, offset: int = 0, db: Session = Depends(get_db)):
    data = get_all_content(db, "research", limit=limit, offset=offset)
    response.headers["X-Has-More"] = "true" if len(data) == limit else "false"
    return data

#internships
@router.get("/internships", response_model=List[ContentResponse])
def get_internships(response: Response, limit: int = 20, offset: int = 0, db: Session = Depends(get_db), user = Depends(get_current_user_optional)):
    data = get_all_content(db, "internship", user=user, limit=limit, offset=offset)
    response.headers["X-Has-More"] = "true" if len(data) == limit else "false"
    return data

#newsletters
@router.get("/newsletters", response_model=List[ContentResponse])
def get_newsletters(response: Response, limit: int = 20, offset: int = 0, db: Session = Depends(get_db)):
    data = get_all_content(db, "newsletter", limit=limit, offset=offset)
    response.headers["X-Has-More"] = "true" if len(data) == limit else "false"
    return data

# single content
@router.get("/{content_id}", response_model=ContentResponse)
def get_single_content(content_id: str, db: Session = Depends(get_db)):
    content = get_content_by_id(db, content_id)
    if not content:
        raise HTTPException(status_code=404, detail="Content not found")
    return content
