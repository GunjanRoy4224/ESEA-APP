from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import FileResponse
from datetime import datetime
import csv
import os
from typing import Dict

from app.dependencies import get_current_student

router = APIRouter(prefix="/feedback", tags=["Feedback"])

# ================= FILE PATH =================

BASE_DIR = os.path.dirname(os.path.dirname(__file__))  # app/
FEEDBACK_DIR = os.path.join(BASE_DIR, "feedback")
FEEDBACK_FILE = os.path.join(FEEDBACK_DIR, "feedback.csv")


# ================= UTILS =================

def ensure_feedback_file():
    """
    Create feedback directory and CSV file with header if not exists
    """
    os.makedirs(FEEDBACK_DIR, exist_ok=True)

    if not os.path.exists(FEEDBACK_FILE):
        with open(FEEDBACK_FILE, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow([
                "timestamp",
                "student_id",
                "feedback"
            ])


# ================= API =================

@router.post("/")
def submit_feedback(
    payload: Dict,
    student = Depends(get_current_student),
):
    """
    Save feedback into CSV file
    """
    message = payload.get("message")

    if not message or not message.strip():
        raise HTTPException(
            status_code=400,
            detail="Feedback message is required"
        )

    ensure_feedback_file()

    try:
        with open(FEEDBACK_FILE, "a", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow([
                datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                student.id,
                message.strip(),
            ])
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to save feedback: {e}"
        )

    return {"success": True}


@router.get("/download")
def download_feedback_csv(
    student = Depends(get_current_student),  # protect endpoint
):
    """
    Download feedback CSV file
    """
    if not os.path.exists(FEEDBACK_FILE):
        raise HTTPException(
            status_code=404,
            detail="No feedback available"
        )

    return FileResponse(
        FEEDBACK_FILE,
        media_type="text/csv",
        filename="feedback.csv",
    )
