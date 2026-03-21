class CourseInfo {
  final String courseCode;
  final String courseTitle;
  final String? instructor;

  final List<ResourceItem> syllabus;
  final List<ResourceItem> resources;
  final List<ResourceItem> pyqs;

  CourseInfo({
    required this.courseCode,
    required this.courseTitle,
    this.instructor,
    required this.syllabus,
    required this.resources,
    required this.pyqs,
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>? ?? {};

    // ✅ STRICT CHECK (WILL NEVER BE EMPTY)
    final code = json['course_code'];
    final title = json['course_title'];

    if (code == null || title == null) {
      throw Exception("Invalid course data: missing course_code or course_title");
    }

    return CourseInfo(
      // ✅ CORRECT MAPPING (ROOT LEVEL)
      courseCode: code.toString(),
      courseTitle: title.toString(),
      instructor: json['instructor']?.toString(),

      // ✅ SAFE NESTED PARSING
      syllabus: (info['syllabus'] as List? ?? [])
          .map((e) => ResourceItem.fromJson(e))
          .toList(),

      resources: (info['resources'] as List? ?? [])
          .map((e) => ResourceItem.fromJson(e))
          .toList(),

      pyqs: (info['pyqs'] as List? ?? [])
          .map((e) => ResourceItem.fromJson(e))
          .toList(),
    );
  }
}

// ======================================================
// RESOURCE ITEM MODEL
// ======================================================

class ResourceItem {
  final String title;
  final String link;

  ResourceItem({
    required this.title,
    required this.link,
  });

  factory ResourceItem.fromJson(Map<String, dynamic> json) {
    return ResourceItem(
      title: json['title']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
    );
  }
}