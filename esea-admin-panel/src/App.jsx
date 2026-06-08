import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { AuthProvider } from "./context/AuthContext";

import Login from "./auth/Login";
import RequireAdmin from "./auth/RequireAdmin";
import AdminLayout from "./layouts/AdminLayout";

import Dashboard from "./pages/Dashboard";
import ContentList from "./pages/ContentList";
import CreateContent from "./pages/CreateContent";
import EditContent from "./pages/EditContent";
import UploadSlotTime from "./pages/UploadSlotTime";
import UploadDepartmentCourses from "./pages/UploadDepartmentCourses";
import UploadExamTimetable from "./pages/UploadExamTimetable";
import AuditLogs from "./pages/AuditLogs";
import ExamTimetablePreview from "./pages/ExamTimetablePreview";
import CourseInfoList from "./pages/CourseInfoList";
import CreateCourseInfo from "./pages/CreateCourseInfo";
import EditCourseInfo from "./pages/EditCourseInfo";
import UploadEseaIdCsv from "./pages/UploadEseaIdCsv";
import DeleteContent from "./pages/DeleteContent";
import FeedbackList from "./pages/FeedbackList";
import InternshipModeration from "./pages/InternshipModeration";
import AlumniManagement from "./pages/AlumniManagement";
import DiscussionModeration from "./pages/DiscussionModeration";


function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          {/* Public */}
          <Route path="/login" element={<Login />} />
          {/*Redirect root*/}
          <Route path="/" element={<Navigate to="/login" replace />} />
          {/* Protected Admin Layout */}
          <Route element={<RequireAdmin />}>
            <Route element={<AdminLayout />}>
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/content" element={<ContentList />} />
            <Route path="/content/create" element={<CreateContent />} />
            <Route path="/content/edit/:id" element={<EditContent />} />
            <Route path="/content/delete/:id" element={<DeleteContent />} />
            <Route path="/upload/slot-time" element={<UploadSlotTime />} />
            <Route
              path="/upload/department-courses"
              element={<UploadDepartmentCourses />}
            />
            <Route path="/upload/exams" element={<UploadExamTimetable />} />
            <Route path="/exams/preview" element={<ExamTimetablePreview />} />
            <Route path="/course-info" element={<CourseInfoList />} />
            <Route path="/course-info/create" element={<CreateCourseInfo />} />
            <Route path="/course-info/edit/:id" element={<EditCourseInfo />} />
            <Route path="/esea-id/upload" element = {<UploadEseaIdCsv />} />
            <Route path="/alumni" element={<AlumniManagement />} />
            <Route path="/discussions/moderation" element={<DiscussionModeration />} />
            <Route path="/internships/moderation" element={<InternshipModeration />} />
            <Route path="/feedback" element={<FeedbackList />} />
            <Route path="/audit" element={<AuditLogs />} />
          </Route>
          </Route>

          {/* Fallback */}
          <Route path="*" element={<Navigate to="/login" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
