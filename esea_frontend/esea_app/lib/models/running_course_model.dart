class RunningCourse {
  final String course_code;
  final String slot_code;
  final String credit;
  final String course_title;
  final String instructors;
  final String classroom;
  final String tag;
  final String programme;

  RunningCourse({
    required this.course_code,
    required this.slot_code,
    required this.credit,
    required this.course_title,
    required this.instructors,
    required this.classroom,
    required this.tag,
    required this.programme,
  });

  factory RunningCourse.fromJson(Map<String, dynamic> json) {
    return RunningCourse(
      course_code: (json['course_code'] ?? '').toString(),
      slot_code: (json['slot'] ?? '').toString(),
      credit: (json['credit'] ?? '').toString(),
      course_title: (json['course_title'] ?? '').toString(),
      instructors: (json['instructors'] ?? '').toString(),
      classroom: (json['classroom'] ?? '').toString(),
      tag: (json['tag'] ?? '').toString(),
      programme: (json['programme'] ?? '').toString(), 
    );
  }
}
