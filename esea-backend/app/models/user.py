from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)

    # -------------------------------------------------
    # Identity
    # -------------------------------------------------
    sso_id = Column(String(255), unique=True, index=True, nullable=True)
    username = Column(String(255), unique=True, index=True, nullable=True)
    email = Column(String(255), unique=True, index=True, nullable=True)

    # -------------------------------------------------
    # Personal
    # -------------------------------------------------
    first_name = Column(String(100), nullable=True)
    last_name = Column(String(100), nullable=True)
    name = Column(String(255), nullable=True)  
    photo_url = Column(String, nullable=True)
    roll_number = Column(String(100), index=True, nullable=True)
    department = Column(String(255), nullable=True)

    # -------------------------------------------------
    # ESEA
    # -------------------------------------------------
    esea_id = Column(String(100), unique=True, index=True, nullable=True)

    # -------------------------------------------------
    # Academic
    # -------------------------------------------------
    join_year = Column(Integer, nullable=True)
    graduation_year = Column(Integer, nullable=True)
    program = Column(String(50), nullable=True) # B.Tech, M.Tech, PhD, Dual Degree
    minor = Column(String(100), nullable=True)
    research_project = Column(String(255), nullable=True)

    # -------------------------------------------------
    # Auth
    # -------------------------------------------------
    role = Column(String(50), default="student", index=True)  
    hashed_password = Column(String(255), nullable=True)

    # -------------------------------------------------
    # Alumni System
    # -------------------------------------------------
    alumni_id = Column(String(100), unique=True, index=True, nullable=True)
    status = Column(String(50), default="pending", index=True) 
    verification_method = Column(String(50), nullable=True)

    # -------------------------------------------------
    # Meta
    # -------------------------------------------------
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())