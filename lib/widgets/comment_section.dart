import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../theme/app_theme.dart';

class CommentSection extends StatefulWidget {
  final String postId;
  final List<PostComment> comments;
  final String currentUserId;
  final String currentUserName;
  final Function(String content) onAddComment;
  final Function(String commentId) onDeleteComment;
  final bool isLoading;

  const CommentSection({
    super.key,
    required this.postId,
    required this.comments,
    required this.currentUserId,
    required this.currentUserName,
    required this.onAddComment,
    required this.onDeleteComment,
    this.isLoading = false,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  late TextEditingController _commentCtrl;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _commentCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _submitting = true);
    try {
      widget.onAddComment(text);
      _commentCtrl.clear();
      if (mounted) {
        setState(() => _submitting = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments list
        if (widget.comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Chưa có bình luận',
                style: TextStyle(
                  color: AppTheme.outline,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.comments.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final comment = widget.comments[index];
              final isAuthor = comment.authorId == widget.currentUserId;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.surfaceContainerLow,
                      child: Text(
                        comment.authorName.isNotEmpty
                            ? comment.authorName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  comment.authorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (isAuthor)
                                GestureDetector(
                                  onTap: () =>
                                      widget.onDeleteComment(comment.id),
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppTheme.outline,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment.content,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(comment.createdAt),
                            style: TextStyle(
                              color: AppTheme.outline,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),

        // Comment input
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.surfaceContainerLow,
              child: Text(
                widget.currentUserName.isNotEmpty
                    ? widget.currentUserName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _commentCtrl,
                enabled: !_submitting && !widget.isLoading,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Viết bình luận...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: AppTheme.outline,
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _submitting || widget.isLoading ? null : _submitComment,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _submitting || widget.isLoading
                      ? AppTheme.outline.withValues(alpha: 0.3)
                      : AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: _submitting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        size: 16,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ],
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
