import { useState } from "react";
import { uploadEseaIdCsv } from "../api/eseaIdApi"

export default function UploadEseaId() {
  const [file, setFile] = useState(null);
  const [msg, setMsg] = useState("");

  const handleUpload = async () => {
    if (!file) return;

    try {
      const res = await uploadEseaIdCsv(file);
      setMsg(
        `Updated: ${res.data.updated}, Skipped: ${res.data.skipped}`
      );
    } catch (e) {
      setMsg("Upload failed");
    }
  };

  return (
    <div>
      <h2>Upload ESEA ID CSV</h2>

      <input
        type="file"
        accept=".csv"
        onChange={(e) => setFile(e.target.files[0])}
      />

      <button onClick={handleUpload}>
        Upload
      </button>

      {msg && <p>{msg}</p>}
    </div>
  );
}

