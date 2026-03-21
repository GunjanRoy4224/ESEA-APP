import api from "../api/axios";

export const uploadDepartmentCourses = async (file) => {
  const formData = new FormData();
  formData.append("file", file);
  return api.post("/admin/department-courses/upload", formData);
};
