import api from "../api/axios";

export default function DownloadTemplate({ file, label }) {
  const handleDownload = async (e) => {
    e.preventDefault();
    try {
      const templateName = file.split('/').pop();
      const res = await api.get(`/upload/template/${templateName}`);
      if (res.data && res.data.url) {
        window.open(res.data.url, "_blank");
      }
    } catch (err) {
      alert("Failed to fetch template URL");
    }
  };

  return (
    <a
      href="#"
      onClick={handleDownload}
      style={{
        display: "inline-block",
        marginBottom: 15,
        textDecoration: "underline",
        color: "#0b5ed7",
        cursor: "pointer",
      }}
    >
      ⬇ Download {label} Template
    </a>
  );
}
