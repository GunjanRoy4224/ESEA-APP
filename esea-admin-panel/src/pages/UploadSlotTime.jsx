import { useState } from "react";
import { uploadSlotTime } from "../api/slotTime";
import FilePreviewTable from "../components/FilePreviewTable";
import DownloadTemplate from "../components/DownloadTemplate";

export default function UploadSlotTime() {
  const [file, setFile] = useState(null);

  const handleUpload = async () => {
    if (!file) return alert("Select file");

    try {
      await uploadSlotTime(file);
      alert("Slot–Time map uploaded");
    } catch {
      alert("Upload failed");
    }
  };

  return (
    <div>
      <h3>Upload Slot–Time Map</h3>
        <DownloadTemplate
            file = "/templates/slot_time_template.xlsx"
            label="Slot–Time Template"
        />
    <div />
      <input type="file" onChange={(e) => setFile(e.target.files[0])} />
      <FilePreviewTable file={file} />
      <button onClick={handleUpload}>Upload</button>
    </div>
  );
}
