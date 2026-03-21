from fastapi import APIRouter, Depends
from app.models.user import User
from app.routers.auth import get_current_user
from app.utils.academic import compute_year

router = APIRouter(tags=["User"])

@router.get("/users/me")
def read_me(current_user: User = Depends(get_current_user)):

    # ================= SAFE NAME =================
    name = (
        current_user.name
        or f"{current_user.first_name or ''} {current_user.last_name or ''}".strip()
    )

    # ================= SAFE ROLE =================
    role = (current_user.role or "student").strip().lower()

    return {
        "id": current_user.id,
        "name": name,

        # ================= STUDENT / ALUMNI =================
        "roll_number": current_user.roll_number,
        "alumni_id": current_user.alumni_id,

        # ================= COMMON =================
        "esea_id": current_user.esea_id,
        "department": current_user.department,

        # FIXED: year only for students
        "year": compute_year(int(current_user.join_year))
            if current_user.join_year and role != "alumni"
            else None,

        "graduation_year": current_user.graduation_year,

        # ================= CRITICAL =================
        "role": role,  # 🔥 FIXED (no null now)
        "status": current_user.status or "pending",

        # ================= OPTIONAL =================
        "photo_url": current_user.photo_url,
    }