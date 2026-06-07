from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.orm import Session
import csv
from io import TextIOWrapper

from app.database import get_db
from app.models.user import User
from app.dependencies import require_admin

router = APIRouter(
    prefix="/admin/esea-id",
    tags=["Admin ESEA ID"]
)

@router.post("/upload")
def upload_esea_id_csv(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    admin = Depends(require_admin),
):
    if file.file is None:
        raise HTTPException(400, "Invalid file")

    reader = csv.DictReader(
        TextIOWrapper(file.file, encoding="utf-8")
    )

    # ✅ FIX: None-safe fieldnames check
    required_cols = {"roll_number", "esea_id"}
    if not reader.fieldnames or not required_cols.issubset(reader.fieldnames):
        raise HTTPException(400, "Invalid CSV format")

    roll_to_esea = {}
    for row in reader:
        roll = row.get("roll_number")
        esea_id = row.get("esea_id")
        if roll and esea_id:
            roll_to_esea[roll] = str(esea_id)

    users = db.query(User).filter(User.roll_number.in_(roll_to_esea.keys())).all()

    updated = 0
    # Those not found in DB are skipped
    skipped = len(roll_to_esea) - len(users)

    for user in users:
        user.esea_id = roll_to_esea[user.roll_number]
        updated += 1

    db.commit()

    return {
        "updated": updated,
        "skipped": skipped
    }