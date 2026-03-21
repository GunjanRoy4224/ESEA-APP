import 'package:flutter/material.dart';
import 'submit_internship_screen.dart';
import '../content/base_content_list_screen.dart';

class InternshipsScreen extends StatelessWidget {
  const InternshipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const BaseContentListScreen(
        title: "Internships",
        contentType: "internships",
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const SubmitInternshipScreen(),
            ),
          );

          if (result == true) {
            // You can trigger refresh logic here if needed
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}