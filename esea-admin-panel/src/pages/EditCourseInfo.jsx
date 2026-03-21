import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import api from "../api/axios";
import { updateCourseInfo } from "../api/courseInfoApi";
import CourseInfoForm from "./CourseInfoForm";

export default function EditCourseInfo() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [data, setData] = useState(null);

  useEffect(() => {
    api.get(`/admin/course-info`).then((res) => {
      const found = res.data.find((x) => x.id === id);
      setData(found);
    });
  }, [id]);

  if (!data) return <div>Loading...</div>;

  const submit = async (payload) => {
    await updateCourseMaterial(id, payload);
    navigate("/course-info");
  };

  return (
    <>
      <h2>Edit Course Info</h2>
      <CourseMaterialForm initial={data} onSubmit={submit} />
    </>
  );
}
