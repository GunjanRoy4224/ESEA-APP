from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User
from app.dependencies import require_admin
from app.services.audit_service import log_action

router = APIRouter(prefix="/admin/alumni", tags=["Admin Alumni"])

@router.get("/")
def get_alumni(
    status: str = "pending",
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    users = db.query(User).filter(
        User.role == "alumni",
        User.status == status
    ).all()
    return users

@router.post("/{user_id}/approve")
def approve_alumni(
    user_id: int,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(404, "User not found")
        
    user.status = "approved"
    
    log_action(
        db=db,
        user=admin,
        action="Approved alumni",
        entity="user",
        entity_id=str(user.id)
    )
    db.commit()
    return {"message": "Alumni approved"}

@router.post("/{user_id}/reject")
def reject_alumni(
    user_id: int,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(404, "User not found")
        
    user.status = "rejected"
    
    log_action(
        db=db,
        user=admin,
        action="Rejected alumni",
        entity="user",
        entity_id=str(user.id)
    )
    db.commit()
    return {"message": "Alumni rejected"}

@router.post("/{user_id}/revoke")
def revoke_alumni(
    user_id: int,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(404, "User not found")
        
    user.status = "pending"  # Or "revoked" depending on enum
    
    log_action(
        db=db,
        user=admin,
        action="Revoked alumni access",
        entity="user",
        entity_id=str(user.id)
    )
    db.commit()
    return {"message": "Alumni access revoked"}
