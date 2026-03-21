import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyTimetableGrid extends StatelessWidget {
  final Map<String, dynamic> timetable;

  const WeeklyTimetableGrid({super.key, required this.timetable});

  static const days = ["Mon", "Tue", "Wed", "Thu", "Fri"];

  // Base sizing
  static const double baseRowHeight = 70;
  static const double pillHeight = 26;
  static const double pillSpacing = 6;

  String _today() => DateFormat('EEE').format(DateTime.now());

  // --------------------------------------------------
  // 🔢 MAX COURSES IN A DAY (per time slot)
  // --------------------------------------------------
  int _maxCoursesInDay(String day) {
    final List dayCourses =
        timetable[day] is List ? timetable[day] : [];

    final Map<String, int> slotCount = {};

    for (final c in dayCourses) {
      final key = "${c["start_time"]}-${c["end_time"]}";
      slotCount[key] = (slotCount[key] ?? 0) + 1;
    }

    if (slotCount.isEmpty) return 1;
    return slotCount.values.reduce((a, b) => a > b ? a : b);
  }

  // --------------------------------------------------
  // 📐 ROW HEIGHT FOR DAY
  // --------------------------------------------------
  double _rowHeightForDay(String day) {
  final max = _maxCoursesInDay(day);

  if (max <= 2) return baseRowHeight;

  // Exact space calculation
  return
      16 + // container padding (top + bottom)
      (max * pillHeight) +
      ((max - 1) * pillSpacing) +
      16; // safety buffer for text & wrap rounding
}

  @override
  Widget build(BuildContext context) {
    final today = _today();

    // Collect time slots
    final Set<String> times = {};
    for (final dayCourses in timetable.values) {
      if (dayCourses is List) {
        for (final c in dayCourses) {
          times.add("${c["start_time"]}-${c["end_time"]}");
        }
      }
    }
    final timeSlots = times.toList()..sort();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- FIXED DAY COLUMN ----------------
          Column(
            children: [
              _headerCell("Day", width: 70),
              ...days.map(
                (d) => _dayCell(
                  d,
                  height: _rowHeightForDay(d),
                  highlight: d == today,
                ),
              ),
            ],
          ),

          // ---------------- SCROLLABLE TIMETABLE ----------------
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _timeHeaderRow(timeSlots),
                  ...days.map(
                    (d) => _timeRow(
                      d,
                      timeSlots,
                      rowHeight: _rowHeightForDay(d),
                      highlight: d == today,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HEADERS ----------------

  Widget _timeHeaderRow(List<String> times) {
    return Row(
      children: times.map((t) => _headerCell(t)).toList(),
    );
  }

  // ---------------- ROWS ----------------

  Widget _timeRow(
    String day,
    List<String> times, {
    required double rowHeight,
    bool highlight = false,
  }) {
    final List courses =
        timetable[day] is List ? timetable[day] : [];

    return Row(
      children: times.map((time) {
        final cellCourses = courses
            .where(
              (c) =>
                  "${c["start_time"]}-${c["end_time"]}" == time,
            )
            .toList();

        return _courseCell(
          cellCourses,
          height: rowHeight,
          highlight: highlight,
        );
      }).toList(),
    );
  }

  // ---------------- CELLS ----------------

  Widget _headerCell(String text, {double width = 140}) {
    return Container(
      width: width,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _dayCell(
    String day, {
    required double height,
    bool highlight = false,
  }) {
    return Container(
      width: 70,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlight
            ? Colors.yellow.shade100
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        day,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _courseCell(
    List courses, {
    required double height,
    bool highlight = false,
  }) {
    return Container(
      width: 140,
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.yellow.shade50
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Center(
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: courses.map<Widget>((c) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F1EC), // 🌿 light green
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                c["course_code"],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F5D50),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
