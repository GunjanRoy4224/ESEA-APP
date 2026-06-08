import { useState, useEffect } from "react";
import api from "../api/axios";

export default function DiscussionModeration() {
  const [discussions, setDiscussions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedDiscussion, setSelectedDiscussion] = useState(null);
  const [comments, setComments] = useState([]);
  const [loadingComments, setLoadingComments] = useState(false);

  useEffect(() => {
    fetchDiscussions();
  }, []);

  const fetchDiscussions = async () => {
    setLoading(true);
    try {
      const res = await api.get("/admin/discussions");
      setDiscussions(res.data);
    } catch (err) {
      alert("Failed to load discussions");
    } finally {
      setLoading(false);
    }
  };

  const fetchComments = async (id) => {
    setLoadingComments(true);
    try {
      const res = await api.get(`/admin/discussions/${id}/comments`);
      setComments(res.data);
    } catch (err) {
      alert("Failed to load comments");
    } finally {
      setLoadingComments(false);
    }
  };

  const handleDeleteDiscussion = async (id) => {
    if (!window.confirm("Are you sure you want to completely delete this discussion?")) return;
    try {
      await api.delete(`/admin/discussions/${id}`);
      alert("Discussion deleted");
      if (selectedDiscussion?.id === id) {
        setSelectedDiscussion(null);
        setComments([]);
      }
      fetchDiscussions();
    } catch (err) {
      alert("Failed to delete discussion");
    }
  };

  const handleDeleteComment = async (id) => {
    if (!window.confirm("Are you sure you want to delete this comment?")) return;
    try {
      await api.delete(`/admin/discussions/comments/${id}`);
      alert("Comment deleted");
      fetchComments(selectedDiscussion.id);
    } catch (err) {
      alert("Failed to delete comment");
    }
  };

  return (
    <div style={{ padding: 20, display: "flex", gap: "20px", height: "calc(100vh - 40px)" }}>
      {/* Left panel: Discussions */}
      <div style={{ flex: 1, overflowY: "auto", borderRight: "1px solid #444", paddingRight: "20px" }}>
        <h2>Discussions Moderation</h2>
        {loading ? (
          <div>Loading...</div>
        ) : discussions.length === 0 ? (
          <p>No discussions found.</p>
        ) : (
          <div style={{ display: "flex", flexDirection: "column", gap: "15px" }}>
            {discussions.map((d) => (
              <div 
                key={d.id} 
                style={{ 
                  border: selectedDiscussion?.id === d.id ? "2px solid #004af5" : "1px solid #444", 
                  padding: "15px", 
                  borderRadius: "8px", 
                  background: "#333",
                  cursor: "pointer"
                }}
                onClick={() => {
                  setSelectedDiscussion(d);
                  fetchComments(d.id);
                }}
              >
                <h4>{d.title}</h4>
                <p style={{ fontSize: "14px", color: "#ccc" }}>By: {d.author_name} | {new Date(d.created_at).toLocaleString()}</p>
                <p style={{ fontSize: "14px", whiteSpace: "pre-wrap", maxHeight: "100px", overflow: "hidden" }}>{d.content}</p>
                
                <div style={{ marginTop: "10px" }}>
                  <button 
                    onClick={(e) => { e.stopPropagation(); handleDeleteDiscussion(d.id); }}
                    style={{ background: "#dc3545", color: "white", padding: "6px 12px", border: "none", borderRadius: "4px", cursor: "pointer" }}
                  >
                    Delete Post
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Right panel: Comments */}
      <div style={{ flex: 1, overflowY: "auto" }}>
        <h2>Comments</h2>
        {!selectedDiscussion ? (
          <p>Select a discussion to view comments.</p>
        ) : loadingComments ? (
          <div>Loading comments...</div>
        ) : comments.length === 0 ? (
          <p>No comments on this discussion.</p>
        ) : (
          <div style={{ display: "flex", flexDirection: "column", gap: "10px" }}>
            {comments.map((c) => (
              <div key={c.id} style={{ border: "1px solid #444", padding: "10px", borderRadius: "8px", background: "#2a2a2a" }}>
                <p style={{ fontSize: "12px", color: "#aaa", marginBottom: "5px" }}>By: {c.author_name} | {new Date(c.created_at).toLocaleString()}</p>
                <p style={{ fontSize: "14px", whiteSpace: "pre-wrap" }}>{c.content}</p>
                <button 
                  onClick={() => handleDeleteComment(c.id)}
                  style={{ marginTop: "8px", background: "#dc3545", color: "white", padding: "4px 8px", border: "none", borderRadius: "4px", cursor: "pointer", fontSize: "12px" }}
                >
                  Delete Comment
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
