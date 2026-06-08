import os
import sys
import asyncio
from app.services.storage_service import storage_service

BASE_DIR = r"C:\Users\gunjan\Desktop\App-dev\ESEA APP\esea-admin-panel\public\templates"

templates = [
    "department_courses_template.xlsx",
    "exam_timetable_template.xlsx",
    "slot_time_template.xlsx"
]

for t in templates:
    path = os.path.join(BASE_DIR, t)
    if not os.path.exists(path):
        print(f"Missing {path}")
        continue
        
    with open(path, "rb") as f:
        file_bytes = f.read()
        
    # We will upload to a folder called "templates"
    filename = f"templates/{t}"
    
    try:
        # Use underlying supabase client
        res = storage_service.client.storage.from_(storage_service.bucket_name).upload(
            path=filename,
            file=file_bytes,
            file_options={"content-type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "upsert": "true"}
        )
        url = storage_service.get_public_url(filename)
        print(f"Uploaded {t} -> {url}")
    except Exception as e:
        print(f"Failed to upload {t}: {e}")
