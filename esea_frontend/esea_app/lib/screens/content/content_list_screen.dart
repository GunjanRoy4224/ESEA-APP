import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/content_model.dart';
import '../../widgets/content_card.dart';
import 'content_detail_screen.dart';
import '../../widgets/error_state_widget.dart';

class ContentListScreen extends StatefulWidget {
  final String title;
  final Future<List<dynamic>> Function() loader;

  const ContentListScreen({
    super.key,
    required this.title,
    required this.loader,
  });

  @override
  State<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends State<ContentListScreen> {
  late Future<List<ContentModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    try {
      await _future;
    } catch (_) {}
  }

  Future<List<ContentModel>> _load() async {
    final data = await widget.loader();
    return data.map((e) => ContentModel.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<ContentModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _shimmer();
          }

          if (snapshot.hasError) {
            return ErrorStateWidget(
              title: "Failed to load ${widget.title.toLowerCase()}",
              message: "Please check your connection.",
              onRetry: _refresh,
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text("No items available"));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return ContentCard(
                  content: item,
                  onTap: () {
                    // 👇 ALWAYS open detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContentDetailScreen(item: item),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _shimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 220,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
