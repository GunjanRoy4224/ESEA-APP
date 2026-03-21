import 'package:flutter/material.dart';
import '../services/dio_client.dart';
import '../services/student_course_service.dart';
import '../constants/api_constants.dart';

class CourseSelectorSheet extends StatefulWidget {
  final List<String> selectedCourses;
  final VoidCallback onUpdated;

  const CourseSelectorSheet({
    super.key,
    required this.selectedCourses,
    required this.onUpdated,
  });

  @override
  State<CourseSelectorSheet> createState() => _CourseSelectorSheetState();
}

class _CourseSelectorSheetState extends State<CourseSelectorSheet> {
  final StudentCourseService _studentService = StudentCourseService();
  final DioClient _dioClient = DioClient();

  bool loading = true;

  /// course_code -> { title, slot_code }
  final Map<String, Map<String, String>> courses = {};

  /// local selection (NOT committed until Save)
  late Set<String> selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selectedCourses.toSet();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final res = await _dioClient.get(ApiConstants.departmentCourses);

      // backend format: { Mon: [...], Tue: [...] }
      (res.data as Map<String, dynamic>).forEach((_, list) {
        for (final c in list) {
          final code = c["course_code"]?.toString();
          if (code == null) continue;

          // ✅ DEDUPE: keep only first occurrence
          courses.putIfAbsent(code, () {
            return {
              "title": c["course_title"]?.toString() ?? "",
              "slot": c["slot_code"]?.toString() ?? "",
            };
          });
        }
      });
    } catch (e) {
      debugPrint("Failed to load department courses: $e");
    }

    setState(() => loading = false);
  }

  Future<void> _save() async {
    final oldSet = widget.selectedCourses.toSet();

    final toAdd = selected.difference(oldSet);
    final toRemove = oldSet.difference(selected);

    for (final c in toAdd) {
      await _studentService.addCourse(c);
    }

    for (final c in toRemove) {
      await _studentService.removeCourse(c);
    }

    widget.onUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Select / Edit Courses",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: _save,
                        child: const Text("SAVE"),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // COURSE LIST
                Expanded(
                  child: ListView(
                    children: courses.entries.map((e) {
                      final code = e.key;
                      final title = e.value["title"]!;
                      final checked = selected.contains(code);

                      return CheckboxListTile(
                        value: checked,
                        title: Text(code),
                        subtitle: Text(title),
                        onChanged: (v) {
                          setState(() {
                            v!
                                ? selected.add(code)
                                : selected.remove(code);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
