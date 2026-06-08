from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from datetime import datetime
from typing import Dict
import csv
import tempfile
import os

from app.dependencies import get_current_student, require_admin
from app.database import get_db
from app.models.feedback import Feedback
from app.models.user import User

router = APIRouter(prefix="/feedback", tags=["Feedback"])

# ================= API =================

@router.post("/")
def submit_feedback(
    payload: Dict,
    db: Session = Depends(get_db),
    student = Depends(get_current_student),
):
    """
    Save feedback into PostgreSQL
    """
    message = payload.get("message")
    category = payload.get("category", "general")

    if not message or not message.strip():
        raise HTTPException(
            status_code=400,
            detail="Feedback message is required"
        )

    try:
        feedback_entry = Feedback(
            user_id=student.id,
            category=category,
            message=message.strip(),
            status="pending"
        )
        db.add(feedback_entry)
        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Failed to save feedback: {e}"
        )

    return {"success": True}


@router.get("/admin", tags=["Admin Feedback"])
def list_feedbacks(
    db: Session = Depends(get_db),
    admin = Depends(require_admin),
):
    """
    Get all feedbacks for Admin UI
    """
    feedbacks = db.query(Feedback).order_by(Feedback.created_at.desc()).all()
    results = []
    for f in feedbacks:
        # Join with user to get details if needed, or just return user_id
        user = db.query(User).filter(User.id == f.user_id).first()
        results.append({
            "id": str(f.id),
            "user_id": str(f.user_id),
            "user_name": user.full_name if user else "Unknown",
            "user_email": user.email if user else "Unknown",
            "category": f.category,
            "message": f.message,
            "status": f.status,
            "created_at": f.created_at
        })
    return results

@router.get("/admin/export", tags=["Admin Feedback"])
def download_feedback_csv(
    db: Session = Depends(get_db),
    admin = Depends(require_admin),
):
    """
    Export feedback to CSV file (Admin only)
    """
    feedbacks = db.query(Feedback).order_by(Feedback.created_at.desc()).all()
    
    with tempfile.NamedTemporaryFile(delete=False, suffix=".csv", mode="w", newline="", encoding="utf-8") as tmp:
        writer = csv.writer(tmp)
        writer.writerow(["id", "user_id", "category", "message", "status", "created_at"])
        for f in feedbacks:
            writer.writerow([
                str(f.id),
                str(f.user_id),
                f.category,
                f.message,
                f.status,
                f.created_at.strftime("%Y-%m-%d %H:%M:%S")
            ])
        tmp_path = tmp.name

    return FileResponse(
        tmp_path,
        media_type="text/csv",
        filename="feedbacks_export.csv",
    )
