from datetime import datetime, timedelta
from app.models.notification_task import NotificationTask


def create_content_notifications(db, content):
    """
    Create notification tasks when content is created.
    Handles:
    - immediate notification
    - event reminder
    - internship deadline reminder
    """

    # ---------------- Immediate Notification ----------------
    # Internships go to 'students', others go to 'all_users'
    target_topic = "students" if content.type == "internship" else "all_users"

    immediate_task = NotificationTask(
        content_id=content.id,
        content_type=content.type,
        title=content.title,
        send_at=datetime.utcnow(),
        topic=target_topic
    )

    db.add(immediate_task)

    # ---------------- Event Reminder ----------------
    if content.event_date:

        reminder_time = datetime.combine(
            content.event_date,
            datetime.min.time()
        ) - timedelta(days=1)

        event_task = NotificationTask(
            content_id=content.id,
            content_type="event",
            title=content.title,
            send_at=reminder_time,
            topic="all_users"
        )

        db.add(event_task)

    # ---------------- Internship Deadline Reminder ----------------
    if content.deadline:

        reminder_time = datetime.combine(
            content.deadline,
            datetime.min.time()
        ) - timedelta(days=1)

        internship_task = NotificationTask(
            content_id=content.id,
            content_type="internship",
            title=content.title,
            send_at=reminder_time,
            topic="students"
        )

        db.add(internship_task)

    # commit handled in router