from apscheduler.schedulers.background import BackgroundScheduler
from app.database import SessionLocal
from app.services.notification_worker import process_notifications


def start_scheduler():

    scheduler = BackgroundScheduler()

    def job():

        db = SessionLocal()

        process_notifications(db)

        db.close()

    scheduler.add_job(
        job,
        "interval",
        minutes=1
    )

    scheduler.start()