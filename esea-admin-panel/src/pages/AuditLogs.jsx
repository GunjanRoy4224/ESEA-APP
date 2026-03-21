import { useEffect, useState } from "react";
import { fetchAuditLogs } from "../api/auditApi";
import Loader from "../components/Loader";

export default function AuditLogs() {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAuditLogs()
      .then((res) => setLogs(res.data))
      .catch((err) => {
        console.error(err);
        alert("Failed to load audit logs");
      })
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return <Loader text="Loading audit logs..." />;
  }

  return (
    <div style={{ padding: 40 }}>
      <h2>Audit Logs (Last 100)</h2>

      <table border="1" cellPadding="8">
        <thead>
          <tr>
            <th>Time</th>
            <th>User</th>
            <th>Action</th>
            <th>Entity</th>
            <th>ID</th>
          </tr>
        </thead>

        <tbody>
          {logs.map((log) => (
            <tr key={log.id}>
              <td>{new Date(log.timestamp + "Z").toLocaleString("en-IN", {
                    timeZone: "Asia/Kolkata",
                    hour12: true,
                  })}
              </td>
              <td>{log.user_email}</td>
              <td>{log.action}</td>
              <td>{log.entity}</td>
              <td>{log.entity_id || "-"}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
