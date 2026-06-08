import { useState, useEffect } from "react";
import api from "../api/axios";

export default function FeedbackList() {
  const [feedbacks, setFeedbacks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [categoryFilter, setCategoryFilter] = useState("all");

  useEffect(() => {
    fetchFeedbacks();
  }, []);

  const fetchFeedbacks = async () => {
    try {
      const res = await api.get("/feedback/admin");
      setFeedbacks(res.data);
    } catch (err) {
      alert("Failed to load feedbacks");
    } finally {
      setLoading(false);
    }
  };

  const handleExport = async () => {
    try {
      const res = await api.get("/feedback/admin/export", {
        responseType: "blob",
      });
      const url = window.URL.createObjectURL(new Blob([res.data]));
      const link = document.createElement("a");
      link.href = url;
      link.setAttribute("download", "feedbacks_export.csv");
      document.body.appendChild(link);
      link.click();
      link.parentNode.removeChild(link);
    } catch (err) {
      alert("Failed to export feedback");
    }
  };

  const filteredFeedbacks = feedbacks.filter((f) => {
    const matchesSearch =
      f.message.toLowerCase().includes(search.toLowerCase()) ||
      f.user_name.toLowerCase().includes(search.toLowerCase()) ||
      f.user_email.toLowerCase().includes(search.toLowerCase());
    
    const matchesStatus = statusFilter === "all" || f.status === statusFilter;
    const matchesCategory = categoryFilter === "all" || f.category === categoryFilter;

    return matchesSearch && matchesStatus && matchesCategory;
  });

  if (loading) return <div>Loading...</div>;

  return (
    <div style={{ padding: 20 }}>
      <h2>Feedback Management</h2>
      
      <div style={{ display: "flex", gap: "10px", marginBottom: "20px" }}>
        <input
          type="text"
          placeholder="Search by name, email or message..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          style={{ padding: "8px", width: "300px" }}
        />
        
        <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} style={{ padding: "8px" }}>
          <option value="all">All Statuses</option>
          <option value="pending">Pending</option>
          <option value="reviewed">Reviewed</option>
          <option value="resolved">Resolved</option>
        </select>

        <select value={categoryFilter} onChange={(e) => setCategoryFilter(e.target.value)} style={{ padding: "8px" }}>
          <option value="all">All Categories</option>
          <option value="general">General</option>
          <option value="bug">Bug</option>
          <option value="feature">Feature Request</option>
        </select>
        
        <button onClick={handleExport} style={{ marginLeft: "auto", padding: "8px 16px", backgroundColor: "#28a745", color: "white", border: "none", cursor: "pointer" }}>
          Export CSV
        </button>
      </div>

      <table border="1" cellPadding="10" style={{ width: "100%", borderCollapse: "collapse" }}>
        <thead>
          <tr>
            <th>Date</th>
            <th>User</th>
            <th>Email</th>
            <th>Category</th>
            <th>Message</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          {filteredFeedbacks.length === 0 ? (
            <tr>
              <td colSpan="6" style={{ textAlign: "center" }}>No feedbacks found</td>
            </tr>
          ) : (
            filteredFeedbacks.map((f) => (
              <tr key={f.id}>
                <td>{new Date(f.created_at).toLocaleString()}</td>
                <td>{f.user_name}</td>
                <td>{f.user_email}</td>
                <td>{f.category}</td>
                <td style={{ maxWidth: "300px", wordWrap: "break-word" }}>{f.message}</td>
                <td>
                  <span style={{ 
                    padding: "4px 8px", 
                    borderRadius: "4px",
                    backgroundColor: f.status === "pending" ? "#fff3cd" : f.status === "resolved" ? "#d4edda" : "#e2e3e5"
                  }}>
                    {f.status}
                  </span>
                </td>
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}
