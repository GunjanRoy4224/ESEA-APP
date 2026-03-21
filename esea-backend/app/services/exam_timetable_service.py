import pandas as pd
from sqlalchemy.orm import Session
from app.models.exam_timetable import ExamTimetable

REQUIRED_COLUMNS = {
    "date",
    "day",
    "time",
    "slot",
    "course",
    "enrolment",
    "instructor",
    "venue",
}

def replace_exam_timetable(db: Session, title: str, file_path: str):
    df = pd.read_excel(file_path)

    if not REQUIRED_COLUMNS.issubset(df.columns):
        raise ValueError("Invalid exam timetable format")

    db.query(ExamTimetable).delete()

    for _, row in df.iterrows():

        # ✅ time: always store as string (time range)
        time_value = str(row["time"]).strip()

        # ✅ enrolment: must be int or None
        enrolment_value = row.get("enrolment")
        if pd.isna(enrolment_value):
            enrolment_value = None
        else:
            try:
                enrolment_value = int(enrolment_value)
            except ValueError:
                raise ValueError(f"Invalid enrolment value: {enrolment_value}")

        exam = ExamTimetable(
            title=title,
            date=row["date"],
            day=str(row["day"]).strip(),
            time=time_value,
            slot=str(row.get("slot")).strip() if not pd.isna(row.get("slot")) else None,
            course=str(row["course"]).strip(),
            enrolment=enrolment_value,
            instructor=str(row.get("instructor")).strip() if not pd.isna(row.get("instructor")) else None,
            venue=str(row.get("venue")).strip() if not pd.isna(row.get("venue")) else None,
        )

        db.add(exam)

    db.commit()
