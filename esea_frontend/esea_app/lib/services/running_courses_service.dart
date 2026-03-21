import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/running_course_model.dart';
import 'dio_client.dart';

class RunningCoursesService {
  final Dio _dio = DioClient().dio;

  Future<List<RunningCourse>> fetchRunningCourses() async {
    final res = await _dio.get(ApiConstants.departmentCourses);

    final Map<String, dynamic> data = res.data;

    // course_code → merged course
    final Map<String, RunningCourse> unique = {};

    data.forEach((_, list) {
      for (final e in list) {
        final code = e['course_code'];

        if (!unique.containsKey(code)) {
          unique[code] = RunningCourse(
            course_code: code.toString(),
            slot_code: e['slot'].toString(),
            credit: (e['credit'] ?? '').toString(),
            course_title: (e['course_title'] ?? '').toString(),
            instructors: (e['instructors'] ?? '').toString(),
            classroom: (e['classroom'] ?? '').toString(),
            tag: (e['tag'] ?? '').toString(),
            programme: (e['programme'] ?? '').toString(),
          );
        } else {
          // merge slots (11A, 11B)
          final existing = unique[code]!;
          final newSlot = e['slot'].toString();

          if (!existing.slot_code.contains(newSlot)) {
            unique[code] = RunningCourse(
              course_code: existing.course_code,
              slot_code: "${existing.slot_code}, $newSlot",
              credit: existing.credit,
              course_title: existing.course_title,
              instructors: existing.instructors,
              classroom: existing.classroom,
              tag: existing.tag,
              programme: existing.programme,
            );
          }
        }
      }
    });

    return unique.values.toList();
  }
}
