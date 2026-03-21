import 'package:flutter/material.dart';
import '../content/base_content_list_screen.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: const BaseContentListScreen(
        title: "Announcements",
        contentType: "announcements",
      ),
    );
  }
}
