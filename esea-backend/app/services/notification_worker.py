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

        send_topic_notification(
            title="ESEA Update",
            body=task.title,
            topic=task.topic
        )

        task.sent = True

    db.commit()