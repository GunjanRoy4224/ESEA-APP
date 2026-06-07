import { useState } from "react";

export default function CourseInfoForm({ initial, onSubmit }) {
  const [form, setForm] = useState(
    initial || {
      course_code: "",
      course_title: "",
      instructor: "",
      info: {
        syllabus: [],
        resources: [],
        pyqs: [],
      },
    }
  );

  const addItem = (key) => {
    setForm({
      ...form,
      info: {
        ...form.info,
        [key]: [...form.info[key], { title: "", link: "" }],
      },
    });
  };

  const updateItem = (key, idx, field, value) => {
    const list = [...form.info[key]];
    list[idx][field] = value;

    setForm({
      ...form,
      info: { ...form.info, [key]: list },
    });
  };

  const removeItem = (key, idx) => {
    const list = form.info[key].filter((_, i) => i !== idx);
    setForm({
      ...form,
      info: { ...form.info, [key]: list },
    });
  };

  return (
    <div>
      <input
        placeholder="Course Code"
        value={form.course_code}
        onChange={(e) =>
          setForm({ ...form, course_code: e.target.value })
        }
      />

      <input
        placeholder="Course Title"
        value={form.course_title}
        onChange={(e) =>
          setForm({ ...form, course_title: e.target.value })
        }
      />

      <input
        placeholder="Instructor"
        value={form.instructor}
        onChange={(e) =>
          setForm({ ...form, instructor: e.target.value })
        }
      />

      {["syllabus", "resources", "pyqs"].map((key) => (
        <div key={key}>
          <h4>{key.toUpperCase()}</h4>
          {form.info[key].map((item, idx) => (
            <div key={idx}>
              <input
                placeholder={key === "pyqs" ? "Year" : "Title"}
                value={item.title}
                onChange={(e) =>
                  updateItem(key, idx, "title", e.target.value)
                }
              />
              <input
                placeholder="Google Drive Link"
                value={item.link}
                onChange={(e) =>
                  updateItem(key, idx, "link", e.target.value)
                }
              />
              <button onClick={() => removeItem(key, idx)} style={{ marginLeft: "10px", color: "red" }}>Remove</button>
            </div>
          ))}
          <button onClick={() => addItem(key)}>Add {key}</button>
        </div>
      ))}

      <br />
      <button onClick={() => onSubmit(form)}>Save</button>
    </div>
  );
}
