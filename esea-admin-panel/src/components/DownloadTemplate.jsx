export default function DownloadTemplate({ file, label }) {
  return (
    <a
      href={file}
      download
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
