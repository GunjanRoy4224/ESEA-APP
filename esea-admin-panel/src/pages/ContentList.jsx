import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import Loader from "../components/Loader";
import { fetchAdminContent } from "../api/contentApi";
export default function ContentList() {
  const [content, setContent] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAdminContent()
      .then((res) => setContent(res.data))
      .catch((err) => {
        console.error(err);
        alert("Failed to load content");
      })
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return <Loader text="Loading content..." />;
  }

  return (
    <div style={{ padding: 40 }}>
      <h2>All Published Content</h2>

      <table border="1" cellPadding="10">
        <thead>
          <tr>
            <th>Type</th>
            <th>Title</th>
            <th>Published At</th>
            <th>Action</th>
          </tr>
        </thead>

        <tbody>
          {content.map((item) => (
            <tr key={item.id}>
              <td>{item.type.toUpperCase()}</td>
              <td>{item.title}</td>
              <td>{new Date(item.published_at).toLocaleString()}</td>
              <td>
                <Link to={`/content/edit/${item.id}`}>Edit</Link>
              </td>
              <td>
                <Link to={`/content/delete/${item.id}`}>Delete</Link>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
