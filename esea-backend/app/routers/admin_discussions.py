from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.discussion import Discussion, Comment
from app.models.user import User
from app.dependencies import require_admin
from app.services.audit_service import log_action

router = APIRouter(prefix="/admin/discussions", tags=["Admin Discussions"])

@router.get("/")
def get_all_discussions(
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    discussions = db.query(Discussion).order_by(Discussion.created_at.desc()).all()
    results = []
    for d in discussions:
        user = db.query(User).filter(User.id == d.author_id).first()
        results.append({
            "id": str(d.id),
            "title": d.title,
            "content": d.content,
            "author_name": user.full_name if user else "Unknown",
            "created_at": d.created_at
        })
    return results

@router.delete("/{discussion_id}")
def delete_discussion_admin(
    discussion_id: str,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    discussion = db.query(Discussion).filter(Discussion.id == discussion_id).first()
    if not discussion:
        raise HTTPException(404, "Discussion not found")
        
    db.delete(discussion)
    log_action(
        db=db,
        user=admin,
        action="Deleted discussion (moderation)",
        entity="discussion",
        entity_id=discussion_id
    )
    db.commit()
    return {"message": "Discussion deleted"}

@router.get("/{discussion_id}/comments")
def get_discussion_comments(
    discussion_id: str,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    comments = db.query(Comment).filter(Comment.discussion_id == discussion_id).order_by(Comment.created_at.desc()).all()
    results = []
    for c in comments:
        user = db.query(User).filter(User.id == c.author_id).first()
        results.append({
            "id": str(c.id),
            "content": c.content,
            "author_name": user.full_name if user else "Unknown",
            "created_at": c.created_at
        })
    return results

@router.delete("/comments/{comment_id}")
def delete_comment_admin(
    comment_id: str,
    db: Session = Depends(get_db),
    admin=Depends(require_admin),
):
    comment = db.query(Comment).filter(Comment.id == comment_id).first()
    if not comment:
        raise HTTPException(404, "Comment not found")
        
    db.delete(comment)
    log_action(
        db=db,
        user=admin,
        action="Deleted comment (moderation)",
        entity="comment",
        entity_id=comment_id
    )
    db.commit()
    return {"message": "Comment deleted"}
