import { useNavigate } from "react-router-dom";
import { createCourseInfo } from "../api/courseInfoApi";
import CourseInfoForm from "./CourseInfoForm";

export default function CreateCourseInfo() {
  const navigate = useNavigate();

  const submit = async (data) => {
    try {
      await createCourseInfo(data);
      navigate("/course-info");
    } catch (err) {
      console.error(err);
      alert("Failed to create course info");
    }
  };

  return (
    <>
      <h2>Create Course Info</h2>
      <CourseInfoForm onSubmit={submit} />
    </>
  );
}
