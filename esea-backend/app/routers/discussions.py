from sqlalchemy.orm.attributes import flag_modified
import copy

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Query,
    Form,
    File,
    UploadFile,
)
from sqlalchemy.orm import Session
from typing import Optional, List
from uuid import uuid4
from datetime import datetime, timedelta
import os
import shutil

from app.database import get_db
from app.models.discussion import Discussion
from app.models.discussion_vote import DiscussionVote
from app.models.discussion_poll_vote import DiscussionPollVote
from app.models.user import User
from app.dependencies import get_current_user

router = APIRouter(prefix="/discussions", tags=["Discussions"])

UPLOAD_DIR = "uploads/discussions"
os.makedirs(UPLOAD_DIR, exist_ok=True)


# ==========================================================
# CREATE DISCUSSION
# ==========================================================
@router.post("")
async def create_discussion(
    title: str = Form(...),
    content: str = Form(...),
    category: str = Form("general"),
    poll_options: Optional[List[str]] = Form(None),
    multiple: bool = Form(False),
    quiz_mode: bool = Form(False),
    correct_indexes: Optional[List[str]] = Form(None),
    image: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    image_url = None

    if image and image.filename:
        ext = image.filename.split(".")[-1]

        # SAFE FILE TYPE CHECK (no feature removed)
        allowed = ["jpg", "jpeg", "png", "webp"]
        if ext.lower() not in allowed:
            raise HTTPException(400, "Invalid image type")

        filename = f"{uuid4()}.{ext}"
        file_path = os.path.join(UPLOAD_DIR, filename)

        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(image.file, buffer)

        # FIXED PATH (important bug fix)
        image_url = f"/uploads/discussions/{filename}"

    poll_data = None

    # ---------------- POLL ----------------
    if poll_options and len(poll_options) >= 2:

        parsed_correct = []

        if quiz_mode and correct_indexes:
            for x in correct_indexes:
                try:
                    parsed_correct.append(int(x))
                except Exception:
                    pass

        poll_data = {
            "options": [
                {
                    "text": option,
                    "votes": 0,
                    "is_correct": (
                        quiz_mode and i in parsed_correct
                    )
                }
                for i, option in enumerate(poll_options)
            ],
            "multiple": multiple,
            "quiz_mode": quiz_mode,
            "expires_at": None
        }

    discussion = Discussion(
        title=title,
        content=content,
        author_id=current_user.id,
        category=category,
        image_url=image_url,
        poll_data=poll_data,
    )

    db.add(discussion)
    db.commit()
    db.refresh(discussion)

    return {"message": "Discussion created", "id": discussion.id}


# ==========================================================
# GET DISCUSSIONS (OPTIMIZED )
# ==========================================================
@router.get("")
def get_discussions(
    sort: str = "new",
    page: int = Query(1, ge=1),
    limit: int = Query(20, le=50),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    offset = (page - 1) * limit

    if sort == "top":
        seven_days_ago = datetime.utcnow() - timedelta(days=7)
        query = (
            db.query(Discussion)
            .filter(Discussion.created_at >= seven_days_ago)
            .order_by(Discussion.upvotes_count.desc())
        )
    else:
        query = db.query(Discussion).order_by(
            Discussion.created_at.desc()
        )

    discussions = query.offset(offset).limit(limit).all()

    # PERFORMANCE OPTIMIZATION
    discussion_ids = [d.id for d in discussions]

    vote_map = {}
    if discussion_ids:
        votes = db.query(DiscussionVote).filter(
            DiscussionVote.user_id == current_user.id,
            DiscussionVote.discussion_id.in_(discussion_ids)
        ).all()
        vote_map = {v.discussion_id: True for v in votes}

    poll_map = {}
    if discussion_ids:
        poll_votes = db.query(DiscussionPollVote).filter(
            DiscussionPollVote.user_id == current_user.id,
            DiscussionPollVote.discussion_id.in_(discussion_ids)
        ).all()
        poll_map = {v.discussion_id: v.option_indexes for v in poll_votes}

    result = []

    for d in discussions:

        voted = vote_map.get(d.id, False)
        poll_data = d.poll_data
        user_poll_vote = poll_map.get(d.id)

        # 🔥 FIXED SAFE POLL HANDLING
        if poll_data and not user_poll_vote:
            try:
                hidden_poll = copy.deepcopy(poll_data)

                # CASE 1: dict format (expected)
                if isinstance(hidden_poll, dict):
                    options = hidden_poll.get("options", [])
                else:
                    # CASE 2: list format (fallback)
                    options = hidden_poll

                for opt in options:
                    if isinstance(opt, dict):
                        opt["votes"] = 0

                poll_data = hidden_poll

            except Exception as e:
                print("Poll parsing error:", e)

        result.append({
            "id": d.id,
            "title": d.title,
            "content": d.content[:200],
            "author_name": d.author.name,
            "is_esea_member": d.author.esea_id is not None,
            "upvotes_count": d.upvotes_count,
            "comments_count": d.comments_count,
            "created_at": d.created_at,
            "voted": voted,
            "image_url": d.image_url,
            "poll_data": poll_data,
            "poll_user_voted": user_poll_vote,
        })

    return result


# ==========================================================
# POLL VOTE (FIXED SAFE QUERY)
# ==========================================================
@router.post("/{discussion_id}/poll")
def vote_poll(
    discussion_id: int,
    option_indexes: List[int] = Form(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    # FIXED (.get removed)
    discussion = db.query(Discussion).filter(
        Discussion.id == discussion_id
    ).first()

    if not discussion or not discussion.poll_data:
        raise HTTPException(status_code=404, detail="Poll not found")

    poll = discussion.poll_data

    existing = db.query(DiscussionPollVote).filter_by(
        discussion_id=discussion_id,
        user_id=current_user.id
    ).first()

    if existing:
        return {
            "poll_data": discussion.poll_data,
            "poll_user_voted": existing.option_indexes
        }

    if not poll.get("multiple", False) and len(option_indexes) > 1:
        raise HTTPException(status_code=400, detail="Multiple answers not allowed")

    updated_poll = copy.deepcopy(poll)

    for idx in option_indexes:
        if idx < 0 or idx >= len(updated_poll["options"]):
            raise HTTPException(status_code=400, detail="Invalid option index")

        updated_poll["options"][idx]["votes"] += 1

    discussion.poll_data = updated_poll
    flag_modified(discussion, "poll_data")

    vote = DiscussionPollVote(
        discussion_id=discussion_id,
        user_id=current_user.id,
        option_indexes=option_indexes
    )

    db.add(vote)
    db.commit()
    db.refresh(discussion)

    return {
        "poll_data": discussion.poll_data,
        "poll_user_voted": option_indexes
    }


# ==========================================================
# TOGGLE UPVOTE 
# ==========================================================
@router.post("/{discussion_id}/vote")
def toggle_vote(
    discussion_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    # FIXED (.get removed → main bug fix)
    discussion = db.query(Discussion).filter(
        Discussion.id == discussion_id
    ).first()

    if not discussion:
        raise HTTPException(status_code=404, detail="Discussion not found")

    existing = db.query(DiscussionVote).filter_by(
        user_id=current_user.id,
        discussion_id=discussion_id
    ).first()

    if existing:
        db.delete(existing)
        discussion.upvotes_count -= 1
        voted = False
    else:
        vote = DiscussionVote(
            user_id=current_user.id,
            discussion_id=discussion_id,
            value=1
        )
        db.add(vote)
        discussion.upvotes_count += 1
        voted = True

    db.commit()
    db.refresh(discussion)

    return {
        "voted": voted,
        "upvotes": discussion.upvotes_count
    }