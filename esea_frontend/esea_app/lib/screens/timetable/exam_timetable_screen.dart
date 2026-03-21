import 'package:flutter/material.dart';
import '../../models/exam_timetable_model.dart';
import '../../services/exam_timetable_service.dart';
import '../../utils/exam_grouping.dart';
import 'exam_timetable_card.dart';

class ExamTimetableScreen extends StatefulWidget {
  const ExamTimetableScreen({super.key});

  @override
  State<ExamTimetableScreen> createState() => _ExamTimetableScreenState();
}

class _ExamTimetableScreenState extends State<ExamTimetableScreen> {
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
      return const Scaffold(
        body: Center(child: Text("Exam timetable not announced yet")),
      );
    }

    final grouped = groupByDate(timetable!.entries);

    return Scaffold(
      appBar: AppBar(title: const Text("Exam Timetable")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: grouped.entries
            .map(
              (e) => ExamDateCard(
                date: e.key,
                exams: e.value,
              ),
            )
            .toList(),
      ),
    );
  }
}
