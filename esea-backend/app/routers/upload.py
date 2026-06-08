from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from typing import Optional
from app.services.storage_service import storage_service
from app.dependencies import get_current_user

router = APIRouter(prefix="/upload", tags=["Upload"])

ALLOWED_FOLDERS = ["discussions", "content", "internships", "profiles", "newsletters"]

@router.post("")
def upload_file(
    file: UploadFile = File(...),
    folder: str = Form("content"),
    current_user = Depends(get_current_user)
):
    """
    Uploads a file to Supabase Storage and returns the public URL.
    """
    if folder not in ALLOWED_FOLDERS:
        raise HTTPException(400, f"Invalid upload folder. Allowed: {', '.join(ALLOWED_FOLDERS)}")
        
    url = storage_service.upload_image(file, folder)
    
    return {"url": url}
    
@router.delete("")
def remove_file(
    filepath: str = Form(...),
    current_user = Depends(get_current_user)
):
    """
    Deletes a file from Supabase Storage.
    """
    # Note: A real implementation should verify ownership or admin rights here.
    success = storage_service.delete_file(filepath)
    if not success:
        raise HTTPException(400, "Failed to delete file")
    return {"success": True}

@router.get("/template/{template_name}")
def get_template_url(
    template_name: str,
):
    """
    Returns the Supabase public URL for a given template
    """
    url = storage_service.get_public_url(f"templates/{template_name}")
    return {"url": url}

