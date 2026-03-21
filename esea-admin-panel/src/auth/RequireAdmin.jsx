import { Navigate, Outlet } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function RequireAdmin() {
  const { user, loading } = useAuth();

  // While auth state is loading (page refresh, token restore)
  if (loading) {
    return (
      <div style={{ padding: 40, textAlign: "center" }}>
        <h3>Loading...</h3>
      </div>
    );
  }

  // Not logged in → redirect to login
  if (!user) {
    return <Navigate to="/login" replace />;
  }

  // Logged in but not admin → block access
  if (user.role !== "admin") {
    return (
      <div style={{ padding: 40 }}>
        <h2>Access Denied</h2>
        <p>You are not authorized to access the admin panel.</p>
      </div>
    );
  }

  // ✅ Admin authenticated → allow nested routes
  return <Outlet />;
}
