import pytest
from unittest.mock import patch

def test_firebase_graceful_failure_no_credentials(caplog):
    # If credentials are not set, it should log a warning but not crash
    from app.config import settings
    original_creds = settings.FIREBASE_CREDENTIALS
    settings.FIREBASE_CREDENTIALS = None

    import importlib
    import app.services.notification_service as ns
    
    # Reload the module to trigger initialization logic
    importlib.reload(ns)

    assert not ns._firebase_initialized
    assert "FIREBASE_CREDENTIALS not set in config" in caplog.text

    # Restore
    settings.FIREBASE_CREDENTIALS = original_creds

def test_send_notification_bypassed_if_not_initialized(caplog):
    import app.services.notification_service as ns
    ns._firebase_initialized = False

    result = ns.send_topic_notification("Title", "Body", "topic")
    assert result is None
    assert "Notification bypassed (Firebase not initialized)" in caplog.text
