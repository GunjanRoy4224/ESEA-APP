// ==========================================================
// Discussion Model (Reddit-Style Poll Ready)
// Supports:
// - Anonymous mode
// - Multiple answers
// - Quiz mode
// - Computed vote totals
// ==========================================================

class DiscussionModel {
  final int id;
  final String title;
  final String content;
  final String authorName;
  final bool isEseaMember;

  int upvotes;
  bool voted;
  int comments;

  final DateTime createdAt;
  final String? imageUrl;

  // ================= POLL SYSTEM =================
  Map<String, dynamic>? pollData;

  /// Stores selected indexes
  /// Example:
  /// Single: [1]
  /// Multiple: [0,2]
  List<int>? pollUserVoted;

  DiscussionModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.isEseaMember,
    this.upvotes = 0,
    this.comments = 0,
    required this.createdAt,
    this.voted = false,
    this.imageUrl,
    this.pollData,
    this.pollUserVoted,
  });

  // ==========================================================
  // FACTORY FROM JSON
  // ==========================================================
  // ==========================================================
  factory DiscussionModel.fromJson(Map<String, dynamic> json) {

  dynamic rawPoll = json["poll_data"];

  Map<String, dynamic>? safePoll;

  if (rawPoll == null) {
    safePoll = null;
  }
  // ✅ Correct new structure
  else if (rawPoll is Map<String, dynamic>) {
    safePoll = rawPoll;
  }
  // 🔥 Old broken structure (List)
  else if (rawPoll is List) {
    safePoll = {
      "options": rawPoll,
      "anonymous": false,
      "multiple": false,
      "quiz_mode": false,
      "expires_at": null,
    };
  }

  List<int>? parsedUserVote;

  final rawVote = json["poll_user_voted"];

  if (rawVote != null) {
    if (rawVote is List) {
      parsedUserVote = List<int>.from(rawVote);
    } else if (rawVote is int) {
      parsedUserVote = [rawVote];
    }
  }

  return DiscussionModel(
    id: json["id"],
    title: json["title"],
    content: json["content"],
    authorName: json["author_name"],
    isEseaMember: json["is_esea_member"],
    upvotes: json["upvotes_count"] ?? 0,
    comments: json["comments_count"] ?? 0,
    createdAt: DateTime.parse(json["created_at"]),
    voted: json["voted"] ?? false,
    imageUrl: json["image_url"],
    pollData: safePoll,
    pollUserVoted: parsedUserVote,
  );
 }
 }