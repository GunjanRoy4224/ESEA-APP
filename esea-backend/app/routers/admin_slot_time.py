import shutil
import tempfile
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.orm import Session
from app.services.audit_service import log_action
from app.database import get_db
from app.dependencies import require_admin
from app.services.slot_time_service import replace_slot_time_map

router = APIRouter(prefix="/admin/slot-time", tags=["Admin Slot Time"])

@router.post("/upload")
def upload_slot_time(
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
        replace_slot_time_map(db, tmp_path)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    
    log_action(
        db=db,
        user=admin,
        action="Uploaded slot time map",
        entity="slot_time",
        entity_id=None,
    )

    return {"success": True, "message": "Slot time map updated"}