import 'dio_client.dart';
import '../constants/api_constants.dart';

class TimetableService {
  final DioClient _dio = DioClient();

  Future<Map<String, dynamic>> fetchDepartmentTimetable() async {
    final res = await _dio.get(ApiConstants.departmentCourses);
    return Map<String, dynamic>.from(res.data);
  }
}
