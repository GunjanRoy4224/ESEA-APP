from pydantic import BaseModel

class StudentCourseRequest(BaseModel):
    course_code: str

class StudentCourseResponse(BaseModel):
    course_code: str

    class Config:
        from_attributes = True
