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

    updated = 0
    skipped = 0

    for row in reader:
        roll = row.get("roll_number")
        esea_id = row.get("esea_id")

        if not roll or not esea_id:
            skipped += 1
            continue

        user = db.query(User).filter(
            User.roll_number == roll
        ).first()

        if not user:
            skipped += 1
            continue

        # ✅ FIX: safe assignment
        user.esea_id = str(esea_id)
        updated += 1

    db.commit()

    return {
        "updated": updated,
        "skipped": skipped
    }