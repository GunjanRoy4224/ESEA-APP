from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.dependencies import get_current_student
from app.schemas.student_course import (
    StudentCourseRequest,
    StudentCourseResponse,
)
from app.services.student_course_service import (
    add_course,
    remove_course,
    list_courses,
)

router = APIRouter(prefix="/student/courses", tags=["Student Courses"])

@router.get("/", response_model=List[StudentCourseResponse])
def get_my_courses(
    db: Session = Depends(get_db),
    student = Depends(get_current_student),
):
    return list_courses(db, student.id)


@router.post("/")
def add_my_course(
    payload: StudentCourseRequest,
    db: Session = Depends(get_db),
    student = Depends(get_current_student),
):
    add_course(db, student.id, payload.course_code)
    return {"success": True}


@router.delete("/{course_code}")
def remove_my_course(
    course_code: str,
    db: Session = Depends(get_db),
    student = Depends(get_current_student),
):
    success = remove_course(db, student.id, course_code)
    if not success:
        raise HTTPException(status_code=404, detail="Course not found")
    return {"success": True}
