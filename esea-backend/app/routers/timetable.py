from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.dependencies import get_current_student
from app.database import get_db
from app.services.timetable_service import (
    build_department_timetable,
    build_student_timetable,
)

router = APIRouter(prefix="/timetable", tags=["Timetable"])


@router.get("/department")
def department_timetable(db: Session = Depends(get_db)):
    return build_department_timetable(db)


@router.get("/student")
def student_timetable(
    db: Session = Depends(get_db),
    student = Depends(get_current_student),
):
    return build_student_timetable(db, student.id)