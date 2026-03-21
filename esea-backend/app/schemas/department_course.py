from pydantic import BaseModel

class DepartmentCourseResponse(BaseModel):
    course_code: str
    slot_code: str
    credit: int
    course_title: str
    instructors: str
    classroom: str | None
    tag: str
    programme: str

    class Config:
        from_attributes = True
