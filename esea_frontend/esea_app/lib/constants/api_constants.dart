class ApiConstants {
  

  // Auth
  static const String ssoLogin = "/auth/sso/login";
  static const String me = "/users/me";
  
  // Content
  static String contentByType(String type) => "/content/$type";

  // Timetable
  static const String studentCourses = "/student/courses/";
  static const String departmentCourses = "/timetable/department";
  static const String studentTimetable = "/timetable/student";


  // Exams
  static const String examTimetable = "/timetable/exams";

  // Course Info
  static const String courseInfo = "/course-info/";
}
