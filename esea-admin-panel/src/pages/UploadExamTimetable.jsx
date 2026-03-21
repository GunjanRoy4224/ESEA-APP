import { useState } from "react";
import { uploadExamTimetable } from "../api/exams";
import FilePreviewTable from "../components/FilePreviewTable";
import DownloadTemplate from "../components/DownloadTemplate";

export default function UploadExamTimetable() {
  const [title, setTitle] = useState("");
  const [file, setFile] = useState(null);

  const handleUpload = async () => {
    try {
      await uploadExamTimetable(title, file);
      alert("Exam timetable uploaded");
    } catch {
      alert("Upload failed");
    }
  };

  return (
    <div>
      <h3>Upload Exam Timetable</h3>
        <DownloadTemplate
            file = "/templates/exam_timetable_template.xlsx"
            label="Exam Timetable Template"
        />
    <div />
      <input
        placeholder="Title (Midsem / Endsem)"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
      />
    <div />
      <br /><br />
    <div />
      <input type="file" onChange={(e) => setFile(e.target.files[0])} />
        <FilePreviewTable file={file} />
      <button onClick={handleUpload}>Upload</button>
    </div>
  );
}
