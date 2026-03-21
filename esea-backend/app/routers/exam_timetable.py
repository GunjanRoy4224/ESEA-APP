from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.exam_timetable import ExamTimetable
from app.schemas.exam_timetable import ExamTimetableResponse

router = APIRouter(prefix="/timetable", tags=["Exam Timetable"])

@router.get("/exams", response_model=ExamTimetableResponse | dict)
def get_exam_timetable(db: Session = Depends(get_db)):
    rows = db.query(ExamTimetable).order_by(ExamTimetable.date).all()

    if not rows:
        return {"message": "Not announced yet"}

    title = rows[0].title
    return {
        "title": title,
        "rows": rows,
    }
