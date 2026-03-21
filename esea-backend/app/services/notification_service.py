import firebase_admin
from firebase_admin import credentials, messaging
import os

# Initialize Firebase only once
if not firebase_admin._apps:
    cred = credentials.Certificate(
        os.getenv("FIREBASE_CREDENTIALS_PATH", "firebase_service_account.json")
    )
    firebase_admin.initialize_app(cred)


def send_topic_notification(title: str, body: str, topic: str, data: dict | None = None):
    """
    Send push notification to a Firebase topic
    """

    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
        topic=topic,
    )

    try:
        return messaging.send(message)
    except Exception as e:
        print("❌ Notification error:", str(e))
        return None