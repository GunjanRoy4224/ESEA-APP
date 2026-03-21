import axios from "./axios";

export const uploadEseaIdCsv = (file) => {
  const formData = new FormData();
  formData.append("file", file);

  return axios.post(
    "/admin/esea-id/upload",
    formData,
    {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    }
  );
};
