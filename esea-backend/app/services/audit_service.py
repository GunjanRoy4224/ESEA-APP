from sqlalchemy.orm import Session
from app.models.audit_log import AuditLog


def log_action(db: Session, user, action: str, entity: str, entity_id=None):
    audit = AuditLog(
        user_id=user.id,
        user_email=user.email,
        action=action,
        entity=entity,
        entity_id=entity_id,
    )

    db.add(audit)
    db.commit()          
    db.refresh(audit)    
