from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from datetime import datetime

from app.database import get_db
from app.models.comment import Comment
from app.models.discussion import Discussion
from app.models.user import User
from app.dependencies import get_current_user

router = APIRouter(
    prefix="/comments",
    tags=["Comments"],
)


# ===============================
# Add Comment
# ===============================
@router.post("/{discussion_id}")
def add_comment(
    discussion_id: int,
    data: dict,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    discussion = db.query(Discussion).filter(
        Discussion.id == discussion_id
    ).first()

    if not discussion:
        raise HTTPException(404, "Discussion not found")

    # CONTENT VALIDATION
    content = (data.get("content") or "").strip()
    if not content:
        raise HTTPException(400, "Content required")

    parent_id = data.get("parent_id")

    # VALIDATE PARENT COMMENT
    if parent_id:
        parent = db.query(Comment).filter(
            Comment.id == parent_id,
            Comment.discussion_id == discussion_id
        ).first()

        if not parent:
            raise HTTPException(400, "Invalid parent comment")

    comment = Comment(
        discussion_id=discussion_id,
        author_id=current_user.id,
        content=content,
        parent_comment_id=parent_id,
        created_at=datetime.utcnow(),
    )

    discussion.comments_count += 1

    db.add(comment)
    db.commit()
    db.refresh(comment)

    return {
        "id": comment.id,
        "content": comment.content,
        "author_name": current_user.name,
        "is_esea_member": current_user.esea_id is not None,
        "created_at": comment.created_at,
        "is_owner": True,
        "parent_id": comment.parent_comment_id,
    }


# ===============================
# Get Comments
# ===============================
@router.get("/{discussion_id}")
def get_comments(
    discussion_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    discussion = db.query(Discussion).filter(
        Discussion.id == discussion_id
    ).first()

    if not discussion:
        raise HTTPException(404, "Discussion not found")

    # OPTIMIZED QUERY 
    comments = (
        db.query(Comment)
        .options(joinedload(Comment.author))
        .filter(Comment.discussion_id == discussion_id)
        .order_by(Comment.created_at.asc())
        .all()
    )

    result = []

    for c in comments:
        result.append({
            "id": c.id,
            "content": c.content,
            "author_name": c.author.name,
            "is_esea_member": c.author.esea_id is not None,
            "created_at": c.created_at,
            "is_owner": c.author_id == current_user.id,
            "parent_id": c.parent_comment_id,
        })

    return result


# ===============================
# Delete Comment
# ===============================
@router.delete("/{comment_id}")
def delete_comment(
    comment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    comment = db.query(Comment).filter(
        Comment.id == comment_id
    ).first()

    if not comment:
        raise HTTPException(404, "Comment not found")

    if comment.author_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not allowed",
        )

    discussion = db.query(Discussion).filter(
        Discussion.id == comment.discussion_id
    ).first()

    if discussion and discussion.comments_count > 0:
        discussion.comments_count -= 1

    db.delete(comment)
    db.commit()

    return {"deleted": True}