import api from "../api/axios";

export const uploadSlotTime = async (file) => {
  const formData = new FormData();
  formData.append("file", file);

  return api.post("/admin/slot-time/upload", formData);
};
