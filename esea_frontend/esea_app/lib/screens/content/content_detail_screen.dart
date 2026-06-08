import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/content_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../common/pdf_viewer_screen.dart';

class ContentDetailScreen extends StatelessWidget {
  final ContentModel item;

  const ContentDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String type = item.type.toLowerCase().trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= TITLE =================
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // ================= SHORT DESCRIPTION =================
            Text(
              item.shortDescription,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            // ================= FULL DESCRIPTION =================
            if (item.fullDescription != null &&
                item.fullDescription!.trim().isNotEmpty) ...[
              const Text(
                "Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.fullDescription!,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 20),
            ],

            // ================= EVENT INFO =================
            if (type == "event") ...[
              if (item.eventDate != null &&
                  item.eventDate!.trim().isNotEmpty)
                _infoRow("Event Date", item.eventDate!),

              if (item.eventTime != null &&
                  item.eventTime!.trim().isNotEmpty)
                _infoRow("Event Time", item.eventTime!),

              const SizedBox(height: 16),
            ],

            // ================= INTERNSHIP INFO =================
            if (type == "internship") ...[
              if (item.deadline != null &&
                  item.deadline!.trim().isNotEmpty)
                _infoRow("Deadline", item.deadline!),

              const SizedBox(height: 20),

              // APPLY NOW
              if (item.externalLink != null &&
                  item.externalLink!.trim().isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        _openExternal(item.externalLink!),
                    child: const Text("Apply Now"),
                  ),
                ),

              const SizedBox(height: 10),
            ],

            // ================= IMAGE =================
            if (item.imageUrl != null &&
                item.imageUrl!.trim().isNotEmpty) ...[
              const Text(
                "Image",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl!.startsWith('http')
                      ? item.imageUrl!
                      : "${AppConfig.uploadsUrl}${item.imageUrl}",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) {
                    return Container(
                      height: 200,
                      alignment: Alignment.center,
                      color: Colors.grey.shade200,
                      child: const Text("Image failed to load"),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ================= FILE (PDF → NATIVE VIEWER) =================
            if (item.fileUrl != null &&
                item.fileUrl!.trim().isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("View Document"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfViewerScreen(
                          url: item.fileUrl!,
                          title: item.title,
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (item.fileUrl != null &&
                item.fileUrl!.trim().isNotEmpty)
              const SizedBox(height: 10),

            // ================= EXTERNAL LINK =================
            if (item.externalLink != null &&
                item.externalLink!.trim().isNotEmpty &&
                type != "internship")
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("Open Link"),
                  onPressed: () =>
                      _openExternal(item.externalLink!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= INFO ROW =================
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // ================= OPEN EXTERNAL =================
  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}
