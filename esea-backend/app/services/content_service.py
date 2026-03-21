from sqlalchemy.orm import Session
from app.models.content import Content
from datetime import datetime

def create_content(db: Session, data):
    content_data = data.dict(exclude_unset=True)  
    content = Content(**content_data)

    db.add(content)
    db.commit()
    db.refresh(content)

    return content


def get_all_content(db: Session, content_type=None, user=None, limit=50, offset=0):
    q = db.query(Content)

    if content_type:
        q = q.filter(Content.type == content_type)

    # Internship logic
    if content_type == "internship":
        q = q.filter(Content.is_verified.is_(True))

        is_member = bool(user and user.esea_id) 
        if not is_member:
            q = q.filter(
                (Content.public_release_date.is_(None)) |
                (Content.public_release_date <= datetime.utcnow())
            )

    return (
        q.order_by(Content.published_at.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )


def get_content_by_id(db: Session, content_id: str):
    return db.query(Content).filter(Content.id == content_id).first()


def update_content(db: Session, content_id: str, data):
    content = get_content_by_id(db, content_id)

    if not content:
        return None

    for key, value in data.dict(exclude_unset=True).items():
        setattr(content, key, value)

    db.commit()
    db.refresh(content)

    return content


def delete_content(db: Session, content_id: str):
    content = get_content_by_id(db, content_id)

    if not content:
        return False

    db.delete(content)
    db.commit()

    return True