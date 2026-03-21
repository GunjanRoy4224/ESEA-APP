from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.content import Content
from app.schemas.content import ContentCreate
from app.dependencies import get_current_user

router = APIRouter(prefix="/internships")

@router.post("/submit")
def submit_internship(
    payload: ContentCreate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    if payload.type != "internship":
        raise HTTPException(400, "Invalid content type")

    internship = Content(
        **payload.dict(),
        is_verified=False,
        created_by=user.id,
    )

    db.add(internship)
    db.commit()
    db.refresh(internship)

    return {"message": "Internship submitted for verification"}