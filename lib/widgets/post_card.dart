import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../theme/app_theme.dart';

class PostCard extends StatefulWidget {
  final CommunityPost post;
  final String currentUserId;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    required this.onDelete,
    required this.onReport,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeController;
  late Animation<double> _likeScale;

  bool get isLiked => widget.post.likedBy.contains(widget.currentUserId);
  bool get isAuthor => widget.post.authorId == widget.currentUserId;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeScale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _handleLike() {
    _likeController.forward(from: 0);
    widget.onLike();
  }

  static const _topicIcons = {
    'tips': Icons.lightbulb_outline,
    'help': Icons.help_outline,
    'share': Icons.share_outlined,
    'all': Icons.public,
  };

  static const _topicLabels = {
    'all': 'Tất cả',
    'tips': 'Mẹo hay',
    'help': 'Hỏi đáp',
    'share': 'Chia sẻ',
  };

  static final _topicGradients = {
    'tips': const [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    'help': const [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    'share': const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    'all': const [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
  };

  static final _topicColors = {
    'tips': const Color(0xFFE65100),
    'help': const Color(0xFF1565C0),
    'share': const Color(0xFF2E7D32),
    'all': const Color(0xFF6A1B9A),
  };

  @override
  Widget build(BuildContext context) {
    final topicColor = _topicColors[widget.post.topic] ?? AppTheme.primary;
    final topicGradient =
        _topicGradients[widget.post.topic] ?? [Colors.grey.shade100, Colors.grey.shade200];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: topicColor.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header with gradient accent ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    topicGradient[0].withValues(alpha: 0.5),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  // Avatar with ring
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [topicColor, topicColor.withValues(alpha: 0.4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: topicGradient[0],
                        backgroundImage: widget.post.authorAvatar != null
                            ? NetworkImage(widget.post.authorAvatar!)
                            : null,
                        child: widget.post.authorAvatar == null
                            ? Text(
                                widget.post.authorName.isNotEmpty
                                    ? widget.post.authorName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: topicColor,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 12, color: AppTheme.outline),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(widget.post.createdAt),
                              style: TextStyle(
                                color: AppTheme.outline,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.circle, size: 3, color: AppTheme.outline),
                            const SizedBox(width: 8),
                            // Topic badge inline
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: topicColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _topicIcons[widget.post.topic] ??
                                        Icons.public,
                                    size: 10,
                                    color: topicColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _topicLabels[widget.post.topic] ??
                                        widget.post.topic,
                                    style: TextStyle(
                                      color: topicColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // More menu
                  PopupMenuButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    itemBuilder: (context) => [
                      if (isAuthor)
                        PopupMenuItem(
                          onTap: widget.onDelete,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.delete_outline,
                                    color: Colors.red.shade400, size: 16),
                              ),
                              const SizedBox(width: 10),
                              Text('Xóa bài',
                                  style: TextStyle(
                                      color: Colors.red.shade400,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      if (!isAuthor)
                        PopupMenuItem(
                          onTap: widget.onReport,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.flag_outlined,
                                    color: Colors.orange.shade400, size: 16),
                              ),
                              const SizedBox(width: 10),
                              Text('Báo cáo',
                                  style: TextStyle(
                                      color: Colors.orange.shade400,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.more_horiz,
                          color: AppTheme.outline, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                widget.post.content,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.6,
                  color: Colors.black87,
                  letterSpacing: -0.1,
                ),
              ),
            ),

            // ── Engagement stats ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (widget.post.likes > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade400,
                            Colors.pink.shade300,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite,
                          size: 10, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.post.likes}',
                      style: TextStyle(
                        color: AppTheme.outline,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (widget.post.comments > 0)
                    Text(
                      '${widget.post.comments} bình luận',
                      style: TextStyle(
                        color: AppTheme.outline,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            // ── Divider ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(
                height: 1,
                color: Colors.grey.shade200,
              ),
            ),

            // ── Actions ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: Row(
                children: [
                  // Like button
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _handleLike,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ScaleTransition(
                                scale: _likeScale,
                                child: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 20,
                                  color:
                                      isLiked ? Colors.red : AppTheme.outline,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Thích',
                                style: TextStyle(
                                  color:
                                      isLiked ? Colors.red : AppTheme.outline,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Comment button
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: widget.onComment,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 19,
                                color: AppTheme.outline,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Bình luận',
                                style: TextStyle(
                                  color: AppTheme.outline,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    if (diff.inDays < 7) return '${diff.inDays} ngày';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
