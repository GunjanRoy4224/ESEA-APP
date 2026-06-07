import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import {
  fetchAdminContentById,
  updateContent,
} from "../api/contentApi";

export default function EditContent() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [form, setForm] = useState(null);

  useEffect(() => {
    fetchAdminContentById(id)
      .then((res) => setForm(res.data))
      .catch(() => alert("Content not found"));
  }, [id]);

  if (!form) return <div>Loading...</div>;

  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    // 🔒 Required field validation
    if (!form.type || !form.title?.trim() || !form.short_description?.trim()) {
      alert("Type, Title and Short Description are required");
      return;
    }

    setLoading(true);

    // ✅ Build payload backend-safe
    const payload = {
      type: form.type,
      title: form.title.trim(),
      short_description: form.short_description.trim(),

      full_description: form.full_description || null,
      image_url: form.image_url || null,
      file_url: form.file_url || null,
      external_link: form.external_link || null,
      
      event_venue: form.event_venue|| null,
      event_date: form.event_date || null,
      event_time: form.event_time || null,

      deadline: form.deadline || null,
    };

    try {
      await updateContent(id, payload);
      alert("Content updated");
      navigate("/content");
    } catch (err) {
      console.error(err);
      alert("Error updating content");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ padding: 40, maxWidth: 700 }}>
      <h2>Edit Content</h2>

      {/* Content Type */}
      <select
        value={form.type}
        onChange={(e) =>
          setForm({ ...form, type: e.target.value })
        }
      >
        <option value="announcement">Announcement</option>
        <option value="event">Event</option>
        <option value="internship">Internship</option>
        <option value="newsletter">Newsletter</option>
        <option value="research">Research</option>
      </select>

      <br /><br />

      {/* Title */}
      <input
        placeholder="Title *"
        value={form.title || ""}
        onChange={(e) =>
          setForm({ ...form, title: e.target.value })
        }
      />

      <br /><br />

      {/* Short Description */}
      <textarea
        placeholder="Short description *"
        value={form.short_description || ""}
        onChange={(e) =>
          setForm({ ...form, short_description: e.target.value })
        }
      />

      <br /><br />

      {/* Full Description */}
      <textarea
        placeholder="Full description (optional)"
        value={form.full_description || ""}
        onChange={(e) =>
          setForm({ ...form, full_description: e.target.value })
        }
      />
      <br /><br />
      {/* event venue */}
      <textarea
        placeholder="Event Venue"
        value={form.event_venue || ""}
        onChange={(e) =>
          setForm({ ...form, event_venue: e.target.value })
        }
      />

      <br /><br />

      <h5>Event Date</h5>
      <input
        type="date"
        value={form.event_date || ""}
        onChange={(e) =>
          setForm({ ...form, event_date: e.target.value })
        }
      />

      <br /><br />

      <h5>Event Time</h5>
      <input
        type="time"
        value={form.event_time || ""}
        onChange={(e) =>
          setForm({ ...form, event_time: e.target.value })
        }
      />

      <br /><br />

      <h5>Deadline</h5>
      <input
        type="date"
        value={form.deadline || ""}
        onChange={(e) =>
          setForm({ ...form, deadline: e.target.value })
        }
      />

      <br /><br />

      <input
        placeholder="Image link (optional)"
        value={form.image_url || ""}
        onChange={(e) =>
          setForm({ ...form, image_url: e.target.value })
        }
      />

      <br /><br />

      <input
        placeholder="Google Drive file link (optional)"
        value={form.file_url || ""}
        onChange={(e) =>
          setForm({ ...form, file_url: e.target.value })
        }
      />

      <br /><br />

      <input
        placeholder="External link (optional)"
        value={form.external_link || ""}
        onChange={(e) =>
          setForm({ ...form, external_link: e.target.value })
        }
      />

      <br /><br />

      <button onClick={handleSubmit} disabled={loading}>
        {loading ? "Saving..." : "Save"}
      </button>
    </div>
  );
}

