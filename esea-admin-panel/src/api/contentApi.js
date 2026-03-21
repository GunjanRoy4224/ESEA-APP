import api from "./axios";

// ADMIN APIs
export function fetchAdminContent() {
  return api.get("/admin/content");
}

export function fetchAdminContentById(id) {
  return api.get(`/admin/content/${id}`);
}

export function createContent(payload) {
  return api.post("/admin/content", payload);
}

export function updateContent(id, payload) {
  return api.put(`/admin/content/${id}`, payload);
}

export function deleteContent(id) {
  return api.delete(`/admin/content/${id}`);
}
