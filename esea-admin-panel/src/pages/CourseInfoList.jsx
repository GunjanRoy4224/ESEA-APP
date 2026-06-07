import { useEffect, useState } from "react";
import {
  fetchCourseInfo,
  deleteCourseInfo,
} from "../api/courseInfoApi";
import { Link } from "react-router-dom";

export default function CourseInfoList() {
  const [items, setItems] = useState([]);

  const load = async () => {
    try {
      const res = await fetchCourseInfo();
      setItems(res.data);
    } catch (err) {
      console.error(err);
      alert("Failed to load course info");
    }
  };

  useEffect(() => {
    load();
  }, []);

  const handleDelete = async (id) => {
    if (!window.confirm("Delete this course info?")) return;
    try {
      await deleteCourseInfo(id);
      load();
    } catch (err) {
      console.error(err);
      alert("Failed to delete course info");
    }
  };

  return (
    <div>
      <h2>Course Info</h2>

      <Link to="/course-info/create">
        <button>Add Course Info</button>
      </Link>

      <table border="1" cellPadding="8" style={{ marginTop: 20 }}>
        <thead>
          <tr>
            <th>Course Code</th>
            <th>Title</th>
            <th>Instructor</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {items.map((m) => (
            <tr key={m.id}>
              <td>{m.course_code}</td>
              <td>{m.course_title}</td>
              <td>{m.instructor || "-"}</td>
              <td>
                <Link to={`/course-info/edit/${m.id}`}>
                  <button>Edit</button>
                </Link>
                <button onClick={() => handleDelete(m.id)}>
                  Delete
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
