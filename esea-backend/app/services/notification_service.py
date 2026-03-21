import firebase_admin
from firebase_admin import credentials, messaging
import os
import json

# Initialize Firebase only once
if not firebase_admin._apps:
    firebase_json = os.getenv("FIREBASE_CREDENTIALS")

    if not firebase_json:
        raise Exception("FIREBASE_CREDENTIALS not set")

    cred_dict = json.loads(firebase_json)

    cred = credentials.Certificate(cred_dict)
    firebase_admin.initialize_app(cred)


def send_topic_notification(title: str, body: str, topic: str, data: dict | None = None):
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
        topic=topic,
    )

    return messaging.send(message)