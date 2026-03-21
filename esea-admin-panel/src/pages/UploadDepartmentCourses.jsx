import { useState } from "react";
import { uploadDepartmentCourses } from "../api/departmentCourses";
import FilePreviewTable from "../components/FilePreviewTable";
import DownloadTemplate from "../components/DownloadTemplate";

export default function UploadDepartmentCourses() {
  const [file, setFile] = useState(null);

  const handleUpload = async () => {
    try {
      await uploadDepartmentCourses(file);
      alert("Department courses uploaded");
    } catch {
      alert("Upload failed");
    }
  };

  return (
    <div>
      <h3>Upload Department Courses</h3>
        <DownloadTemplate
            file = "/templates/department_courses_template.xlsx"
            label="Department Courses Template"
        />
    <div />
      <input type="file" onChange={(e) => setFile(e.target.files[0])} />
      <FilePreviewTable file={file} />
      <button onClick={handleUpload}>Upload</button>
    </div>
  );
}
