// ==========================================================
// DISCUSSION DETAIL SCREEN (FINAL FIXED - NO SIMPLIFICATION)
// Only fixes applied:
// - ESEA → verified icon
// - Safe author rendering
// - Minor UI polish
// ==========================================================

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/discussion_service.dart';
import '../../models/discussion_model.dart';
import '../../config/app_config.dart';
import 'discussion_comments_widget.dart';

class DiscussionDetailScreen extends StatefulWidget {
  final DiscussionModel discussion;
  final bool isModal;

  const DiscussionDetailScreen({
    super.key,
    required this.discussion,
    this.isModal = false,
  });

  @override
  State<DiscussionDetailScreen> createState() =>
      _DiscussionDetailScreenState();
}

class _DiscussionDetailScreenState
    extends State<DiscussionDetailScreen> {

  final DiscussionService _service = DiscussionService();

  bool _voting = false;
  List<int> _selectedIndexes = [];

  // ================= SUBMIT POLL =================
  Future<void> _submitVote() async {
    if (_selectedIndexes.isEmpty || _voting) return;

    setState(() => _voting = true);

    try {
      final res = await _service.votePoll(
        widget.discussion.id,
        _selectedIndexes,
      );

      Map<String, dynamic>? safePoll;
      if (res["poll_data"] is Map<String, dynamic>) {
        safePoll =
            Map<String, dynamic>.from(res["poll_data"]);
      }

      List<int>? parsedVote;
      final rawVote = res["poll_user_voted"];

      if (rawVote is List) {
        parsedVote = List<int>.from(rawVote);
      } else if (rawVote is int) {
        parsedVote = [rawVote];
      }

      setState(() {
        widget.discussion.pollData = safePoll;
        widget.discussion.pollUserVoted =
            parsedVote;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vote failed")),
      );
    }

    setState(() => _voting = false);
  }

  @override
  Widget build(BuildContext context) {

    final d = widget.discussion;
    final poll = d.pollData;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: widget.isModal
          ? null
          : AppBar(title: const Text("Discussion")),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ================= HEADER CARD =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    // TITLE
                    Text(
                      d.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // AUTHOR
                    Row(
                      children: [
                        Text(
                          d.authorName.isNotEmpty
                              ? d.authorName
                              : "User",
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey),
                        ),

                        // ✅ FIX: STAR ICON INSTEAD OF TEXT
                        if (d.isEseaMember)
                          Container(
                            margin:
                                const EdgeInsets.only(left: 6),
                            child: const Icon(
                              Icons.verified,
                              size: 16,
                              color: Color(0xFF0B5D4B),
                            ),
                          ),

                        const SizedBox(width: 6),

                        Text(
                          "• ${timeago.format(d.createdAt)}",
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // IMAGE
                    if (d.imageUrl != null &&
                        d.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            "${AppConfig.uploadsUrl}${d.imageUrl}",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // CONTENT
                    Text(d.content),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ================= POLL =================
              if (poll != null) _buildPoll(poll),

              const SizedBox(height: 20),

              // ================= COMMENTS =================
              const Text(
                "Comments",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              DiscussionCommentsWidget(
                  discussionId: d.id),
            ],
          ),
        ),
      ),
    );
  }

  // ================= POLL =================
  Widget _buildPoll(Map<String, dynamic> poll) {

    if (poll["options"] == null ||
        poll["options"] is! List) {
      return const SizedBox();
    }

    final options = List<Map<String, dynamic>>.from(
        (poll["options"] as List)
            .map((e) => Map<String, dynamic>.from(e)));

    final bool multiple = poll["multiple"] == true;
    final bool isQuiz = poll["quiz_mode"] == true;

    final totalVotes = options.fold<int>(
      0,
      (sum, opt) =>
          sum + ((opt["votes"] ?? 0) as int),
    );

    final alreadyVoted =
        widget.discussion.pollUserVoted != null &&
        widget.discussion.pollUserVoted!.isNotEmpty;

    bool userGotCorrect = false;

    if (isQuiz && alreadyVoted) {
      for (int i = 0; i < options.length; i++) {
        final isCorrect =
            options[i]["is_correct"] == true;

        final selected =
            widget.discussion.pollUserVoted!
                .contains(i);

        if (isCorrect && selected) {
          userGotCorrect = true;
        }
      }
    }

    return Column(
      children: [

        ...options.asMap().entries.map((entry) {

          final index = entry.key;
          final option = entry.value;

          final votes = (option["votes"] ?? 0) as int;

          final percentage =
              totalVotes == 0 ? 0.0 : votes / totalVotes;

          final selected = alreadyVoted
              ? widget.discussion.pollUserVoted!
                  .contains(index)
              : _selectedIndexes.contains(index);

          final isCorrect =
              option["is_correct"] == true;

          final text =
              (option["text"] ?? option["title"] ?? "")
                  .toString();

          Color borderColor = Colors.transparent;

          if (isQuiz && alreadyVoted) {
            if (isCorrect) {
              borderColor = Colors.green;
            } else if (selected && !isCorrect) {
              borderColor = Colors.red;
            }
          }

          return Container(
            margin:
                const EdgeInsets.symmetric(vertical: 6),
            height: 48,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(10),
              border:
                  Border.all(color: borderColor, width: 2),
            ),
            child: Stack(
              children: [

                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                if (alreadyVoted)
                  FractionallySizedBox(
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B5D4B),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12),
                  child: Row(
                    children: [

                      if (!alreadyVoted)
                        multiple
                            ? Checkbox(
                                value: selected,
                                onChanged: (val) {
                                  setState(() {
                                    if (selected) {
                                      _selectedIndexes.remove(index);
                                    } else {
                                      _selectedIndexes.add(index);
                                    }
                                  });
                                },
                              )
                            : Radio<int>(
                                value: index,
                                groupValue:
                                    _selectedIndexes.isEmpty
                                        ? null
                                        : _selectedIndexes.first,
                                onChanged: (val) {
                                  setState(() {
                                    _selectedIndexes = [index];
                                  });
                                },
                              ),

                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                              fontWeight:
                                  FontWeight.w600),
                        ),
                      ),

                      if (alreadyVoted)
                        Text(
                          "${(percentage * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),

        if (!alreadyVoted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _voting ? null : _submitVote,
              child: _voting
                  ? const CircularProgressIndicator()
                  : const Text("Vote"),
            ),
          ),

        if (alreadyVoted)
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text("$totalVotes votes",
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey)),
              if (isQuiz)
                Text(
                  userGotCorrect
                      ? "Correct Answer"
                      : "Wrong Answer",
                  style: TextStyle(
                    color: userGotCorrect
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}