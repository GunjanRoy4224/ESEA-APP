from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
import os

# ---------------- LOAD ENV ----------------
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError("DATABASE_URL is not set")

# ---------------- ENGINE ----------------
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,       # voids stale connections (important for Neon)
    pool_recycle=300,         # refresh connections every 5 min
    pool_size=5,              # base connections
    max_overflow=10,          # extra burst connections
    connect_args={"connect_timeout": 10},  # prevents hanging
    future=True,              # SQLAlchemy 2.0
)

# ---------------- SESSION ----------------
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

# ---------------- BASE ----------------
Base = declarative_base()

# ---------------- DEPENDENCY ----------------
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()