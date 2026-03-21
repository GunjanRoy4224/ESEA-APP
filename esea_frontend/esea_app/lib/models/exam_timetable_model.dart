class ExamEntry {
  final String date;
  final String day;
  final String time;
  final String? slot;
  final String course;
  final int? enrolment;
  final String? instructor;
  final String? venue;

  ExamEntry({
    required this.date,
    required this.day,
    required this.time,
    this.slot,
    required this.course,
    this.enrolment,
    this.instructor,
    this.venue,
  });

  factory ExamEntry.fromJson(Map<String, dynamic> json) {
    return ExamEntry(
      date: json['date'],
      day: json['day'],
      time: json['time'],
      slot: json['slot'],
      course: json['course'],
      enrolment: json['enrolment'],
      instructor: json['instructor'],
      venue: json['venue'],
    );
  }
}

class ExamTimetable {
  final String title;
  final List<ExamEntry> entries;

  ExamTimetable({
    required this.title,
    required this.entries,
  });

  factory ExamTimetable.fromJson(Map<String, dynamic> json) {
    return ExamTimetable(
      title: json['title'],
      entries: (json['rows'] as List)
          .map((e) => ExamEntry.fromJson(e))
          .toList(),
    );
  }
}
