import base64
import requests
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from starlette.responses import RedirectResponse

from app.database import get_db
from app.config import settings
from app.models.user import User
from app.routers.auth import create_access_token

router = APIRouter(prefix="/auth", tags=["SSO"])


# -------------------------------------------------
# SSO LOGIN URL
# -------------------------------------------------
@router.get("/sso/login")
def sso_login():
    """
    Returns Gymkhana SSO authorization URL
    """
    auth_url = (
        f"{settings.SSO_AUTH_URL}"
        f"?client_id={settings.SSO_CLIENT_ID}"
        f"&response_type=code"
        f"&scope=basic profile ldap program picture"
        f"&redirect_uri={settings.SSO_REDIRECT_URI}"
    )
    return {"url": auth_url}


# -------------------------------------------------
# CREATE OR FETCH USER FROM SSO PROFILE
# -------------------------------------------------
def get_or_create_user_from_sso(profile: dict, db: Session) -> User:
    """
    Creates or fetches a student user from IITB SSO profile
    """

    # 🔑 REQUIRED FIELD
    sso_id = str(profile["id"])

    # 1️⃣ Existing user check
    user = db.query(User).filter(User.sso_id == sso_id).first()
    if user:
        return user

    # 2️⃣ Program block (SAFE)
    program = profile.get("program") or {}

    # 3️⃣ Build full name
    first_name = profile.get("first_name", "")
    last_name = profile.get("last_name", "")
    full_name = f"{first_name} {last_name}".strip()

    # 4️⃣ Create new student user
    user = User(
        sso_id=sso_id,
        username=profile.get("username"),
        name=full_name,
        roll_number=profile.get("roll_number"),
        department=program.get("department_name") or program.get("department"),
        join_year=program.get("join_year"),
        graduation_year=program.get("graduation_year"),
        role="student",
        status="verified",  # SSO users are auto-verified
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return user


# -------------------------------------------------
# SSO CALLBACK
# -------------------------------------------------
@router.get("/sso/callback")
def sso_callback(code: str, db: Session = Depends(get_db)):
    """
    Handles IITB SSO callback:
    code -> access_token -> profile -> user -> app JWT
    """

    # 1️⃣ TOKEN EXCHANGE (Basic Auth REQUIRED by IITB)
    auth_string = f"{settings.SSO_CLIENT_ID}:{settings.SSO_CLIENT_SECRET}"
    auth_header = base64.b64encode(auth_string.encode()).decode()

    token_response = requests.post(
        settings.SSO_TOKEN_URL,
        headers={
            "Authorization": f"Basic {auth_header}",
            "Content-Type": "application/x-www-form-urlencoded",
        },
        data={
            "code": code,
            "redirect_uri": settings.SSO_REDIRECT_URI,
            "grant_type": "authorization_code",
        },
        timeout=10,
    )

    if token_response.status_code != 200:
        raise HTTPException(400, "Token exchange failed")

    access_token = token_response.json().get("access_token")
    if not access_token:
        raise HTTPException(400, "Access token missing")

    # 2️⃣ FETCH USER PROFILE (CORRECT GYMKHANA WAY)
    profile_response = requests.get(
        settings.SSO_PROFILE_URL,
        headers={
            "Authorization": f"Bearer {access_token}",
        },
        params={
            # ❗ DO NOT USE NESTED FIELD SELECTION
            "fields": (
                "id,"
                "first_name,"
                "last_name,"
                "username,"
                "roll_number,"
                "program"
            )
        },
        timeout=10,
    )

    if profile_response.status_code != 200:
        raise HTTPException(400, "Failed to fetch user profile")

    profile = profile_response.json()

    # 3️⃣ CREATE / FETCH USER
    user = get_or_create_user_from_sso(profile, db)

    # 4️⃣ ISSUE APP JWT
    jwt_token = create_access_token(
        {"sub": str(user.id), "role": "student"},
    )

    # 5️⃣ REDIRECT BACK TO FLUTTER (DEEP LINK)
    return RedirectResponse(
        url=f"esea://auth/callback?token={jwt_token}",
        status_code=307,
    )
