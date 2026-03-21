from sqlalchemy import Column, String
from app.database import Base

class Course(Base):
    __tablename__ = "courses"

    course_code = Column(String, primary_key=True)  # e.g. ES204
    course_name = Column(String, nullable=False)
    professor = Column(String, nullable=False)
