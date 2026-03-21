import 'package:flutter/material.dart';
import 'department_timetable_widget.dart';
import 'student_timetable_widget.dart';
import 'exam_timetable_widget.dart';
import 'running_courses_screen.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  bool showExam = false;
  bool showRunning = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = 0; // ✅ My Timetable first
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Timetable")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ================= CARD =================
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // ---------- TAB HEADER ----------
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.teal,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: "My Timetable"),
                      Tab(text: "Department Timetable"),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // ---------- TAB CONTENT ----------
                SizedBox(
                  height: 520, // ✅ fixed height avoids overflow
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      StudentTimetableWidget(),
                      DepartmentTimetableWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ================= BUTTONS =================
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showExam = !showExam;
                      showRunning = false;
                    });
                  },
                  child: const Text("Exam Timetable"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showRunning = !showRunning;
                      showExam = false;
                    });
                  },
                  child: const Text("Running Courses"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (showExam) ExamTimetableWidget(),
          if (showRunning) const RunningCoursesScreen(),
        ],
      ),
    );
  }
}
