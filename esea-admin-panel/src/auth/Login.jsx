import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { adminLogin } from "../api/authApi";
import { useAuth } from "../context/AuthContext";

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const navigate = useNavigate();
  const { login } = useAuth();

  const handleLogin = async () => {
    try {
      const res = await adminLogin(email, password);
      login(res.access_token, res.role);
      navigate("/dashboard");
    } catch (err) {
      console.error(err.response?.data || err);
      alert("Invalid admin credentials");
    }
  };

  return (
    <div style={{ padding: 40 }}>
      <h2>ESEA Admin Login</h2>

      <input
        type="email"
        placeholder="Admin Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />

      <br /><br />

      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />

      <br /><br />

      <button onClick={handleLogin}>Login</button>
    </div>
  );
}
