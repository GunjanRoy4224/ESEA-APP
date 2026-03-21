# ==========================================================
# DiscussionPollVote Model (Production-Ready)
# Supports:
# - Single Answer Poll
# - Multiple Answer Poll
# - One Vote Per User
# - Fast Lookup
# ==========================================================

from sqlalchemy import (
    Column,
    Integer,
    ForeignKey,
    UniqueConstraint,
    Index,
    JSON
)
from sqlalchemy.orm import relationship
from app.database import Base


class DiscussionPollVote(Base):
    __tablename__ = "discussion_poll_votes"

    # ================= PRIMARY KEY =================
    id = Column(Integer, primary_key=True, index=True)

    # ================= RELATIONS =================
    discussion_id = Column(
        Integer,
        ForeignKey("discussions.id", ondelete="CASCADE"),
        nullable=False
    )

    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False
    )

    # ================= VOTE STORAGE =================
    """
    Stores selected option indexes.

    Single-answer poll:
        [1]

    Multiple-answer poll:
        [0, 2]

    Quiz mode:
        [2]
    """
    option_indexes = Column(JSON, nullable=False)

    # ================= CONSTRAINTS =================
    __table_args__ = (

        # 🔥 ONE VOTE PER USER PER DISCUSSION
        UniqueConstraint(
            "discussion_id",
            "user_id",
            name="uq_poll_vote_user_discussion"
        ),

        # 🔥 FAST QUERY INDEX
        Index(
            "idx_poll_vote_discussion",
            "discussion_id"
        ),
    )

    # ================= RELATIONSHIPS =================
    discussion = relationship("Discussion")
    user = relationship("User")