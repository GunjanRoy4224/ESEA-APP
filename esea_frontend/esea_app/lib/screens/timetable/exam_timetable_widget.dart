import 'package:flutter/material.dart';
import '../../services/exam_timetable_service.dart';
import '../../models/exam_timetable_model.dart';
import '../../utils/exam_grouping.dart';
import 'exam_timetable_card.dart';

class ExamTimetableWidget extends StatefulWidget {
  const ExamTimetableWidget({super.key});

  @override
  State<ExamTimetableWidget> createState() => _ExamTimetableWidgetState();
}

class _ExamTimetableWidgetState extends State<ExamTimetableWidget> {
  ExamTimetable? timetable;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    timetable = await ExamTimetableService().fetchExamTimetable();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (timetable == null) {
      return const Text("Exam timetable not announced yet");
    }

    final grouped = groupByDate(timetable!.entries);

    return Column(
      children: grouped.entries
          .map(
            (e) => ExamDateCard(
              date: e.key,
              exams: e.value,
            ),
          )
          .toList(),
    );
  }
}
