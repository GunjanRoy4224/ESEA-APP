import { useNavigate } from "react-router-dom";
import { createCourseInfo } from "../api/courseInfoApi";
import CourseInfoForm from "./CourseInfoForm";

export default function CreateCourseInfo() {
  const navigate = useNavigate();

  const submit = async (data) => {
    await createCourseInfo(data);
    navigate("/course-info");
  };

  return (
    <>
      <h2>Create Course Info</h2>
      <CourseInfoForm onSubmit={submit} />
    </>
  );
}
