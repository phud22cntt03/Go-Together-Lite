import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late List<_PostData> _posts;
  final _topics = ['Tất cả', 'Chia sẻ', 'Hỏi đáp', 'Mẹo hay'];
  int _selectedTopic = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _posts = MockData.communityPosts
        .map(
          (p) => _PostData(
            id: p.id,
            authorName: p.authorName,
            content: p.content,
            timeAgo: p.timeAgo ?? '',
            likes: p.likes,
            comments: p.comments,
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _toggleLike(String id) {
    setState(() {
      final idx = _posts.indexWhere((p) => p.id == id);
      if (idx != -1) {
        final p = _posts[idx];
        _posts[idx] = _PostData(
          id: p.id,
          authorName: p.authorName,
          content: p.content,
          timeAgo: p.timeAgo,
          likes: p.isLiked ? p.likes - 1 : p.likes + 1,
          comments: p.comments,
          isLiked: !p.isLiked,
        );
      }
    });
  }

  void _openCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePostSheet(
        onPost: (content) {
          setState(() {
            _posts.insert(
              0,
              _PostData(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                authorName: 'Bạn',
                content: content,
                timeAgo: 'Vừa xong',
                likes: 0,
                comments: 0,
              ),
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã đăng bài thành công!'),
              backgroundColor: AppTheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg),
            ),
          );
        },
      ),
    );
  }

  void _openComments(_PostData post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(post: post),
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _topics.length,
                  itemBuilder: (_, i) {
                    final sel = _selectedTopic == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTopic = i),
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
                                  : AppTheme.outlineVariant.withValues(
                                      alpha: 0.4,
                                    ),
                            ),
                          ),
                          child: Text(
                            _topics[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: sel ? Colors.white : AppTheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Posts list
            Expanded(
              child: _posts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: _posts.length,
                      itemBuilder: (_, i) => _buildPostCard(_posts[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(_PostData post) {
    final avatarColors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.tertiary,
      Colors.purple,
      Colors.orange,
    ];
    final color =
        avatarColors[post.authorName.codeUnitAt(0) % avatarColors.length];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusXxl,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text(
                  post.authorName[0],
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 12,
                          color: AppTheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          post.timeAgo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showPostMenu(post),
                child: const Icon(Icons.more_horiz, color: AppTheme.outline),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              _actionBtn(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${post.likes}',
                color: post.isLiked ? Colors.red : AppTheme.outline,
                onTap: () => _toggleLike(post.id),
              ),
              const SizedBox(width: 20),
              _actionBtn(
                icon: Icons.chat_bubble_outline,
                label: '${post.comments}',
                onTap: () => _openComments(post),
              ),
              const SizedBox(width: 20),
              _actionBtn(
                icon: Icons.share_outlined,
                label: 'Chia sẻ',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              key: ValueKey(icon),
              size: 18,
              color: color ?? AppTheme.outline,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color ?? AppTheme.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showPostMenu(_PostData post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report_outlined, color: Colors.orange),
              title: const Text('Báo cáo bài đăng'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Đã gửi báo cáo')));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.hide_source_outlined,
                color: AppTheme.outline,
              ),
              title: const Text('Ẩn bài đăng'),
              onTap: () {
                setState(() => _posts.removeWhere((p) => p.id == post.id));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.groups_outlined, size: 60, color: AppTheme.outline),
          const SizedBox(height: 16),
          Text(
            'Chưa có bài đăng nào',
            style: TextStyle(color: AppTheme.outline, fontSize: 15),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _openCreatePost,
            child: const Text(
              'Hãy là người đầu tiên chia sẻ!',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Post Data Model (local state) ───────────────────────
class _PostData {
  final String id;
  final String authorName;
  final String content;
  final String timeAgo;
  final int likes;
  final int comments;
  final bool isLiked;

  _PostData({
    required this.id,
    required this.authorName,
    required this.content,
    required this.timeAgo,
    required this.likes,
    required this.comments,
    this.isLiked = false,
  });
}

// ─── Create Post Sheet ───────────────────────────────────
class _CreatePostSheet extends StatefulWidget {
  final Function(String content) onPost;
  const _CreatePostSheet({required this.onPost});

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _ctrl = TextEditingController();
  bool _hasContent = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryContainer,
                child: Icon(Icons.person, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bạn',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: AppTheme.radiusFull,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.public, size: 12, color: AppTheme.outline),
                        SizedBox(width: 4),
                        Text(
                          'Công khai',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: AppTheme.outline),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            onChanged: (v) => setState(() => _hasContent = v.trim().isNotEmpty),
            maxLines: 6,
            minLines: 3,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Bạn muốn chia sẻ điều gì?',
              border: InputBorder.none,
              hintStyle: TextStyle(color: AppTheme.outline, fontSize: 15),
            ),
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 12),
          // Suggestions
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _suggestionTag('🚗 Chuyến đi hôm nay'),
                _suggestionTag('🌟 Đánh giá tài xế'),
                _suggestionTag('💡 Mẹo tiết kiệm'),
                _suggestionTag('📍 Tuyến mới'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.image_outlined, color: AppTheme.outline),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.emoji_emotions_outlined,
                  color: AppTheme.outline,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.location_on_outlined,
                  color: AppTheme.outline,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: _hasContent
                      ? () {
                          widget.onPost(_ctrl.text.trim());
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusLg,
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text(
                    'Đăng',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _suggestionTag(String text) {
    return GestureDetector(
      onTap: () {
        _ctrl.text += (_ctrl.text.isEmpty ? '' : ' ') + text;
        setState(() => _hasContent = true);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryContainer.withValues(alpha: 0.1),
          borderRadius: AppTheme.radiusFull,
          border: Border.all(
            color: AppTheme.primaryContainer.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppTheme.primary),
        ),
      ),
    );
  }
}

// ─── Comments Sheet ──────────────────────────────────────
class _CommentsSheet extends StatefulWidget {
  final _PostData post;
  const _CommentsSheet({required this.post});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _ctrl = TextEditingController();
  final _mockComments = [
    _Comment(
      author: 'Hoàng Nam',
      content: 'Tuyệt vời quá! Mình cũng hay đi tuyến đó.',
      time: '30 phút trước',
    ),
    _Comment(
      author: 'Thu Hương',
      content: 'Cảm ơn bạn đã chia sẻ, rất hữu ích!',
      time: '1 giờ trước',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Bình luận (${widget.post.comments + _mockComments.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(16),
                children: [
                  // Original post
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: AppTheme.radiusLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.post.content,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._mockComments.map((c) => _buildComment(c)),
                ],
              ),
            ),
            // Comment input
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      color: AppTheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: InputDecoration(
                        hintText: 'Viết bình luận...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.outline,
                        ),
                        filled: true,
                        fillColor: AppTheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: AppTheme.radiusFull,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (_ctrl.text.trim().isEmpty) return;
                      setState(() {
                        _mockComments.insert(
                          0,
                          _Comment(
                            author: 'Bạn',
                            content: _ctrl.text.trim(),
                            time: 'Vừa xong',
                          ),
                        );
                        _ctrl.clear();
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
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

  Widget _buildComment(_Comment c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.secondaryContainer.withValues(alpha: 0.3),
            child: Text(
              c.author[0],
              style: const TextStyle(
                color: AppTheme.secondary,
                fontWeight: FontWeight.w700,
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
                    Text(
                      c.author,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      c.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    c.content,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Comment {
  final String author;
  final String content;
  final String time;
  _Comment({required this.author, required this.content, required this.time});
}
