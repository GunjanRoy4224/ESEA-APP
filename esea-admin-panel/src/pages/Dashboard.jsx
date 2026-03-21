import { Link, Links } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import AdminLayout from "../layouts/AdminLayout";

export default function Dashboard() {
  const { logout } = useAuth();

  return (

    <div style={{ padding: 40 }}>
      <h1>Welcome to ESEA Admin Panel</h1>

      <ul>
        
        <li>
          <Link to="/content">View All Content</Link>
        </li>
        <li>
          <Link to="/content/create">Create Content</Link>
        </li>
        <li>
          <Link to="/upload/slot-time">Upload Slot Time</Link>
        </li>
        <li>
          <Link to="/upload/department-courses">Upload Department Courses</Link>
        </li>
        <li>
          <Link to="/upload/exams">Upload Exam Timetable</Link>
        </li>
        <li>
          <Link to="/course-info">Manage Course Info</Link>
        </li>
        <li>
          <Link to="/exams/preview">Preview Exam Timetable</Link>
        </li>
        <li>
          <Link to="/esea-id/upload">Upload ESEA IDs</Link>
        </li>
        <li>
          <Link to="/audit">View Audit Logs</Link>
        </li>

      </ul>

      <button onClick={logout}>Logout</button>
    </div>
  );
}
