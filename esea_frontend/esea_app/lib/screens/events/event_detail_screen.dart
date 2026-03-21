import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/content_model.dart';

class EventDetailScreen extends StatelessWidget {
  final ContentModel content;

  const EventDetailScreen({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- TITLE ----------
            Text(
              content.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // ---------- FULL DESCRIPTION ----------
            Text(
              content.fullDescription ??
                  content.shortDescription,
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 24),

            // ---------- EVENT DATE ----------
            if (content.eventDate != null &&
                content.eventDate!.trim().isNotEmpty)
              _infoRow(
                Icons.calendar_today,
                "Date",
                _formatDate(content.eventDate!),
              ),

            // ---------- EVENT TIME ----------
            if (content.eventTime != null &&
                content.eventTime!.trim().isNotEmpty)
              _infoRow(
                Icons.access_time,
                "Time",
                content.eventTime!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    final dt = DateTime.tryParse(date);
    if (dt == null) return date;
    return DateFormat("dd MMM yyyy").format(dt);
  }
}
