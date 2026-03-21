from sqlalchemy.orm import Session
from app.models.student_course import StudentCourse

def add_course(db: Session, student_id: int, course_code: str):
    existing = (
        db.query(StudentCourse)
        .filter(
            StudentCourse.student_id == student_id,
            StudentCourse.course_code == course_code,
        )
        .first()
    )
    if existing:
        return existing

    sc = StudentCourse(
        student_id=student_id,
        course_code=course_code,
    )
    db.add(sc)
    db.commit()
    return sc


def remove_course(db: Session, student_id: int, course_code: str):
    sc = (
        db.query(StudentCourse)
        .filter(
            StudentCourse.student_id == student_id,
            StudentCourse.course_code == course_code,
        )
        .first()
    )
    if sc:
        db.delete(sc)
        db.commit()
        return True
    return False


def list_courses(db: Session, student_id: int):
    return (
        db.query(StudentCourse)
        .filter(StudentCourse.student_id == student_id)
        .all()
    )
