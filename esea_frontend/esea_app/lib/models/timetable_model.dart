class SlotTime {
  final String slot;
  final String day;
  final String startTime;
  final String endTime;

  SlotTime({
    required this.slot,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory SlotTime.fromJson(Map<String, dynamic> json) {
    return SlotTime(
      slot: json['slot'],
      day: json['day'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

class CourseEntry {
  final String courseCode;
  final String courseTitle;
  final String slot;
  final String instructor;
  final String? classroom;
  final String type; // core / elective / lab

  CourseEntry({
    required this.courseCode,
    required this.courseTitle,
    required this.slot,
    required this.instructor,
    this.classroom,
    required this.type,
  });

  factory CourseEntry.fromJson(Map<String, dynamic> json) {
    return CourseEntry(
      courseCode: json['course_code'],
      courseTitle: json['course_title'],
      slot: json['slot'],
      instructor: json['instructor'],
      classroom: json['classroom'],
      type: json['type'],
    );
  }
}
