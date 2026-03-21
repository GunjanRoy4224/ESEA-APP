import 'package:flutter/material.dart';
import '../models/student_timetable_entry.dart';

class StudentWeeklyTimetableGrid extends StatelessWidget {
  final List<StudentTimetableEntry> entries;

  const StudentWeeklyTimetableGrid({super.key, required this.entries});

  static const days = ["Mon", "Tue", "Wed", "Thu", "Fri"];
  static const double slotHeight = 40;
  static const double dayWidth = 110;

  static const int startMinutes = 8 * 60 + 30;
  static const int endMinutes = 20 * 60 + 30;

  // 🎨 Day-wise colors
  static const Map<String, Color> dayColors = {
    "Mon": Color(0xFF5AA9FF),
    "Tue": Color(0xFFFFE082),
    "Wed": Color(0xFF9CCC9C),
    "Thu": Color(0xFFB39DDB),
    "Fri": Color(0xFFFFAB91),
  };

  int _toMinutes(String time) {
    final p = time.split(":");
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  double _top(String start) {
    return (_toMinutes(start) - startMinutes) / 30 * slotHeight;
  }

  double _height(String start, String end) {
    return (_toMinutes(end) - _toMinutes(start)) / 30 * slotHeight;
  }

  @override
  Widget build(BuildContext context) {
    final totalSlots = ((endMinutes - startMinutes) / 30).round();
    final totalHeight = totalSlots * slotHeight;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TIME COLUMN =====
            Column(
              children: [
                _emptyHeader(),
                _timeLabels(totalSlots),
              ],
            ),

            // ===== DAY COLUMNS =====
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: days.map((day) {
                    final dayEntries =
                        entries.where((e) => e.day == day).toList();

                    return SizedBox(
                      width: dayWidth,
                      child: Column(
                        children: [
                          _dayHeader(day),
                          SizedBox(
                            height: totalHeight,
                            child: Stack(
                              children: [
                                _timeGrid(totalSlots),
                                ...dayEntries.map((e) {
                                  return Positioned(
                                    top: _top(e.startTime),
                                    left: 6,
                                    right: 6,
                                    height:
                                        _height(e.startTime, e.endTime),
                                    child: _courseBlock(e, day),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI PARTS =================

  Widget _emptyHeader() {
    return const SizedBox(height: 48, width: 60);
  }

  Widget _dayHeader(String day) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dayColors[day]!.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        day,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _timeLabels(int slots) {
    return Column(
      children: List.generate(slots + 1, (i) {
        final minutes = startMinutes + i * 30;
        final h = minutes ~/ 60;
        final m = minutes % 60;

        return Container(
          height: slotHeight,
          width: 60,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}",
            style: const TextStyle(fontSize: 11, color: Color.fromARGB(255, 0, 0, 0)),
          ),
        );
      }),
    );
  }

  Widget _timeGrid(int slots) {
    return Column(
      children: List.generate(slots, (_) {
        return Container(
          height: slotHeight,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color.fromARGB(31, 255, 5, 5)),
            ),
          ),
        );
      }),
    );
  }

  Widget _courseBlock(StudentTimetableEntry e, String day) {
    final color = dayColors[day]!;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            e.courseCode,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
