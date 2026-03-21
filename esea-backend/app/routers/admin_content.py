from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timedelta

from app.database import get_db
from app.schemas.content import ContentCreate, ContentResponse

from app.services.content_service import (
    create_content,
    update_content,
    delete_content,
    get_content_by_id
)

from app.dependencies import require_admin
from app.services.audit_service import log_action

from app.services.notification_task_service import create_content_notifications
from app.services.notification_service import send_topic_notification


router = APIRouter(prefix="/admin/content")


# ================= CREATE CONTENT =================

@router.post("/", response_model=ContentResponse)
def create(
    payload: ContentCreate,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):

    content = create_content(db, payload)

    # 🔔 Create notification tasks (immediate + reminders)
    create_content_notifications(db, content)

    log_action(
        db=db,
        user=admin,
        action="Created new content",
        entity="content",
        entity_id=content.id,
    )

    db.commit()

    return content


# ================= GET CONTENT =================

@router.get("/{content_id}", response_model=ContentResponse)
def get_content(
    content_id: str,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):

    content = get_content_by_id(db, content_id)

    if not content:
        raise HTTPException(status_code=404, detail="Content not found")

    return content


# ================= UPDATE CONTENT =================

@router.put("/{content_id}", response_model=ContentResponse)
def update_existing_content(
    content_id: str,
    payload: ContentCreate,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):

    content = update_content(db, content_id, payload)

    if not content:
        raise HTTPException(status_code=404, detail="Content not found")

    log_action(
        db=db,
        user=admin,
        action="Updated content",
        entity="content",
        entity_id=content.id,
    )

    db.commit()

    return content


# ================= DELETE CONTENT =================

@router.delete("/{content_id}")
def remove_content(
    content_id: str,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):

    success = delete_content(db, content_id)

    if not success:
        raise HTTPException(status_code=404, detail="Content not found")

    log_action(
        db=db,
        user=admin,
        action="Deleted content",
        entity="content",
        entity_id=content_id,
    )

    db.commit()

    return {"success": True}


# ================= APPROVE INTERNSHIP =================

@router.post("/{content_id}/approve")
def approve_internship(
    content_id: str,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):

    content = get_content_by_id(db, content_id)

    if not content or content.type != "internship":
        raise HTTPException(404, "Internship not found")

    if not content.deadline:
        raise HTTPException(400, "Deadline required")

    today = datetime.utcnow().date()
    days_left = (content.deadline - today).days

    # Early access logic
    early_days = 3 if days_left <= 3 else 5

    content.is_verified = True
    content.verified_by = admin.id
    content.verified_at = datetime.utcnow()
    content.public_release_date = datetime.utcnow() + timedelta(days=early_days)

    db.commit()

    # 🔔 Send notification to ESEA members
    send_topic_notification(
        title="New Internship (ESEA Exclusive)",
        body=content.title,
        topic="esea_members"
    )

    return {"message": "Internship approved"}