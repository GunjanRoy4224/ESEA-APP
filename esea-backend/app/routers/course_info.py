from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.course_info import CourseInfoResponse
from app.services.course_info_service import (
    get_all_info,
    get_info_by_course,
)

router = APIRouter(prefix="/course-info", tags=["Course Info"])


@router.get("/", response_model=list[CourseInfoResponse])
def list_all_course_info(db: Session = Depends(get_db)):
    return get_all_info(db)


@router.get("/{course_code}", response_model=CourseInfoResponse)
def get_course_info(
    course_code: str,
    db: Session = Depends(get_db),
):
    info = get_info_by_course(db, course_code)
    if not info:
        raise HTTPException(status_code=404, detail="Course info not found")
    return info
