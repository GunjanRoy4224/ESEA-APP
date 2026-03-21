from pydantic import BaseModel

class CourseResponse(BaseModel):
    course_code: str
    course_name: str
    professor: str

    class Config:
        from_attributes = True
