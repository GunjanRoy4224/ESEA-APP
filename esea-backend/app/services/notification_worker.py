from datetime import datetime
from app.models.notification_task import NotificationTask
from app.services.notification_service import send_topic_notification


def process_notifications(db):

    tasks = (
        db.query(NotificationTask)
        .filter(NotificationTask.sent.is_(False))
        .filter(NotificationTask.send_at <= datetime.utcnow())
        .all()
    )

    for task in tasks:
        try:
            send_topic_notification(
                title="ESEA Update",
                body=task.title,
                topic=task.topic
            )
        except Exception as e:
            print(f"Failed to send notification task {task.id}: {e}")
        finally:
            # Mark as sent so it doesn't block the queue forever
            task.sent = True

    db.commit()