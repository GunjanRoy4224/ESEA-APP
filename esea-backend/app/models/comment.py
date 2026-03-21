from sqlalchemy import Column, Integer, Text, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True, index=True)

    discussion_id = Column(Integer, ForeignKey("discussions.id"), nullable=False)
    author_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    content = Column(Text, nullable=False)

    parent_comment_id = Column(Integer, nullable=True)

    upvotes_count = Column(Integer, default=0)

    created_at = Column(DateTime, default=datetime.utcnow)

    discussion = relationship("Discussion", back_populates="comments")
    author = relationship("User")
