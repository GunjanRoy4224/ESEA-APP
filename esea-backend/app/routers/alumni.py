from fastapi import APIRouter, Depends, Form, HTTPException
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from typing import Optional
import requests

from app.database import get_db
from app.models.user import User
from app.routers.auth import create_access_token
from app.dependencies import require_admin

router = APIRouter(prefix="/alumni", tags=["Alumni"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# -----------------------------------------
# IITB PAGE VERIFICATION FUNCTION (SECURED)
# -----------------------------------------
def verify_from_iitb_page(qr_url: str, input_name: str):
    try:
        print("🌐 Opening IITB page:", qr_url)

        # ✅ SECURITY FIX
        if not qr_url.lower().startswith("https://iitb.ac.in/"):
            print("Invalid domain")
            return False

        response = requests.get(qr_url, timeout=3)

        if response.status_code != 200:
            print("IITB page not reachable")
            return False

        page_text = response.text.lower()

        name_clean = input_name.lower().replace(" ", "")
        page_clean = page_text.replace(" ", "")

        return name_clean in page_clean

    except Exception as e:
        print("Verification error:", str(e))
        return False


# -----------------------------------------
# SIGNUP
# -----------------------------------------
@router.post("/signup")
def alumni_signup(
    name: str = Form(...),
    alumni_id: str = Form(...),
    password: str = Form(...),
    graduation_year: int = Form(...),
    department: str = Form(...),
    qr_data: Optional[str] = Form(None),
    db: Session = Depends(get_db),
):
    existing = db.query(User).filter(User.alumni_id == alumni_id).first()
    if existing:
        raise HTTPException(400, "Alumni already exists")

    hashed_password = pwd_context.hash(password)

    status = "pending"
    verification_method = "manual"

    if qr_data:
        if "iitb.ac.in" in qr_data.lower():
            if verify_from_iitb_page(qr_data, name):
                status = "verified"
                verification_method = "qr_live_verify"

    user = User(
        name=name,
        alumni_id=alumni_id,
        hashed_password=hashed_password,
        graduation_year=graduation_year,
        department=department,
        role="alumni",
        status=status,
        verification_method=verification_method,
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    if status == "verified":
        token = create_access_token(
            {"sub": str(user.id), "role": "alumni"}
        )

        return {
            "status": "verified",
            "access_token": token,
            "token_type": "bearer",
        }

    return {"status": "pending"}


# -----------------------------------------
# LOGIN
# -----------------------------------------
@router.post("/login")
def alumni_login(
    alumni_id: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.alumni_id == alumni_id).first()

    if not user:
        raise HTTPException(404, "User not found")

    if (user.role or "").lower() != "alumni":
        raise HTTPException(403, "Not an alumni")

    if user.status != "verified":
        raise HTTPException(403, "Verification pending")

    if not user.hashed_password or not pwd_context.verify(password, user.hashed_password):
        raise HTTPException(401, "Invalid password")

    token = create_access_token(
        {"sub": str(user.id), "role": "alumni"}
    )

    return {
        "access_token": token,
        "token_type": "bearer",
    }


# -----------------------------------------
# ADMIN ROUTES (SAFE RESPONSE)
# -----------------------------------------
@router.get("/admin/pending")
def get_pending_alumni(
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    users = db.query(User).filter(
        User.role == "alumni",
        User.status == "pending"
    ).all()

    return [
        {
            "id": u.id,
            "name": u.name,
            "alumni_id": u.alumni_id,
            "department": u.department,
            "graduation_year": u.graduation_year,
            "status": u.status,
        }
        for u in users
    ]


@router.post("/admin/approve/{user_id}")
def approve_alumni(
    user_id: int,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(404, "User not found")

    user.status = "verified"
    db.commit()

    return {"message": "Approved"}


@router.post("/admin/reject/{user_id}")
def reject_alumni(
    user_id: int,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(404, "User not found")

    user.status = "rejected"
    db.commit()

    return {"message": "Rejected"}