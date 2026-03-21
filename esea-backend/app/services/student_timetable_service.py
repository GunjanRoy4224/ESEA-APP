from sqlalchemy.orm import Session
from app.models.student_course import StudentCourse
from app.models.department_course import DepartmentCourse
from app.models.slot_time import SlotTime

def get_student_timetable(db: Session, student_id: int):
    selected = (
        db.query(StudentCourse.course_code)
        .filter(StudentCourse.student_id == student_id)
        .all()
    )

    if not selected:
        return []

    selected_codes = [c.course_code for c in selected]

    courses = (
        db.query(DepartmentCourse)
        .filter(DepartmentCourse.course_code.in_(selected_codes))
        .all()
    )

    slot_map = (
        db.query(SlotTime)
        .all()
    )

    result = []

    for course in courses:
        slots = [s.strip() for s in course.slot_code.split(",")]

        for slot in slots:
            for sm in slot_map:
                if sm.slot_code == slot:
                    result.append({
                        "course_code": course.course_code,
                        "day": sm.day,
                        "start_time": sm.start_time.strftime("%H:%M"),
                        "end_time": sm.end_time.strftime("%H:%M"),
                        "type": "Lab" if "L" in slot else "Lecture",
                    })

    return result
