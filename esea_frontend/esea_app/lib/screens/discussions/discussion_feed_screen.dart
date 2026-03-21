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
import '../../config/app_config.dart';
import 'create_discussion_sheet.dart';
import 'discussion_detail_screen.dart';

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

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;

    setState(() => _loading = true);

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
      setState(() => _loading = false);
    } catch (e) {
      print("UNKNOWN ERROR: $e");
      setState(() => _loading = false);
    }
  }

  void _resetAndReload() {
    setState(() {
      _page = 1;
      _discussions.clear();
      _hasMore = true;
    });
    _loadMore();
  }

  Future<void> _toggleVote(DiscussionModel d) async {
    final res = await _service.toggleVote(d.id);

    setState(() {
      d.voted = res["voted"];
      d.upvotes = res["upvotes"];
    });
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

      body: _discussions.isEmpty && !_loading
          ? const Center(
              child: Text(
                "No discussions yet",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => _resetAndReload(),
              child: ListView.builder(
                controller: _scrollController,
                itemCount:
                    _discussions.length + (_loading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _discussions.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                          child:
                              CircularProgressIndicator()),
                    );
                  }

                  final d = _discussions[index];

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DiscussionDetailScreen(
                                  discussion: d),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          _buildHeader(d),
                          const SizedBox(height: 10),
                          _buildTitle(d),
                          const SizedBox(height: 6),
                          _buildContent(d),
                          const SizedBox(height: 10),
                          _buildImage(d),

                          // ✅ FIX: show poll ONLY if user voted
                          if (d.pollUserVoted != null &&
                              d.pollUserVoted!.isNotEmpty)
                            _buildPollPreview(d),

                          const SizedBox(height: 12),
                          _buildActions(d),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildHeader(DiscussionModel d) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFFE3F2EF),
          child: Text(
            d.authorName.isNotEmpty
                ? d.authorName[0]
                : "?",
            style: const TextStyle(
              color: Color(0xFF0B5D4B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),

        Row(
          children: [
            Text(
              d.authorName.isNotEmpty ? d.authorName : "User",
              style:
                  const TextStyle(fontWeight: FontWeight.w600),
            ),

            // ✅ FIX: VERIFIED ICON
            if (d.isEseaMember)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.verified,
                  size: 16,
                  color: Color(0xFF0B5D4B),
                ),
              ),
          ],
        ),

        const Spacer(),

        Text(
          timeago.format(d.createdAt),
          style:
              const TextStyle(fontSize: 12, color: Colors.grey),
        )
      ],
    );
  }

  Widget _buildTitle(DiscussionModel d) {
    return Text(
      d.title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildContent(DiscussionModel d) {
    return Text(
      d.content,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildImage(DiscussionModel d) {
    if (d.imageUrl == null || d.imageUrl!.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            "${AppConfig.uploadsUrl}${d.imageUrl}",
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildPollPreview(DiscussionModel d) {
    final poll = d.pollData;

    if (poll == null) return const SizedBox();

    final options = List<Map<String, dynamic>>.from(
        (poll["options"] as List));

    final totalVotes = options.fold<int>(
      0,
      (sum, opt) => sum + (opt["votes"] ?? 0) as int,
    );

    return Column(
      children: options.map((option) {
        final votes = option["votes"] ?? 0;
        final percentage =
            totalVotes == 0 ? 0.0 : votes / totalVotes;

        final text =
            (option["text"] ?? option["title"] ?? "")
                .toString();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          height: 40,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B5D4B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(child: Text(text)),
                    Text(
                      "${(percentage * 100).toStringAsFixed(0)}%",
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions(DiscussionModel d) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _toggleVote(d),
          child: Row(
            children: [
              Icon(
                Icons.thumb_up,
                color: d.voted
                    ? const Color(0xFF0B5D4B)
                    : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(d.upvotes.toString()),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Row(
          children: [
            const Icon(Icons.chat_bubble_outline, size: 18),
            const SizedBox(width: 6),
            Text(d.comments.toString()),
          ],
        )
      ],
    );
  }
}