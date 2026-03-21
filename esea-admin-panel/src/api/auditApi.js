import api from "../api/axios";

export function fetchAuditLogs() {
  return api.get("/admin/audit");
}
