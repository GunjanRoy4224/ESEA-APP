from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class DiscussionCreate(BaseModel):
    title: str
    content: str
    category: Optional[str] = "general"


class DiscussionResponse(BaseModel):
    id: int
    title: str
    content: str
    author_name: str
    is_esea_member: bool
    upvotes_count: int
    comments_count: int
    created_at: datetime

    class Config:
        from_attributes = True
