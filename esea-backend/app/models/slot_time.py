from sqlalchemy import Column, String, Time
from app.database import Base

class SlotTime(Base):
    __tablename__ = "slot_time_map"

    slot_code = Column(String, primary_key=True, index=True)
    day = Column(String, nullable=False)          # Mon, Tue, Wed...
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)
