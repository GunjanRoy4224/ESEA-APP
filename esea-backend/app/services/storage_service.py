import os
import uuid
from typing import Optional
from fastapi import UploadFile, HTTPException
from supabase import create_client, Client
from app.config import settings

class StorageService:
    def __init__(self):
        url = settings.SUPABASE_URL
        key = settings.SUPABASE_SERVICE_KEY
        self.bucket_name = settings.SUPABASE_BUCKET
        
        if not url or not key or not self.bucket_name:
            raise ValueError("Supabase configuration is missing in environment variables.")
        
        self.client: Client = create_client(url, key)

    def validate_image(self, file: UploadFile) -> str:
        """Validates file size and MIME type. Returns the extension."""
        allowed_mime_types = ["image/jpeg", "image/png", "image/webp", "image/gif"]
        allowed_extensions = ["jpg", "jpeg", "png", "webp", "gif"]

        if file.content_type not in allowed_mime_types:
            raise HTTPException(400, f"Invalid file type. Allowed: {', '.join(allowed_mime_types)}")

        ext = file.filename.split(".")[-1].lower() if file.filename else ""
        if ext not in allowed_extensions:
            raise HTTPException(400, f"Invalid file extension. Allowed: {', '.join(allowed_extensions)}")
            
        # File size validation (limit to 5MB)
        file.file.seek(0, 2)  # Seek to end
        size = file.file.tell()
        file.file.seek(0)  # Reset to beginning

        if size > 5 * 1024 * 1024:
            raise HTTPException(400, "File size exceeds the 5MB limit.")

        return ext

    def upload_image(self, file: UploadFile, folder: str) -> str:
        """Uploads an image to Supabase Storage and returns the public URL."""
        ext = self.validate_image(file)
        filename = f"{folder}/{uuid.uuid4()}.{ext}"

        try:
            file_bytes = file.file.read()
            res = self.client.storage.from_(self.bucket_name).upload(
                path=filename,
                file=file_bytes,
                file_options={"content-type": file.content_type}
            )
            return self.get_public_url(filename)
        except Exception as e:
            print(f"Supabase Upload Error: {e}")
            raise HTTPException(500, "Failed to upload file to storage")

    def get_public_url(self, filepath: str) -> str:
        """Returns the public URL for a given file path."""
        return self.client.storage.from_(self.bucket_name).get_public_url(filepath)

    def delete_file(self, filepath: str) -> bool:
        """Deletes a file from Supabase Storage."""
        try:
            # Extract path from URL if a full URL is passed
            if "supabase.co" in filepath:
                # Extract the path relative to the bucket
                parts = filepath.split(f"/storage/v1/object/public/{self.bucket_name}/")
                if len(parts) > 1:
                    filepath = parts[1]
            
            res = self.client.storage.from_(self.bucket_name).remove([filepath])
            return True
        except Exception as e:
            print(f"Supabase Delete Error: {e}")
            return False

storage_service = StorageService()
