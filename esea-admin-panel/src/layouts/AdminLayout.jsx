import { NavLink, Outlet, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function AdminLayout() {
  const { logout } = useAuth();
  const navigate = useNavigate();

  return (
    <div style={{ display: "flex", height: "100vh" }}>
      {/* SIDEBAR */}
      <aside
        style={{
          width: 260,
          background: "#004af5",
          color: "#fff",
          padding: 20,
        }}
      >
        <h2 style={{ marginBottom: 30 }}>ESEA Admin</h2>

        <nav style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          <NavLink to="/dashboard" style={linkStyle}>Dashboard</NavLink>
          <NavLink to="/content" style={linkStyle}>Content</NavLink>
          <NavLink to="/upload/slot-time" style={linkStyle}>Slot–Time Map</NavLink>
          <NavLink to="/upload/department-courses" style={linkStyle}>Dept Courses</NavLink>
          <NavLink to="/upload/exams" style={linkStyle}>Exam Timetable</NavLink>
          <NavLink to="/course-info" style={linkStyle}>Course Info</NavLink>
          <NavLink to="/audit" style={linkStyle}>Audit Logs</NavLink>

          <button
            onClick={() => {
              logout();
              navigate("/login");
            }}
            style={{
              marginTop: 30,
              padding: 10,
              background: "#fb0606",
              border: "none",
              color: "white",
              cursor: "pointer",
            }}
          >
            Logout
          </button>
        </nav>
      </aside>

      {/* MAIN CONTENT */}
      <main
        style={{
          flex: 1,
          padding: 24,
          background: "#242424",
          overflowY: "auto",
        }}
      >
        <Outlet /> {/* 🔥 THIS WAS MISSING */}
      </main>
    </div>
  );
}

const linkStyle = ({ isActive }) => ({
  color: isActive ? "#38bdf8" : "#e5e7eb",
  textDecoration: "none",
  fontWeight: 500,
});
