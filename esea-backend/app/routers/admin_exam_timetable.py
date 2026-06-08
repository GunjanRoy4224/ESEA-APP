import shutil
import tempfile
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from sqlalchemy.orm import Session
from app.services.audit_service import log_action
from app.database import get_db
from app.dependencies import require_admin
from app.services.exam_timetable_service import replace_exam_timetable
from datetime import datetime
from app.models.notification_task import NotificationTask

router = APIRouter(prefix="/admin/exams", tags=["Admin Exam Timetable"])

@router.post("/upload")
def upload_exam_timetable(
    title: str = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    admin = Depends(require_admin),
):
    # ✅ FIX
    if not file.filename or not file.filename.lower().endswith((".xlsx", ".xls")):
        raise HTTPException(status_code=400, detail="Excel file required")

    with tempfile.NamedTemporaryFile(delete=False) as tmp:
        shutil.copyfileobj(file.file, tmp)
        tmp_path = tmp.name

    try:
        replace_exam_timetable(db, title, tmp_path)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
        
    # Notify students that a new exam timetable was published
    task = NotificationTask(
        content_type="timetable",
        title=f"New Exam Timetable: {title}",
        send_at=datetime.utcnow(),
        topic="students"
    )
    db.add(task)
    db.commit()
    
    log_action(
        db=db,
        user=admin,
        action="Uploaded exam timetable",
        entity="exam_timetable",
        entity_id=None,
    )

    return {"success": True, "message": "Exam timetable updated"}