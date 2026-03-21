from pydantic import BaseModel
from datetime import time

class SlotTimeResponse(BaseModel):
    slot_code: str
    day: str
    start_time: time
    end_time: time

    class Config:
        from_attributes = True
