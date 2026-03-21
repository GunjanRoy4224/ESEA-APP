import pandas as pd
from sqlalchemy.orm import Session
from app.models.slot_time import SlotTime

ALLOWED_DAYS = {"Mon", "Tue", "Wed", "Thu", "Fri"}

def replace_slot_time_map(db: Session, file_path: str):
    df = pd.read_excel(file_path)

    required_cols = {"slot_code", "day", "start_time", "end_time"}
    if not required_cols.issubset(df.columns):
        raise ValueError("Invalid slot time file format")

    # Clear old data
    db.query(SlotTime).delete()

    for _, row in df.iterrows():
        if row["day"] not in ALLOWED_DAYS:
            raise ValueError(f"Invalid day: {row['day']}")

        slot = SlotTime(
            slot_code=row["slot_code"].strip(),
            day=row["day"],
            start_time=row["start_time"],
            end_time=row["end_time"],
        )
        db.add(slot)

    db.commit()
