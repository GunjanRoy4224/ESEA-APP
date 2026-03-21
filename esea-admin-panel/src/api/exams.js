import api from "../api/axios";

export const uploadExamTimetable = async (title, file) => {
  const formData = new FormData();
  formData.append("title", title);
  formData.append("file", file);

  return api.post("/admin/exams/upload", formData);
};
