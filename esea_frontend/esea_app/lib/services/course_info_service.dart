import 'package:dio/dio.dart';
import '../models/course_info_model.dart';
import '../constants/api_constants.dart';
import 'dio_client.dart';

class CourseInfoService {
  final Dio _dio = DioClient().dio;

  Future<List<CourseInfo>> fetchAllCourses() async {
    try {
  final response = await _dio.get(ApiConstants.courseInfo);
  return (response.data as List)
      .map((e) => CourseInfo.fromJson(e))
      .toList();
} catch (e) {
  print("COURSE INFO API ERROR: $e");
  rethrow;
}
}

  Future<CourseInfo> fetchCourse(String courseCode) async {
    final response = await _dio.get(
      '${ApiConstants.courseInfo}/$courseCode',
    );
    print("REQUEST URL = ${ApiConstants.courseInfo}");

    return CourseInfo.fromJson(response.data);
  }
}
