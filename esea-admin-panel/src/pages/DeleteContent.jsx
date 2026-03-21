import React, { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { fetchAdminContentById, deleteContent } from "../api/contentApi";

export default function DeleteContent() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [content, setContent] = useState(null);

  useEffect(() => {
    fetchAdminContentById(id)
      .then((res) => setContent(res.data))
      .catch(() => alert("Content not found"));
  }, [id]);
  if (!content) return <div>Loading...</div>;

  const handleDelete = async () => {
    if (!window.confirm("Are you sure you want to delete this content?")) return;
    try {
      await deleteContent(id);
      alert("Content deleted");
      navigate("/content");
    } catch (err) {
      console.error(err);
      alert("Error deleting content");
    }
  };

  return (
    <div style={{ padding: 40, maxWidth: 700 }}>
      <h2>Delete Content</h2>
      <p>Are you sure you want to delete the content titled "<strong>{content.title}</strong>"?</p>
      <button onClick={handleDelete} style={{ backgroundColor: 'red', color: 'white' }}>
        Delete
      </button>
    </div>
  );
}