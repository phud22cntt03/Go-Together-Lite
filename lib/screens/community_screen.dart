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
  final _topicLabels = ['Tất cả', 'Mẹo hay', 'Hỏi đáp', 'Chia sẻ'];

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
                  content: const Text('Đã đăng bài thành công!'),
                  backgroundColor: AppTheme.primary,
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Cộng đồng',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _openCreatePost,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: AppTheme.radiusFull,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, color: Colors.white, size: 16),
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

            // Topic chips
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
              child: SizedBox(
                height: 38,
                child: Consumer<CommunityProvider>(
                  builder: (ctx, provider, _) => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _topics.length,
                    itemBuilder: (_, i) {
                      final sel = provider.selectedTopic == _topics[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => provider.setTopic(_topics[i]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppTheme.primary
                                  : AppTheme.surfaceContainerLow,
                              borderRadius: AppTheme.radiusFull,
                              border: Border.all(
                                color: sel
                                    ? AppTheme.primary
                                    : AppTheme.outlineVariant
                                        .withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              _topicLabels[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color:
                                    sel ? Colors.white : AppTheme.onSurface,
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

            // Posts list
            Expanded(
              child: Consumer2<CommunityProvider, AuthProvider>(
                builder: (ctx, communityProvider, authProvider, _) {
                  if (communityProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (communityProvider.posts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.article_outlined,
                              size: 48, color: AppTheme.outline),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có bài viết',
                            style: TextStyle(
                              color: AppTheme.outline,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: communityProvider.posts.length,
                    itemBuilder: (_, i) {
                      final post = communityProvider.posts[i];
                      return PostCard(
                        post: post,
                        currentUserId: authProvider.currentUser?.id ?? '',
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
                              const SnackBar(
                                  content: Text('Đã xóa bài viết')),
                            );
                          }
                        },
                        onReport: () {
                          _showReportDialog(post, communityProvider);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(
    post,
    AuthProvider authProvider,
    CommunityProvider communityProvider,
  ) {
    communityProvider.watchComments(post.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Bình luận',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<CommunityProvider>(
                    builder: (ctx, provider, _) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CommentSection(
                            postId: post.id,
                            comments: provider.currentPostComments,
                            currentUserId: authProvider.currentUser?.id ?? '',
                            currentUserName:
                                authProvider.currentUser?.fullName ?? '',
                            onAddComment: (content) async {
                              await provider.addComment(
                                postId: post.id,
                                authorId: authProvider.currentUser?.id ?? '',
                                authorName:
                                    authProvider.currentUser?.fullName ?? '',
                                content: content,
                              );
                            },
                            onDeleteComment: (commentId) async {
                              await provider.deleteComment(
                                post.id,
                                commentId,
                              );
                            },
                          ),
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

  void _showReportDialog(post, CommunityProvider communityProvider) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Báo cáo bài viết'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Lý do báo cáo...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
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
                  const SnackBar(
                    content: Text('Đã gửi báo cáo'),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tạo bài viết',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Bạn đang nghĩ gì?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Chủ đề',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildTopicChip('all', 'Tất cả'),
              _buildTopicChip('tips', 'Mẹo hay'),
              _buildTopicChip('help', 'Hỏi đáp'),
              _buildTopicChip('share', 'Chia sẻ'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
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
              child: _posting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Đăng bài'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicChip(String value, String label) {
    final selected = _selectedTopic == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTopic = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              selected ? AppTheme.primary : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
