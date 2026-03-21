from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.course_info import (
    CourseInfoCreate,
    CourseInfoResponse,
)
from app.services.course_info_service import (
    create_info,
    update_info,
    delete_info,
    get_all_info,
)
from app.dependencies import require_admin
from app.services.audit_service import log_action

router = APIRouter(prefix="/admin/course-info", tags=["Admin Course Info"])


@router.post("/", response_model=CourseInfoResponse)
def create_course_info(
    payload: CourseInfoCreate,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    info = create_info(db, payload)

    log_action(
        db=db,
        user=admin,
        action="Created course info",
        entity="course_info",
        entity_id=info.id,
    )

    return info


@router.get("/", response_model=list[CourseInfoResponse])
def list_course_info(
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    return get_all_info(db)


@router.put("/{info_id}", response_model=CourseInfoResponse)
def update_course_info(
    info_id: str,
    payload: CourseInfoCreate,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    info = update_info(db, info_id, payload)
    if not info:
        raise HTTPException(status_code=404, detail="Course info not found")

    log_action(
        db=db,
        user=admin,
        action="Updated course info",
        entity="course_info",
        entity_id=info.id,
    )

    return info


@router.delete("/{info_id}")
def delete_course_info(
    info_id: str,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    success = delete_info(db, info_id)
    if not success:
        raise HTTPException(status_code=404, detail="Course info not found")

    log_action(
        db=db,
        user=admin,
        action="Deleted course info",
        entity="course_info",
        entity_id=info_id,
    )

    return {"success": True}
