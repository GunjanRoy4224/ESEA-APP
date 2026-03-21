// ==========================================================
// DISCUSSION COMMENTS WIDGET (FINAL - REDDIT STYLE)
// Features:
// - Nested replies
// - Add comment
// - Add reply
// - Clean UI
// ==========================================================

import 'package:flutter/material.dart';
import '../../services/discussion_service.dart';

// ================= MODEL =================
class CommentNode {
  final Map data;
  final List<CommentNode> children;

  CommentNode({
    required this.data,
    required this.children,
  });
}

class DiscussionCommentsWidget extends StatefulWidget {
  final int discussionId;

  const DiscussionCommentsWidget({
    super.key,
    required this.discussionId,
  });

  @override
  State<DiscussionCommentsWidget> createState() =>
      _DiscussionCommentsWidgetState();
}

class _DiscussionCommentsWidgetState
    extends State<DiscussionCommentsWidget> {

  final DiscussionService _service = DiscussionService();

  List<CommentNode> _tree = [];
  bool _loading = true;

  final TextEditingController _commentController =
      TextEditingController();

  int? _replyingTo; // comment id
  final TextEditingController _replyController =
      TextEditingController();

  // ==========================================================
  // LOAD COMMENTS
  // ==========================================================
  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final raw =
          await _service.fetchComments(widget.discussionId);

      final map = <int, CommentNode>{};

      // create nodes
      for (final c in raw) {
        map[c["id"]] = CommentNode(
          data: c,
          children: [],
        );
      }

      // build tree
      for (final c in raw) {
        final parent = c["parent_id"];

        if (parent != null && map.containsKey(parent)) {
          map[parent]!.children.add(map[c["id"]]!);
        }
      }

      // root nodes
      _tree = map.values
          .where((n) => n.data["parent_id"] == null)
          .toList();

    } catch (e) {
      print("COMMENT LOAD ERROR: $e");
    }

    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ==========================================================
  // ADD COMMENT
  // ==========================================================
  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    await _service.addComment(
      widget.discussionId,
      text,
    );

    _commentController.clear();
    _load();
  }

  // ==========================================================
  // ADD REPLY
  // ==========================================================
  Future<void> _addReply(int parentId) async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    await _service.addComment(
      widget.discussionId,
      text,
      parentId: parentId,
    );

    _replyController.clear();
    _replyingTo = null;
    _load();
  }

  // ==========================================================
  // UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ================= ADD COMMENT =================
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: "Add a comment...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addComment,
              child: const Text("Post"),
            )
          ],
        ),

        const SizedBox(height: 16),

        // ================= COMMENTS =================
        if (_tree.isEmpty)
          const Text(
            "No comments yet",
            style: TextStyle(color: Colors.grey),
          ),

        ..._tree.map((node) => _buildNode(node, 0)),
      ],
    );
  }

  // ==========================================================
  // BUILD NODE (RECURSIVE)
  // ==========================================================
  Widget _buildNode(CommentNode node, int depth) {

    final data = node.data;

    return Padding(
      padding: EdgeInsets.only(
        left: depth * 14,
        top: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= COMMENT CARD =================
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  data["author_name"] ?? "User",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(data["content"] ?? ""),

                const SizedBox(height: 6),

                Row(
                  children: [

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _replyingTo = data["id"];
                        });
                      },
                      child: const Text(
                        "Reply",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= REPLY INPUT =================
          if (_replyingTo == data["id"])
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      decoration: const InputDecoration(
                        hintText: "Write a reply...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    onPressed: () =>
                        _addReply(data["id"]),
                    child: const Text("Send"),
                  ),
                ],
              ),
            ),

          // ================= CHILDREN =================
          ...node.children
              .map((child) => _buildNode(child, depth + 1)),
        ],
      ),
    );
  }
}