import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../theme/app_theme.dart';

class PostCard extends StatelessWidget {
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

  bool get isLiked => post.likedBy.contains(currentUserId);
  bool get isAuthor => post.authorId == currentUserId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.surfaceContainerLow, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Author info + actions
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.surfaceContainerLow,
                backgroundImage: post.authorAvatar != null
                    ? NetworkImage(post.authorAvatar!)
                    : null,
                child: post.authorAvatar == null
                    ? Text(
                        post.authorName.isNotEmpty
                            ? post.authorName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(post.createdAt),
                      style: TextStyle(
                        color: AppTheme.outline,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  if (isAuthor)
                    PopupMenuItem(
                      onTap: onDelete,
                      child: const Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Xóa bài', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  if (!isAuthor)
                    PopupMenuItem(
                      onTap: onReport,
                      child: const Row(
                        children: [
                          Icon(Icons.flag, color: Colors.orange, size: 18),
                          SizedBox(width: 8),
                          Text('Báo cáo',
                              style: TextStyle(color: Colors.orange)),
                        ],
                      ),
                    ),
                ],
                child: Icon(Icons.more_vert, color: AppTheme.outline, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Topic badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '#${post.topic}',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Content
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Engagement stats
          Row(
            children: [
              Text(
                '${post.likes} lượt thích',
                style: TextStyle(
                  color: AppTheme.outline,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${post.comments} bình luận',
                style: TextStyle(
                  color: AppTheme.outline,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onLike,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isLiked ? Colors.red : AppTheme.outline,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Thích',
                          style: TextStyle(
                            color: isLiked ? Colors.red : AppTheme.outline,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onComment,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 18,
                          color: AppTheme.outline,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Bình luận',
                          style: TextStyle(
                            color: AppTheme.outline,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dateTime.day}/${dateTime.month}';
  }
}
