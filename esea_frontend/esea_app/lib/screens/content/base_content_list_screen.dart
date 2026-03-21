import 'package:flutter/material.dart';
import '../../models/content_model.dart';
import '../../services/content_service.dart';
import '../../widgets/content_card.dart';

class BaseContentListScreen extends StatefulWidget {
  final String title;
  final String contentType;

  const BaseContentListScreen({
    super.key,
    required this.title,
    required this.contentType,
  });

  @override
  State<BaseContentListScreen> createState() =>
      _BaseContentListScreenState();
}

class _BaseContentListScreenState extends State<BaseContentListScreen> {
  late Future<List<ContentModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentService().fetchByType(widget.contentType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: FutureBuilder<List<ContentModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No content available",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final content = snapshot.data![index];

              return ContentCard(
                content: content,
              );
            },
          );
        },
      ),
    );
  }
}
