import 'package:flutter/material.dart';
import '../../models/course_info_model.dart';
import '../common/pdf_viewer_screen.dart';

class CourseInfoDetailScreen extends StatelessWidget {
  final CourseInfo course;

  const CourseInfoDetailScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(course.courseCode),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          // ================= COURSE HEADER =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.courseTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (course.instructor != null &&
                    course.instructor!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Instructor: ${course.instructor}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ================= SECTIONS =================
          if (course.syllabus.isNotEmpty)
            _groupSection(
              context: context,
              title: "Syllabus",
              color: Colors.blue,
              items: course.syllabus,
            ),

          if (course.resources.isNotEmpty)
            _groupSection(
              context: context,
              title: "Resources",
              color: Colors.green,
              items: course.resources,
            ),

          if (course.pyqs.isNotEmpty)
            _groupSection(
              context: context,
              title: "PYQs",
              color: Colors.deepPurple,
              items: course.pyqs,
            ),
        ],
      ),
    );
  }

  // ================= GROUPED SECTION =================

  Widget _groupSection({
    required BuildContext context,
    required String title,
    required Color color,
    required List<ResourceItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SECTION HEADER
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.6,
              ),
            ),
          ),

          // SECTION CARD
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: List.generate(items.length, (index) {
                final e = items[index];
                final isLast = index == items.length - 1;

                return Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfViewerScreen(
                              url: e.link,
                              title: e.title,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            _pdfBadge(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                e.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (!isLast)
                      const Padding(
                        padding: EdgeInsets.only(left: 60),
                        child: Divider(height: 1),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PDF BADGE =================

  Widget _pdfBadge() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          "PDF",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
