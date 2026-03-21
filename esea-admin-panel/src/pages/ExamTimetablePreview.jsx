import { useEffect, useState } from "react";
import api from "../api/axios";

export default function ExamTimetablePreview() {
  const [data, setData] = useState(null);

  useEffect(() => {
    api.get("timetable/exams")
      .then((res) => setData(res.data))
      .catch(() => setData(null));
  }, []);

  if (!data || data.message) {
    return (
      <div style={{ padding: 40 }}>
        <h3>Exam Timetable</h3>
        <p>Not announced yet</p>
      </div>
    );
  }

  const headers = Object.keys(data.rows[0]);

  return (
    <div style={{ padding: 40 }}>
      <h3>{data.title} Exam Timetable</h3>

      <table border="1" cellPadding="6">
        <thead>
          <tr>
            {headers.map((h) => (
              <th key={h}>{h}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.rows.map((row, i) => (
            <tr key={i}>
              {headers.map((h) => (
                <td key={h}>{row[h]}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
