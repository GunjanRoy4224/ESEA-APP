import 'package:flutter/material.dart';
import '../../models/running_course_model.dart';
import '../../services/running_courses_service.dart';
import 'running_courses_widget.dart';

class RunningCoursesScreen extends StatefulWidget {
  const RunningCoursesScreen({super.key});

  @override
  State<RunningCoursesScreen> createState() => _RunningCoursesScreenState();
}

class _RunningCoursesScreenState extends State<RunningCoursesScreen> {
  List<RunningCourse> courses = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      courses = await RunningCoursesService().fetchRunningCourses();
    } catch (e) {
      error = "Failed to load running courses";
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return RunningCoursesWidget(courses: courses);
  }
}
