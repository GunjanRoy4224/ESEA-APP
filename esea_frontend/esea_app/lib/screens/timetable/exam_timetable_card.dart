import 'package:flutter/material.dart';
import '../../models/exam_timetable_model.dart';

const Color greenDark = Color(0xFF4F6F66);
const Color greenStrip = Color(0xFFE6F1EC);
const Color cardBg = Colors.white;
const Color textMuted = Color(0xFF6B7280);

class ExamDateCard extends StatelessWidget {
  final String date;
  final List<ExamEntry> exams;

  const ExamDateCard({
    super.key,
    required this.date,
    required this.exams,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          // GREEN STRIP 
          Container(
            width: 56,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 182, 233, 210),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                bottomLeft: Radius.circular(22),
              ),
            ),
            padding: const EdgeInsets.only(top: 18),
            child: const Icon(
              Icons.calendar_today,
              color: greenDark,
            ),
          ),

          // CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // STACK EXAMS VERTICALLY
                  ...exams.map(_examBlock),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _examBlock(ExamEntry e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            e.course,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _info(Icons.access_time, "Time", e.time),
          if (e.slot != null)
            _info(Icons.confirmation_number, "Slot", "${e.slot}"),
          if (e.instructor != null)
            _info(Icons.person, "Instructor", e.instructor!),
          if (e.venue != null)
            _info(Icons.place, "Venue", e.venue!),
          if (e.enrolment != null)
            _info(Icons.group, "Enrolment", "${e.enrolment}"),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: greenDark),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(
                fontSize: 13,
                color: textMuted,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
