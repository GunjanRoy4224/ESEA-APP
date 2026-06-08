// ==========================================================
// DISCUSSION FEED SCREEN (FINAL FIXED - NO SIMPLIFICATION)
// FIXES:
// - Hide poll preview until user votes
// - ESEA → verified icon
// - Safe rendering
// ==========================================================

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:dio/dio.dart';
import '../../models/discussion_model.dart';
import '../../services/discussion_service.dart';
import '../../widgets/discussion_card.dart';
import '../../config/app_config.dart';
import 'create_discussion_sheet.dart';
import 'discussion_detail_screen.dart';
import '../../widgets/error_state_widget.dart';
import 'package:shimmer/shimmer.dart';

class DiscussionFeedScreen extends StatefulWidget {
  const DiscussionFeedScreen({super.key});

  @override
  State<DiscussionFeedScreen> createState() =>
      _DiscussionFeedScreenState();
}

class _DiscussionFeedScreenState extends State<DiscussionFeedScreen> {
  final DiscussionService _service = DiscussionService();
  final ScrollController _scrollController = ScrollController();

  final List<DiscussionModel> _discussions = [];

  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String _sort = "new";
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;

    setState(() {
      _loading = true;
      if (_page == 1) _error = null;
    });

    try {
      final newData =
          await _service.fetchDiscussions(
              page: _page, sort: _sort);

      setState(() {
        if (newData.isEmpty) {
          _hasMore = false;
        } else {
          _discussions.addAll(newData);
          _page++;
        }
        _loading = false;
      });

    } on DioException catch (e) {
      print("🔥 API ERROR: ${e.response?.statusCode}");
      setState(() {
        _loading = false;
        if (_page == 1) _error = e.toString();
      });
    } catch (e) {
      print("UNKNOWN ERROR: $e");
      setState(() {
        _loading = false;
        if (_page == 1) _error = e.toString();
      });
    }
  }

  void _resetAndReload() {
    setState(() {
      _page = 1;
      _discussions.clear();
      _hasMore = true;
      _error = null;
    });
    _loadMore();
  }

  Widget _buildSortButton(String label) {
    final value = label.toLowerCase();
    final selected = _sort == value;

    return GestureDetector(
      onTap: () {
        setState(() => _sort = value);
        _resetAndReload();
      },
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selected
              ? const Color(0xFF0B5D4B)
              : Colors.grey,
        ),
      ),
    );
  }

  void _openCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CreateDiscussionSheet(
        onPostSuccess: _resetAndReload,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: const Text("Discussion"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSortButton("New"),
                const SizedBox(width: 24),
                _buildSortButton("Top"),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateSheet,
        child: const Icon(Icons.add),
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _page == 1 && _discussions.isEmpty) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.builder(
          itemCount: 4,
          padding: const EdgeInsets.all(12),
          itemBuilder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }

    if (_error != null && _discussions.isEmpty) {
      return ErrorStateWidget(
        title: "Couldn't load discussions",
        message: "Please check your connection.",
        onRetry: _resetAndReload,
      );
    }

    if (_discussions.isEmpty && !_loading) {
      return const Center(
        child: Text(
          "No discussions yet",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _resetAndReload(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _discussions.length + (_loading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _discussions.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final d = _discussions[index];

          return DiscussionCard(discussion: d);
        },
      ),
    );
  }
}
}