import React, { useEffect, useState } from "react";
import * as XLSX from "xlsx";

function formatCellValue(header, value) {
  if (value == null) return "";

  // Only treat as time if column name suggests time
  const timeHeaders = ["time", "start", "end", "from", "to"];

  const isTimeColumn = timeHeaders.some((key) =>
    header.toLowerCase().includes(key)
  );

  if (isTimeColumn && typeof value === "number") {
    const totalMinutes = Math.round(value * 24 * 60);
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;

    return new Date(0, 0, 0, hours, minutes).toLocaleTimeString("en-IN", {
      hour: "numeric",
      minute: "2-digit",
      hour12: true,
    });
  }

  // Otherwise return as-is (number / string)
  return value;
}
export default function FilePreviewTable({ file, maxRows = 10 }) {
  const [rows, setRows] = useState([]);

  useEffect(() => {
    if (!file) return;

    const reader = new FileReader();

    reader.onload = (e) => {
      const workbook = XLSX.read(e.target.result, { type: "binary" });
      const sheet = workbook.Sheets[workbook.SheetNames[0]];
      const json = XLSX.utils.sheet_to_json(sheet);
      setRows(json.slice(0, maxRows));
    };

    reader.readAsBinaryString(file);
  }, [file, maxRows]);

  if (!file || rows.length === 0) return null;

  const headers = Object.keys(rows[0]);

  return (
    <div style={{ marginTop: 20 }}>
      <h4>Preview (first {maxRows} rows)</h4>

      <table border="1" cellPadding="6">
        <thead>
          <tr>
            {headers.map((h) => (
              <th key={h}>{h}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, i) => (
            <tr key={i}>
              {headers.map((h) => (
                <td key={h}>{formatCellValue(h, row[h])}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
