import firebase_admin
from firebase_admin import credentials, messaging
import os
import json
import logging
from app.config import settings

logger = logging.getLogger(__name__)

_firebase_initialized = False

# Initialize Firebase only once
if not firebase_admin._apps:
    firebase_cred_source = settings.FIREBASE_CREDENTIALS

    if not firebase_cred_source:
        logger.warning("FIREBASE_CREDENTIALS not set in config. Notifications are disabled.")
    else:
        try:
            # Check if it's a JSON string
            if firebase_cred_source.strip().startswith("{"):
                cred_dict = json.loads(firebase_cred_source)
                cred = credentials.Certificate(cred_dict)
            else:
                # Assume it's a file path
                if not os.path.exists(firebase_cred_source):
                    raise FileNotFoundError(f"Firebase credentials file not found: {firebase_cred_source}")
                cred = credentials.Certificate(firebase_cred_source)
                
            firebase_admin.initialize_app(cred)
            _firebase_initialized = True
            logger.info("Firebase Admin initialized successfully.")
        except Exception as e:
            logger.error(f"Failed to initialize Firebase Admin SDK: {e}")


def send_topic_notification(title: str, body: str, topic: str, data: dict | None = None):
    if not _firebase_initialized:
        logger.warning(f"Notification bypassed (Firebase not initialized). Topic: {topic}, Title: {title}")
        return None

    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=data or {},
            topic=topic,
        )
        return messaging.send(message)
    except Exception as e:
        logger.error(f"Error sending Firebase notification to topic {topic}: {e}")
        return None