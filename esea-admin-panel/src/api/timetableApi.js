import api from "../api/axios";

export const getDepartmentTimetable = async () => {
  const res = await api.get("/timetable/department");
  return res.data;
};
