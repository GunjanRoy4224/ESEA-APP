import api from "./axios";

export const fetchCourseInfo = () =>
  api.get("/admin/course-info");

export const createCourseInfo = (payload) =>
  api.post("/admin/course-info", payload);

export const updateCourseInfo = (id, payload) =>
  api.put(`/admin/course-info/${id}`, payload);

export const deleteCourseInfo = (id) =>
  api.delete(`/admin/course-info/${id}`);
