from pydantic import BaseModel
from datetime import date

class ExamRow(BaseModel):
    date: date
    day: str
    time: str
    slot: str | None
    course: str
    enrolment: int | None
    instructor: str | None
    venue: str | None

    class Config:
        from_attributes = True


class ExamTimetableResponse(BaseModel):
    title: str
    rows: list[ExamRow]
