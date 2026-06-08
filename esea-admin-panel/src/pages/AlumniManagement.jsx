import { useState, useEffect } from "react";
import api from "../api/axios";

export default function AlumniManagement() {
  const [alumni, setAlumni] = useState([]);
  const [loading, setLoading] = useState(true);
  const [statusTab, setStatusTab] = useState("pending");

  useEffect(() => {
    fetchAlumni();
  }, [statusTab]);

  const fetchAlumni = async () => {
    setLoading(true);
    try {
      const res = await api.get(`/admin/alumni?status=${statusTab}`);
      setAlumni(res.data);
    } catch (err) {
      alert("Failed to load alumni");
    } finally {
      setLoading(false);
    }
  };

  const handleAction = async (id, action) => {
    let confirmMsg = `Are you sure you want to ${action} this alumni?`;
    if (!window.confirm(confirmMsg)) return;

    try {
      await api.post(`/admin/alumni/${id}/${action}`);
      alert(`Alumni successfully ${action}d`);
      fetchAlumni();
    } catch (err) {
      alert(`Failed to ${action} alumni`);
    }
  };

  return (
    <div style={{ padding: 20 }}>
      <h2>Alumni Verification Management</h2>
      
      <div style={{ display: "flex", gap: "10px", marginBottom: "20px" }}>
        <button 
          onClick={() => setStatusTab("pending")} 
          style={{ padding: "8px 16px", background: statusTab === "pending" ? "#004af5" : "#444", color: "white", border: "none", cursor: "pointer" }}
        >
          Pending
        </button>
        <button 
          onClick={() => setStatusTab("approved")} 
          style={{ padding: "8px 16px", background: statusTab === "approved" ? "#004af5" : "#444", color: "white", border: "none", cursor: "pointer" }}
        >
          Approved
        </button>
        <button 
          onClick={() => setStatusTab("rejected")} 
          style={{ padding: "8px 16px", background: statusTab === "rejected" ? "#004af5" : "#444", color: "white", border: "none", cursor: "pointer" }}
        >
          Rejected
        </button>
      </div>

      {loading ? (
        <div>Loading...</div>
      ) : alumni.length === 0 ? (
        <p>No alumni found for this status.</p>
      ) : (
        <table border="1" cellPadding="10" style={{ width: "100%", borderCollapse: "collapse", background: "#333", color: "white" }}>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Email</th>
              <th>Roll Number</th>
              <th>Dept / Year</th>
              <th>Verification Method</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {alumni.map((user) => (
              <tr key={user.id}>
                <td>{user.id}</td>
                <td>{user.name || user.first_name + " " + user.last_name}</td>
                <td>{user.email}</td>
                <td>{user.roll_number}</td>
                <td>{user.department} ({user.join_year} - {user.graduation_year})</td>
                <td>{user.verification_method || "N/A"}</td>
                <td>
                  <div style={{ display: "flex", gap: "8px" }}>
                    {statusTab === "pending" && (
                      <>
                        <button onClick={() => handleAction(user.id, "approve")} style={{ background: "#28a745", color: "white", border: "none", padding: "4px 8px", cursor: "pointer" }}>Approve</button>
                        <button onClick={() => handleAction(user.id, "reject")} style={{ background: "#dc3545", color: "white", border: "none", padding: "4px 8px", cursor: "pointer" }}>Reject</button>
                      </>
                    )}
                    {statusTab === "approved" && (
                      <button onClick={() => handleAction(user.id, "revoke")} style={{ background: "#ffc107", color: "black", border: "none", padding: "4px 8px", cursor: "pointer" }}>Revoke Access</button>
                    )}
                    {statusTab === "rejected" && (
                      <button onClick={() => handleAction(user.id, "approve")} style={{ background: "#28a745", color: "white", border: "none", padding: "4px 8px", cursor: "pointer" }}>Re-Approve</button>
                    )}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}
