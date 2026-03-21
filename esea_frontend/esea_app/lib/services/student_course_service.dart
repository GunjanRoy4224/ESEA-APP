import '../services/dio_client.dart';
import '../constants/api_constants.dart';

class StudentCourseService {
  final _dio = DioClient().dio;

  Future<List<String>> getSelectedCourses() async {
    final res = await _dio.get(ApiConstants.studentCourses);
    return (res.data as List)
        .map((e) => e['course_code'].toString())
        .toList();
  }

  Future<void> addCourse(String courseCode) async {
    await _dio.post(
      ApiConstants.studentCourses,
      data: {"course_code": courseCode},
    );
  }

  Future<void> removeCourse(String courseCode) async {
    await _dio.delete("${ApiConstants.studentCourses}$courseCode");
  }
}
