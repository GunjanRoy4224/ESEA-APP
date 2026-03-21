import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceListTile extends StatelessWidget {
  final String title;
  final String link;

  const ResourceListTile({
    super.key,
    required this.title,
    required this.link,
  });

  Future<void> _openLink() async {
    final uri = Uri.parse(link);
    await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.open_in_new),
      onTap: _openLink,
    );
  }
}
