from app.config import settings
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# ---------------- ENGINE ----------------
DATABASE_URL = settings.DATABASE_URL
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