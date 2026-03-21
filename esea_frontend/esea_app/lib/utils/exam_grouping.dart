import '../models/exam_timetable_model.dart';

Map<String, List<ExamEntry>> groupByDate(List<ExamEntry> entries) {
  final Map<String, List<ExamEntry>> grouped = {};
  for (final e in entries) {
    grouped.putIfAbsent(e.date, () => []).add(e);
  }
  return grouped;
}
