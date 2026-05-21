import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/community_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/comment_section.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _topics = ['all', 'tips', 'help', 'share'];
  final _topicLabels = ['🌐 Tất cả', '💡 Mẹo hay', '❓ Hỏi đáp', '🔗 Chia sẻ'];
  final _topicColors = [
    const Color(0xFF6A1B9A),
    const Color(0xFFE65100),
    const Color(0xFF1565C0),
    const Color(0xFF2E7D32),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CommunityProvider>();
    });
  }

  void _openCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePostSheet(
        onPost: (content, topic) async {
          final authProvider = context.read<AuthProvider>();
          final communityProvider = context.read<CommunityProvider>();
          if (authProvider.currentUser != null) {
            await communityProvider.createPost(
              authorId: authProvider.currentUser!.id,
              authorName: authProvider.currentUser!.fullName,
              authorAvatar: authProvider.currentUser!.avatarUrl,
              content: content,
              topic: topic,
            );
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Đã đăng bài thành công!'),
                    ],
                  ),
                  backgroundColor: AppTheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Premium Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cộng đồng',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chia sẻ & kết nối cùng mọi người',
                        style: TextStyle(
                          color: AppTheme.outline,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _openCreatePost,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary,
                            AppTheme.primaryContainer,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_note, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Đăng bài',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Topic chips ──
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
              child: SizedBox(
                height: 42,
                child: Consumer<CommunityProvider>(
                  builder: (ctx, provider, _) => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _topics.length,
                    itemBuilder: (_, i) {
                      final sel = provider.selectedTopic == _topics[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => provider.setTopic(_topics[i]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 9),
                            decoration: BoxDecoration(
                              gradient: sel
                                  ? LinearGradient(colors: [
                                      _topicColors[i],
                                      _topicColors[i].withValues(alpha: 0.7),
                                    ])
                                  : null,
                              color: sel ? null : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: sel
                                  ? null
                                  : Border.all(color: Colors.grey.shade300),
                              boxShadow: sel
                                  ? [
                                      BoxShadow(
                                        color: _topicColors[i]
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              _topicLabels[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    sel ? FontWeight.w600 : FontWeight.w500,
                                color: sel
                                    ? Colors.white
                                    : AppTheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Posts list with pull-to-refresh ──
            Expanded(
              child: Consumer2<CommunityProvider, AuthProvider>(
                builder: (ctx, communityProvider, authProvider, _) {
                  if (communityProvider.isLoading) {
                    return _buildLoadingShimmer();
                  }

                  if (communityProvider.posts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.forum_outlined,
                                size: 48,
                                color:
                                    AppTheme.primary.withValues(alpha: 0.5)),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có bài viết nào',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hãy là người đầu tiên chia sẻ!',
                            style: TextStyle(
                              color: AppTheme.outline,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: communityProvider.refreshPosts,
                    color: AppTheme.primary,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.only(top: 4, bottom: 24),
                      itemCount: communityProvider.posts.length,
                      itemBuilder: (_, i) {
                        final post = communityProvider.posts[i];
                        return PostCard(
                          post: post,
                          currentUserId:
                              authProvider.currentUser?.id ?? '',
                          onLike: () async {
                            await communityProvider.toggleLike(
                              post.id,
                              authProvider.currentUser?.id ?? '',
                            );
                          },
                          onComment: () {
                            _showCommentsBottomSheet(
                              post,
                              authProvider,
                              communityProvider,
                            );
                          },
                          onDelete: () async {
                            await communityProvider.deletePost(post.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Đã xóa bài viết'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            }
                          },
                          onReport: () {
                            _showReportDialog(post, communityProvider);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _shimmerBox(44, 44, isCircle: true),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(120, 12),
                    const SizedBox(height: 6),
                    _shimmerBox(80, 10),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _shimmerBox(double.infinity, 12),
            const SizedBox(height: 8),
            _shimmerBox(200, 12),
            const SizedBox(height: 8),
            _shimmerBox(150, 12),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double width, double height, {bool isCircle = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: isCircle ? null : BorderRadius.circular(6),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }

  void _showCommentsBottomSheet(
    dynamic post,
    AuthProvider authProvider,
    CommunityProvider communityProvider,
  ) {
    communityProvider.watchComments(post.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                  child: Row(
                    children: [
                      const Text(
                        'Bình luận',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Consumer<CommunityProvider>(
                        builder: (_, p, __) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${p.currentPostComments.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Consumer<CommunityProvider>(
                    builder: (ctx, provider, _) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: CommentSection(
                          postId: post.id,
                          postAuthorId: post.authorId,
                          comments: provider.currentPostComments,
                          currentUserId:
                              authProvider.currentUser?.id ?? '',
                          currentUserName:
                              authProvider.currentUser?.fullName ?? '',
                          onAddComment: (content,
                              {String? imageUrl,
                              String? replyToId,
                              String? replyToName}) async {
                            await provider.addComment(
                              postId: post.id,
                              authorId:
                                  authProvider.currentUser?.id ?? '',
                              authorName:
                                  authProvider.currentUser?.fullName ?? '',
                              content: content,
                              imageUrl: imageUrl,
                              replyToId: replyToId,
                              replyToName: replyToName,
                            );
                          },
                          onDeleteComment: (commentId) async {
                            await provider.deleteComment(
                                post.id, commentId);
                          },
                          onReact: (commentId, emoji) async {
                            await provider.toggleCommentReaction(
                              post.id,
                              commentId,
                              emoji,
                              authProvider.currentUser?.id ?? '',
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showReportDialog(
      dynamic post, CommunityProvider communityProvider) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(Icons.flag_outlined, color: Colors.orange.shade400, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Báo cáo bài viết',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Lý do báo cáo...',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy',
                style: TextStyle(color: AppTheme.outline)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              await communityProvider.reportPost(
                post.id,
                authProvider.currentUser?.id ?? '',
                reasonCtrl.text,
              );
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Đã gửi báo cáo'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            child: const Text('Gửi báo cáo'),
          ),
        ],
      ),
    );
  }
}

// ─── Create Post Sheet ────────────────────────────────────────────

class _CreatePostSheet extends StatefulWidget {
  final Function(String content, String topic) onPost;

  const _CreatePostSheet({required this.onPost});

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _contentCtrl = TextEditingController();
  String _selectedTopic = 'all';
  bool _posting = false;

  final _chipData = [
    {'value': 'all', 'label': '🌐 Tất cả'},
    {'value': 'tips', 'label': '💡 Mẹo hay'},
    {'value': 'help', 'label': '❓ Hỏi đáp'},
    {'value': 'share', 'label': '🔗 Chia sẻ'},
  ];

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text('Tạo bài viết mới',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Chia sẻ suy nghĩ với cộng đồng',
              style: TextStyle(color: AppTheme.outline, fontSize: 13)),
          const SizedBox(height: 20),
          TextField(
            controller: _contentCtrl,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Bạn đang nghĩ gì?',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Chủ đề',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _chipData.map((chip) {
              final selected = _selectedTopic == chip['value'];
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedTopic = chip['value']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primary
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color:
                                  AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    chip['label']!,
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _posting
                  ? null
                  : () {
                      if (_contentCtrl.text.trim().isNotEmpty) {
                        setState(() => _posting = true);
                        widget.onPost(
                          _contentCtrl.text.trim(),
                          _selectedTopic,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _posting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Đăng bài',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
