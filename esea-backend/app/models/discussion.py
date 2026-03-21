# ==========================================================
# Discussion Model (Production-Ready Poll System)
# Supports:
# - Anonymous Poll
# - Multiple Answer Poll
# - Quiz Mode
# - Future Expiry Support
# ==========================================================

from sqlalchemy import (
    Column,
    Integer,
    String,
    Text,
    ForeignKey,
    DateTime,
    Boolean,
    JSON
)
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


class Discussion(Base):
    __tablename__ = "discussions"

    # ================= BASIC FIELDS =================

    id = Column(Integer, primary_key=True, index=True)

    title = Column(String, nullable=False)
    content = Column(Text, nullable=False)

    author_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False
    )

    category = Column(String, default="general")

    upvotes_count = Column(Integer, default=0)
    comments_count = Column(Integer, default=0)

    is_pinned = Column(Boolean, default=False)
    is_locked = Column(Boolean, default=False)

    created_at = Column(
        DateTime,
        default=datetime.utcnow
    )

    updated_at = Column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow
    )

    # ================= RELATIONSHIPS =================

    author = relationship("User")
    comments = relationship(
        "Comment",
        back_populates="discussion"
    )

    # ================= MEDIA =================

    image_url = Column(String, nullable=True)

    # ================= POLL SYSTEM =================
    """
    poll_data structure:

    {
        "options": [
            {
                "text": "Option A",
                "votes": 0,
                "is_correct": False
            }
        ],
        "anonymous": False,
        "multiple": False,
        "quiz_mode": False,
        "expires_at": null
    }
    """

    poll_data = Column(JSON, nullable=True)