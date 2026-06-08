import { useState, useEffect } from "react";
import api from "../api/axios";

export default function InternshipModeration() {
  const [internships, setInternships] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchPending();
  }, []);

  const fetchPending = async () => {
    try {
      const res = await api.get("/admin/content/internships/pending");
      setInternships(res.data);
    } catch (err) {
      alert("Failed to load pending internships");
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (id) => {
    try {
      await api.post(`/admin/content/${id}/approve`);
      alert("Internship approved successfully");
      fetchPending();
    } catch (err) {
      alert("Failed to approve internship");
    }
  };

  const handleReject = async (id) => {
    if (!window.confirm("Are you sure you want to reject and delete this submission?")) return;
    try {
      await api.post(`/admin/content/${id}/reject`);
      alert("Internship rejected");
      fetchPending();
    } catch (err) {
      alert("Failed to reject internship");
    }
  };

  if (loading) return <div>Loading...</div>;

  return (
    <div style={{ padding: 20 }}>
      <h2>Internship Moderation Queue</h2>
      
      {internships.length === 0 ? (
        <p>No pending internships to review.</p>
      ) : (
        <div style={{ display: "flex", flexDirection: "column", gap: "20px" }}>
          {internships.map((item) => (
            <div key={item.id} style={{ border: "1px solid #444", padding: "15px", borderRadius: "8px", background: "#333" }}>
              <h3>{item.title}</h3>
              <p><strong>Description:</strong> {item.description}</p>
              {item.url && <p><strong>URL:</strong> <a href={item.url} target="_blank" rel="noopener noreferrer">{item.url}</a></p>}
              <p><strong>Deadline:</strong> {item.deadline ? new Date(item.deadline).toLocaleString() : "N/A"}</p>
              
              <div style={{ marginTop: "15px", display: "flex", gap: "10px" }}>
                <button 
                  onClick={() => handleApprove(item.id)}
                  style={{ background: "#28a745", color: "white", padding: "8px 16px", border: "none", borderRadius: "4px", cursor: "pointer" }}
                >
                  Approve
                </button>
                <button 
                  onClick={() => handleReject(item.id)}
                  style={{ background: "#dc3545", color: "white", padding: "8px 16px", border: "none", borderRadius: "4px", cursor: "pointer" }}
                >
                  Reject
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
