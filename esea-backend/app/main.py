from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.scheduler import start_scheduler
from app.routers.admin_content import router as admin_content 
from app.routers.audit import router as audit
from app.routers.auth import router as auth
from app.routers.public_content import router as public_content
from app.routers.admin_slot_time import router as admin_slot_time
from app.routers.admin_department_course import router as admin_department_course
from app.routers.student_courses import router as student_courses
from app.routers.timetable import router as timetable
from app.routers.admin_exam_timetable import router as admin_exam_timetable 
from app.routers.exam_timetable import router as exam_timetable
from app.routers.sso import router as sso
from app.routers.users import router as users
from app.routers.admin_course_info import router as admin_course_info
from app.routers.course_info import router as course_info
from app.routers.content import router as content_router
from app.routers.admin_esea_id import router as admin_esea_id
from app.routers.feedback import router as feedback_router
from app.routers.discussions import router as discussions
from app.routers.comments import router as comments
from app.routers.internship_submit_router import router as internship_submit_router
from app.routers.alumni import router as alumni

app = FastAPI(title="ESEA API")

# ---------------- STARTUP ----------------
@app.on_event("startup")
def startup():
    print("Starting notification scheduler...")
    start_scheduler()

    print("\n=== REGISTERED ROUTES ===")
    for route in app.routes:
        print(route.path)


# ---------------- CORS ----------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------- ROUTERS ----------------
app.include_router(admin_content, prefix="/api")
app.include_router(audit, prefix="/api")
app.include_router(auth, prefix="/api")
app.include_router(users, prefix="/api")
app.include_router(public_content, prefix="/api")
app.include_router(admin_slot_time, prefix="/api")
app.include_router(admin_department_course, prefix="/api")
app.include_router(student_courses, prefix="/api")
app.include_router(timetable, prefix="/api")
app.include_router(admin_exam_timetable, prefix="/api")
app.include_router(exam_timetable, prefix="/api")
app.include_router(sso, prefix="/api")
app.include_router(admin_course_info, prefix="/api")
app.include_router(course_info, prefix="/api")
app.include_router(content_router, prefix="/api", tags=["Content"])
app.include_router(admin_esea_id, prefix="/api")
app.include_router(feedback_router, prefix="/api")  # ✅ FIXED
app.include_router(discussions, prefix="/api")
app.include_router(comments, prefix="/api")
app.include_router(internship_submit_router, prefix="/api")
app.include_router(alumni, prefix="/api")

# ---------------- STATIC FILES ----------------
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")