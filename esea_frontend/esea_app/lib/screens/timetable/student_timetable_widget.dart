import 'package:flutter/material.dart';
import '../../models/student_timetable_entry.dart';
import '../../constants/api_constants.dart';
import '../../services/dio_client.dart';
import '../../widgets/student_weekly_timetable_grid.dart';
import '../../widgets/course_selector_sheet.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class StudentTimetableWidget extends StatefulWidget {
  const StudentTimetableWidget({super.key});

  @override
  State<StudentTimetableWidget> createState() =>
      _StudentTimetableWidgetState();
}

class _StudentTimetableWidgetState extends State<StudentTimetableWidget> {
  bool loading = true;
  String? error;

  List<StudentTimetableEntry> entries = [];
  List<String> selectedCourses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dio = DioClient().dio;

      // 1️⃣ Load selected courses
      final scRes = await dio.get(ApiConstants.studentCourses);
      selectedCourses = (scRes.data as List)
          .map((e) => e['course_code'].toString())
          .toList();

      // 2️⃣ Load student timetable (BACKEND COMPUTED)
      final ttRes = await dio.get(ApiConstants.studentTimetable);

      final Map<String, dynamic> data = ttRes.data;
      final List<StudentTimetableEntry> temp = [];

      data.forEach((day, list) {
        for (final e in list) {
          temp.add(
            StudentTimetableEntry(
              courseCode: e['course_code'],
              day: day,
              startTime: e['start_time'],
              endTime: e['end_time'],
            ),
          );
        }
      });

      entries = temp;
      error = null;
    } catch (e) {
      error = e.toString();
    }

    setState(() => loading = false);
  }

  @override
Widget build(BuildContext context) {
  final user = context.watch<AuthProvider>().user;

  // 🚫 BLOCK ALUMNI HERE (MAIN FIX)
  if (user != null && user.isAlumni) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "My timetable is only available for students.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  // ================= NORMAL STUDENT FLOW =================

  if (loading) {
    return const Center(child: CircularProgressIndicator());
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      ElevatedButton.icon(
        icon: const Icon(Icons.edit),
        label: const Text("Select / Edit Courses"),
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => CourseSelectorSheet(
              selectedCourses: selectedCourses,
              onUpdated: () async {
                setState(() => loading = true);
                await _load();
              },
            ),
          );
        },
      ),

      const SizedBox(height: 12),

      if (error != null)
        const Text(
          "Failed to load timetable",
          style: TextStyle(color: Colors.red),
        )
      else if (entries.isEmpty)
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text("No courses selected"),
        )
      else
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: StudentWeeklyTimetableGrid(entries: entries),
          ),
        ),
    ],
  );
}
}