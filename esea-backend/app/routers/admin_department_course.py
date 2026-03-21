import shutil
import tempfile
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.orm import Session
from app.services.audit_service import log_action    
from app.database import get_db
from app.dependencies import require_admin
from app.services.department_course_service import replace_department_courses

router = APIRouter(prefix="/admin/department-courses", tags=["Admin Department Courses"])

@router.post("/upload")
def upload_department_courses(
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
        replace_department_courses(db, tmp_path)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    
    log_action(
        db=db,
        user=admin,
        action="Uploaded department courses",
        entity="department_courses",
        entity_id=None,
    )
    return {"success": True, "message": "Department courses updated"}