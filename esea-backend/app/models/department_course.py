from sqlalchemy import Column, String, Integer
from app.database import Base

class DepartmentCourse(Base):
    __tablename__ = "department_courses"

    course_code = Column(String, primary_key=True, index=True)
    slot_code = Column(String, nullable=False)     # "L3, L4"
    credit = Column(Integer, nullable=False)
    course_title = Column(String, nullable=False)
    instructors = Column(String, nullable=False)
    classroom = Column(String, nullable=True)
    tag = Column(String, nullable=False)             # Core / Elective / Minor
    programme = Column(String, nullable=False)       # display only
