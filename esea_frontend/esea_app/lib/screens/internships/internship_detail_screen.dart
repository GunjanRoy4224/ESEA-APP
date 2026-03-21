import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/content_model.dart';

class InternshipDetailScreen extends StatelessWidget {
  final ContentModel content;

  const InternshipDetailScreen({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Internship Details"),
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

            const SizedBox(height: 20),

            // ---------- DEADLINE ----------
            if (content.deadline != null &&
                content.deadline!.trim().isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.schedule, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Deadline: ${_formatDeadline(content.deadline!)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),

            // ---------- APPLY BUTTON ----------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _applyNow(content.externalLink),
                child: const Text("Apply Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyNow(String? url) async {
    if (url == null || url.trim().isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  String _formatDeadline(String deadline) {
    final dt = DateTime.tryParse(deadline);
    if (dt == null) return deadline;
    return DateFormat("dd MMM yyyy").format(dt);
  }
}
