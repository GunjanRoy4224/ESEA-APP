from sqlalchemy.orm import Session
from app.models.course_info import CourseInfo


def create_info(db: Session, data):
    info = CourseInfo(**data.dict())
    db.add(info)
    db.commit()
    db.refresh(info)
    return info


def get_all_info(db: Session):
    return db.query(CourseInfo).order_by(
        CourseInfo.course_code.asc()
    ).all()


def get_info_by_id(db: Session, info_id):
    return db.query(CourseInfo).filter(
        CourseInfo.id == info_id
    ).first()


def get_info_by_course(db: Session, course_code: str):
    return db.query(CourseInfo).filter(
        CourseInfo.course_code == course_code
    ).first()


def update_info(db: Session, info_id, data):
    info = get_info_by_id(db, info_id)
    if not info:
        return None

    for k, v in data.dict(exclude_unset=True).items():
        setattr(info, k, v)

    db.commit()
    db.refresh(info)
    return info


def delete_info(db: Session, info_id):
    info = get_info_by_id(db, info_id)
    if not info:
        return False

    db.delete(info)
    db.commit()
    return True
