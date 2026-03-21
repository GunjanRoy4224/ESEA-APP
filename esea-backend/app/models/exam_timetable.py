from sqlalchemy import Column, Integer, String, Date
from app.database import Base
class ExamTimetable(Base):
    __tablename__ = "exam_timetable"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)          # Midsem / Endsem
    date = Column(Date, nullable=False)
    day = Column(String, nullable=False)
    time = Column(String, nullable=False)
    slot = Column(String, nullable=True)
    course = Column(String, nullable=False)
    enrolment = Column(Integer, nullable=True)
    instructor = Column(String, nullable=True)
    venue = Column(String, nullable=True)
