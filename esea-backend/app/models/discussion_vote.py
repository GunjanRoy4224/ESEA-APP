from sqlalchemy import Column, Integer, ForeignKey, UniqueConstraint
from app.database import Base

class DiscussionVote(Base):
    __tablename__ = "discussion_votes"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    discussion_id = Column(Integer, ForeignKey("discussions.id"), nullable=False)
    value = Column(Integer, nullable=False)  # 1 only for now

    __table_args__ = (
        UniqueConstraint("user_id", "discussion_id", name="uq_user_discussion_vote"),
    )
