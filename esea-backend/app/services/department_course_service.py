import pandas as pd
from sqlalchemy.orm import Session
from app.models.department_course import DepartmentCourse

REQUIRED_COLUMNS = {
    "course_code",
    "slot_code",
    "credit",
    "course_title",
    "instructors",
    "classroom",
    "tag",
    "programme",
}

def replace_department_courses(db: Session, file_path: str):
    df = pd.read_excel(file_path)

    if not REQUIRED_COLUMNS.issubset(df.columns):
        raise ValueError("Invalid department course file format")

    db.query(DepartmentCourse).delete()

    for _, row in df.iterrows():
        course = DepartmentCourse(
            course_code=row["course_code"].strip(),
            slot_code=row["slot_code"].strip(),
            credit=int(row["credit"]),
            course_title=row["course_title"],
            instructors=row["instructors"],
            classroom=row.get("classroom"),
            tag=row["tag"],
            programme=row["programme"],
        )
        db.add(course)

    db.commit()
