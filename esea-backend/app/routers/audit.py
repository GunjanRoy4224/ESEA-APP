from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import require_admin
from app.models.audit_log import AuditLog

router = APIRouter(prefix="/admin/audit", tags=["Audit Logs"])

@router.get("/")
def get_audit_logs(
    db: Session = Depends(get_db),
    admin = Depends(require_admin),
):
    return (
        db.query(AuditLog)
        .order_by(AuditLog.timestamp.desc())
        .limit(100)
        .all()
    )
