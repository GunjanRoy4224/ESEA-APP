from sqlalchemy import Column, Integer, String, ForeignKey, UniqueConstraint
from app.database import Base

class StudentCourse(Base):
    __tablename__ = "student_courses"

    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    course_code = Column(String, nullable=False)

    __table_args__ = (
        UniqueConstraint("student_id", "course_code", name="uq_student_course"),
    )
