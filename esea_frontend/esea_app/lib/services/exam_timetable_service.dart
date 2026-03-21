import 'dio_client.dart';
import '../constants/api_constants.dart';
import '../models/exam_timetable_model.dart'; 

class ExamTimetableService {
  final DioClient _dio = DioClient();

  Future<ExamTimetable?> fetchExamTimetable() async {
    final res = await _dio.get(ApiConstants.examTimetable);

    if (res.data is Map && res.data['rows'] != null) {
      return ExamTimetable.fromJson(res.data);
    }

    return null;
  }
}
