import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/community_post.dart';
import '../theme/app_theme.dart';

class CommentSection extends StatefulWidget {
  final String postId;
  final String postAuthorId;
  final List<PostComment> comments;
  final String currentUserId;
  final String currentUserName;
  final Function(String content, {String? imageUrl, String? replyToId, String? replyToName}) onAddComment;
  final Function(String commentId) onDeleteComment;
  final Function(String commentId, String emoji) onReact;
  final bool isLoading;

  const CommentSection({
    super.key,
    required this.postId,
    required this.postAuthorId,
    required this.comments,
    required this.currentUserId,
    required this.currentUserName,
    required this.onAddComment,
    required this.onDeleteComment,
    required this.onReact,
    this.isLoading = false,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  late TextEditingController _commentCtrl;
  bool _submitting = false;
  bool _uploadingImage = false;
  String? _replyToId;
  String? _replyToName;
  String? _pendingImageUrl;

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

  void _setReply(String commentId, String authorName) {
    setState(() {
      _replyToId = commentId;
      _replyToName = authorName;
    });
    _commentCtrl.clear();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _clearReply() {
    setState(() {
      _replyToId = null;
      _replyToName = null;
    });
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;
    final file = File(result.files.single.path!);

    setState(() => _uploadingImage = true);
    try {
      final ref = FirebaseStorage.instance
          .ref('comment_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      setState(() => _pendingImageUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải ảnh: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  void _removeImage() => setState(() => _pendingImageUrl = null);

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty && _pendingImageUrl == null) return;

    setState(() => _submitting = true);
    try {
      widget.onAddComment(
        text,
        imageUrl: _pendingImageUrl,
        replyToId: _replyToId,
        replyToName: _replyToName,
      );
      _commentCtrl.clear();
      _clearReply();
      setState(() => _pendingImageUrl = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  bool _canDelete(PostComment comment) {
    return comment.authorId == widget.currentUserId ||
        widget.postAuthorId == widget.currentUserId;
  }

  void _showReactionPicker(String commentId) {
    const emojis = ['❤️', '😂', '😮', '😢', '😡', '👍'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: emojis.map((emoji) {
            return GestureDetector(
              onTap: () {
                widget.onReact(commentId, emoji);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 40, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text('Chưa có bình luận',
                      style: TextStyle(color: AppTheme.outline, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Hãy là người đầu tiên bình luận!',
                      style: TextStyle(
                          color: AppTheme.outline.withValues(alpha: 0.6),
                          fontSize: 11)),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.comments.length,
            itemBuilder: (context, index) {
              final comment = widget.comments[index];
              return _buildCommentTile(comment);
            },
          ),

        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 8),

        // Reply indicator
        if (_replyToName != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.reply, size: 14, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text('Đang trả lời ',
                    style: TextStyle(fontSize: 12, color: AppTheme.outline)),
                Text(_replyToName!,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary)),
                const Spacer(),
                GestureDetector(
                  onTap: _clearReply,
                  child: Icon(Icons.close, size: 16, color: AppTheme.outline),
                ),
              ],
            ),
          ),

        // Pending image preview
        if (_pendingImageUrl != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: _pendingImageUrl!,
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: _removeImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Input
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              child: Text(
                widget.currentUserName.isNotEmpty
                    ? widget.currentUserName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppTheme.primary),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    // Image picker button
                    GestureDetector(
                      onTap: _uploadingImage ? null : _pickImage,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: _uploadingImage
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.image_outlined,
                                size: 22, color: AppTheme.primary),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _commentCtrl,
                        enabled: !_submitting && !widget.isLoading,
                        maxLines: null,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: _replyToName != null
                              ? 'Trả lời $_replyToName...'
                              : 'Viết bình luận...',
                          hintStyle:
                              TextStyle(color: AppTheme.outline, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _submitting || widget.isLoading ? null : _submitComment,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryContainer],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded,
                        size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentTile(PostComment comment) {
    final isReply = comment.replyToName != null && comment.replyToName!.isNotEmpty;

    return GestureDetector(
      onLongPress: () => _showReactionPicker(comment.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: EdgeInsets.only(left: isReply ? 40 : 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: isReply ? 14 : 16,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              child: Text(
                comment.authorName.isNotEmpty
                    ? comment.authorName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isReply ? 10 : 12,
                    color: AppTheme.primary),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Comment bubble
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                        topLeft: Radius.circular(4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(comment.authorName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 12)),
                            if (comment.authorId == widget.postAuthorId) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Tác giả',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primary)),
                              ),
                            ],
                          ],
                        ),
                        if (isReply) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.reply,
                                  size: 12, color: AppTheme.outline),
                              const SizedBox(width: 4),
                              Text('${comment.replyToName}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                        if (comment.content.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(comment.content,
                              style: const TextStyle(
                                  fontSize: 13, height: 1.4)),
                        ],
                        // Image in comment
                        if (comment.imageUrl != null &&
                            comment.imageUrl!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: comment.imageUrl!,
                              width: 200,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 200,
                                height: 120,
                                color: Colors.grey.shade200,
                                child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Reactions display
                  if (comment.reactions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Wrap(
                        spacing: 4,
                        children: comment.reactions.entries.map((e) {
                          final isReacted = e.value.contains(widget.currentUserId);
                          return GestureDetector(
                            onTap: () => widget.onReact(comment.id, e.key),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isReacted
                                    ? AppTheme.primary.withValues(alpha: 0.15)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                                border: isReacted
                                    ? Border.all(
                                        color: AppTheme.primary
                                            .withValues(alpha: 0.3))
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(e.key,
                                      style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 2),
                                  Text('${e.value.length}',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: isReacted
                                              ? AppTheme.primary
                                              : AppTheme.outline,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // Action row
                  Row(
                    children: [
                      Text(_formatTime(comment.createdAt),
                          style:
                              TextStyle(color: AppTheme.outline, fontSize: 11)),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () =>
                            _showReactionPicker(comment.id),
                        child: Text('Thích',
                            style: TextStyle(
                                color: AppTheme.outline,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () =>
                            _setReply(comment.id, comment.authorName),
                        child: Text('Trả lời',
                            style: TextStyle(
                                color: AppTheme.outline,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      if (_canDelete(comment))
                        GestureDetector(
                          onTap: () =>
                              widget.onDeleteComment(comment.id),
                          child: Icon(Icons.delete_outline,
                              size: 14,
                              color: Colors.red.shade300),
                        ),
                    ],
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
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dateTime.day}/${dateTime.month}';
  }
}
