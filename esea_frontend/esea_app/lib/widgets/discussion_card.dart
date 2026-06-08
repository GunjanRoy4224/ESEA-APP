import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../models/discussion_model.dart';
import '../services/discussion_service.dart';
import '../config/app_config.dart';
import '../screens/discussions/discussion_detail_screen.dart';

class DiscussionCard extends StatefulWidget {
  final DiscussionModel discussion;

  const DiscussionCard({super.key, required this.discussion});

  @override
  State<DiscussionCard> createState() => _DiscussionCardState();
}

class _DiscussionCardState extends State<DiscussionCard> with SingleTickerProviderStateMixin {
  final DiscussionService _service = DiscussionService();
  late AnimationController _voteAnimController;

  @override
  void initState() {
    super.initState();
    _voteAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 1.0,
      upperBound: 1.3,
    );
  }

  @override
  void dispose() {
    _voteAnimController.dispose();
    super.dispose();
  }

  Future<void> _toggleVote() async {
    _voteAnimController.forward().then((_) => _voteAnimController.reverse());
    
    try {
      final res = await _service.toggleVote(widget.discussion.id);
      if (mounted) {
        setState(() {
          widget.discussion.voted = res["voted"];
          widget.discussion.upvotes = res["upvotes"];
        });
      }
    } catch (e) {
      debugPrint("Vote failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.discussion;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiscussionDetailScreen(discussion: d),
          ),
        ).then((_) {
          if (mounted) setState(() {});
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4), // Flat against edges or list
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1.0),
          ), // Reddit/LinkedIn style dividers instead of full cards
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(d),
            const SizedBox(height: 12),
            _buildTitle(d),
            const SizedBox(height: 8),
            _buildContent(d),
            const SizedBox(height: 12),
            _buildImage(d),
            if (d.pollUserVoted != null && d.pollUserVoted!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildPollPreview(d),
            ],
            const SizedBox(height: 16),
            _buildActions(d),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DiscussionModel d) {
    // Determine badge based on tags or other properties
    // We assume if isEseaMember it's verified, we could also use tags for alumni/student
    final bool isAlumni = d.tags.contains("alumni");
    
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade100,
          backgroundImage: d.authorPhotoUrl != null ? NetworkImage(d.authorPhotoUrl!) : null,
          child: d.authorPhotoUrl == null
              ? Text(
                  d.authorName.isNotEmpty ? d.authorName[0] : "?",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    d.authorName.isNotEmpty ? d.authorName : "User",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  if (d.isEseaMember) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, size: 16, color: Color(0xFF0B5D4B)),
                  ],
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAlumni ? Colors.blue.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isAlumni ? "Alumni" : "Student",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isAlumni ? Colors.blue.shade700 : Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                timeago.format(d.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(DiscussionModel d) {
    return Text(
      d.title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.2),
    );
  }

  Widget _buildContent(DiscussionModel d) {
    return Text(
      d.content,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
    );
  }

  Widget _buildImage(DiscussionModel d) {
    if (d.imageUrl == null || d.imageUrl!.isEmpty) {
      return const SizedBox();
    }
    return Hero(
      tag: 'discussion_img_${d.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            imageUrl: d.imageUrl!.startsWith('http')
                ? d.imageUrl!
                : "${AppConfig.uploadsUrl}${d.imageUrl}",
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey.shade100),
          ),
        ),
      ),
    );
  }

  Widget _buildPollPreview(DiscussionModel d) {
    final poll = d.pollData;
    if (poll == null) return const SizedBox();

    final options = List<Map<String, dynamic>>.from((poll["options"] as List));
    final totalVotes = options.fold<int>(
      0,
      (sum, opt) => sum + (opt["votes"] ?? 0) as int,
    );

    return Column(
      children: options.map((option) {
        final votes = option["votes"] ?? 0;
        final percentage = totalVotes == 0 ? 0.0 : votes / totalVotes;
        final text = (option["text"] ?? option["title"] ?? "").toString();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          height: 36,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                width: MediaQuery.of(context).size.width * percentage,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B5D4B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                    Text("${(percentage * 100).toStringAsFixed(0)}%", style: const TextStyle(fontSize: 13, color: Colors.black54)),
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
          onTap: _toggleVote,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: d.voted ? const Color(0xFFE3F2EF) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                ScaleTransition(
                  scale: _voteAnimController,
                  child: Icon(
                    Icons.thumb_up_rounded,
                    size: 18,
                    color: d.voted ? const Color(0xFF0B5D4B) : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  d.upvotes.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: d.voted ? const Color(0xFF0B5D4B) : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                d.comments.toString(),
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
            ],
          ),
        )
      ],
    );
  }
}
