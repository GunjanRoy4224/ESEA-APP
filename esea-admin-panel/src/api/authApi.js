import api from "./axios";

export async function adminLogin(email, password) {
  const response = await api.post("/auth/admin/login", {
    email: email,
    password: password,
  });

  return response.data;
}
