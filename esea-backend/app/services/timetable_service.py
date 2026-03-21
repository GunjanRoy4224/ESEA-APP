from sqlalchemy.orm import Session
from collections import defaultdict

from app.models.slot_time import SlotTime
from app.models.department_course import DepartmentCourse
from app.models.student_course import StudentCourse


def _slot_map(db: Session):
    slots = db.query(SlotTime).all()
    return {s.slot_code: s for s in slots}


def build_department_timetable(db: Session):
    slot_map = _slot_map(db)
    timetable = defaultdict(list)

    courses = db.query(DepartmentCourse).all()

    for course in courses:
        slot_codes = [s.strip() for s in course.slot_code.split(",")]


        for slot in slot_codes:
            slot_info = slot_map.get(slot)
            if not slot_info:
                continue

            timetable[slot_info.day].append({
                "course_code": course.course_code,
                "course_title": course.course_title,
                "slot": slot,
                "start_time": slot_info.start_time.strftime("%H:%M"),
                "end_time": slot_info.end_time.strftime("%H:%M"),
                "instructors": course.instructors,
                "classroom": course.classroom,
                "credit": course.credit,
                "tag": course.tag,
                "programme": course.programme,
            })

    return timetable


def build_student_timetable(db: Session, student_id: int):
    slot_map = _slot_map(db)
    student_timetable = defaultdict(list)

    selected = db.query(StudentCourse.course_code).filter(
        StudentCourse.student_id == student_id
    ).all()
    selected_codes = {c[0] for c in selected}

    if not selected_codes:
        return student_timetable

    courses = db.query(DepartmentCourse).filter(
        DepartmentCourse.course_code.in_(selected_codes)
    ).all()

    for course in courses:
        # ✅ FIXED FIELD NAME
        slot_codes = [s.strip() for s in course.slot_code.split(",")]

        for slot in slot_codes:
            slot_info = slot_map.get(slot)
            if not slot_info:
                continue

            student_timetable[slot_info.day].append({
                "course_code": course.course_code,
                "course_title": course.course_title,
                "slot": slot,
                "start_time": slot_info.start_time.strftime("%H:%M"),
                "end_time": slot_info.end_time.strftime("%H:%M"),
            })

    return student_timetable