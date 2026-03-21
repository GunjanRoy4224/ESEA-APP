import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/content_model.dart';
import '../screens/internships/internship_detail_screen.dart';
import '../screens/events/event_detail_screen.dart';
import '../screens/common/pdf_viewer_screen.dart';


class ContentCard extends StatelessWidget {
  final ContentModel content;
  final VoidCallback? onTap;

  const ContentCard({
    super.key,
    required this.content,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = content.type.toLowerCase().trim();

    if (type == "announcement") {
      return _announcementCard(context);
    }

    if (type == "event") {
      return _eventCard(context);
    }

    if (type == "research") {
      return _researchCard(context);
    }

    if (type == "newsletter") {
      return _newsletterCard(context);
    }

    if (type == "internship") {
      return _internshipCard(context);
    }

    // ---------- DEFAULT CARD ----------
    return GestureDetector(
      onTap: onTap,
      child: _baseCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              content.shortDescription,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // 📢 ANNOUNCEMENT
  // ==================================================
  Widget _announcementCard(BuildContext context) {
    final timeText = _relativeTime(content.published_at);

    return GestureDetector(
      onTap: onTap,
      child: _baseCard(
        child: Row(
          children: [
            _circleIcon(Icons.campaign, Colors.blue),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content.shortDescription,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              timeText,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // 📅 EVENT
  // ==================================================
  Widget _eventCard(BuildContext context) {
  final date = _parseEventDate(content.eventDate);
  final time = content.eventTime ?? "";
  final venue = content.eventVenue ?? "";

  return _baseCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- TOP ROW ----------
        Row(
          children: [
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4E6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    date.day,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    date.month,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          content.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _statusChip(content.eventDate),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content.shortDescription,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        const Divider(),

        // ---------- INFO ----------
        if (venue.isNotEmpty)
          _infoRow(Icons.location_on, venue),
        if (time.isNotEmpty)
          _infoRow(Icons.access_time, time),

        const SizedBox(height: 14),

        // ---------- DETAILS BUTTON ----------
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EventDetailScreen(content: content),
                ),
              );
            },
            child: const Text("Details"),
          ),
        ),
      ],
    ),
  );
}

  // ==================================================
  // 🔬 RESEARCH
  // ==================================================
  Widget _researchCard(BuildContext context) {
  return GestureDetector(
    onTap: onTap,
    child: _baseCard(
      child: Row(
        children: [
          // LEFT IMAGE
          Container(
            width: 90,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6EC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Image.asset(
                "assets/images/research.png",
                width: 42,
                height: 42,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content.shortDescription,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ VIEW BUTTON
                if (content.fileUrl != null &&
                    content.fileUrl!.trim().isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          url: content.fileUrl!,
          title: content.title,
        ),
      ),
    );
  },
  style: OutlinedButton.styleFrom(
    side: const BorderSide(color: Color(0xFF6C63FF)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 6,
    ),
  ),
  child: const Text(
    "View",
    style: TextStyle(
      color: Color(0xFF6C63FF),
      fontWeight: FontWeight.w600,
      fontSize: 13,
    ),
  ),
),

                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  // ==================================================
  // 📰 NEWSLETTER
  // ==================================================
  Widget _newsletterCard(BuildContext context) {
  return GestureDetector(
    onTap: onTap,
    child: _baseCard(
      child: Row(
        children: [
          // LEFT IMAGE
          Container(
            width: 90,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Image.asset(
                "assets/images/newsletter.png",
                width: 42,
                height: 42,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content.shortDescription,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ VIEW BUTTON
                if (content.fileUrl != null &&
                    content.fileUrl!.trim().isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          url: content.fileUrl!,
          title: content.title,
        ),
      ),
    );
  },
  style: OutlinedButton.styleFrom(
    side: const BorderSide(color: Color(0xFF6C63FF)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 6,
    ),
  ),
  child: const Text(
    "View",
    style: TextStyle(
      color: Color(0xFF6C63FF),
      fontWeight: FontWeight.w600,
      fontSize: 13,
    ),
  ),
),

                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  // ==================================================
  // 💼 INTERNSHIP
  // ==================================================
  Widget _internshipCard(BuildContext context) {
  final status = _internshipStatus(content.deadline);

  return _baseCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- TOP ----------
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _assetPanel(
              "assets/images/internship.png",
              const Color(0xFFEAF0FF),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          content.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _internshipStatusChip(status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content.shortDescription,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ---------- DEADLINE ----------
        if (content.deadline != null &&
            content.deadline!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          const Divider(),
          _infoRow(
            Icons.schedule,
            "Deadline: ${_formatDeadline(content.deadline!)}",
          ),
        ],

        const SizedBox(height: 12),

        // ---------- ACTION BUTTONS ----------
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          InternshipDetailScreen(content: content),
                    ),
                  );
                },
                child: const Text("Details"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: status == _InternshipStatus.active &&
                content.externalLink != null &&
                content.externalLink!.trim().isNotEmpty
                ? () => _openExternalLink(content.externalLink!)
                : null,
                child: const Text("Apply Now"),
                ),
                ),

          ],
        ),
      ],
    ),
  );
}

  // ==================================================
  // 🔧 HELPERS
  // ==================================================
  Widget _baseCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }

  Widget _assetPanel(String path, Color bg) {
    return Container(
      width: 90,
      height: 80,
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
      child: Center(
        child: Image.asset(path, width: 42, height: 42),
      ),
    );
  }

  Widget _circleIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
      child: Icon(icon, color: color),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
  
  void _openExternalLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}


  Widget _statusChip(String? eventDate) {
    final dt = DateTime.tryParse(eventDate ?? "");
    if (dt == null) return const SizedBox();
    final today = DateTime.now();
    final upcoming =
        !dt.isBefore(DateTime(today.year, today.month, today.day));
    return _chip(upcoming ? "Upcoming" : "Completed",
        upcoming ? Colors.green : Colors.grey);
  }

  String _relativeTime(String? publishedAt) {
    final dt = DateTime.tryParse(publishedAt ?? "");
    if (dt == null) return "";
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inHours < 24) return "Today";
    if (diff.inDays <= 3) return "${diff.inDays} days ago";
    return DateFormat("dd MMM yyyy").format(dt);
  }

  _EventDate _parseEventDate(String? date) {
    final dt = DateTime.tryParse(date ?? "");
    if (dt == null) return _EventDate("--", "---");
    return _EventDate(dt.day.toString(),
        DateFormat("MMM").format(dt).toUpperCase());
  }

  _InternshipStatus _internshipStatus(String? deadline) {
    final dt = DateTime.tryParse(deadline ?? "");
    if (dt == null) return _InternshipStatus.unknown;
    final today = DateTime.now();
    return dt.isBefore(DateTime(today.year, today.month, today.day))
        ? _InternshipStatus.inactive
        : _InternshipStatus.active;
  }

  Widget _internshipStatusChip(_InternshipStatus status) {
    if (status == _InternshipStatus.unknown) return const SizedBox();
    return _chip(status == _InternshipStatus.active ? "Active" : "Inactive",
        status == _InternshipStatus.active ? Colors.green : Colors.grey);
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style:
              TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  String _formatDeadline(String deadline) {
    final dt = DateTime.tryParse(deadline);
    if (dt == null) return deadline;
    return DateFormat("dd MMM yyyy").format(dt);
  }
}

// ==================================================
class _EventDate {
  final String day;
  final String month;
  _EventDate(this.day, this.month);
}

enum _InternshipStatus { active, inactive, unknown }
