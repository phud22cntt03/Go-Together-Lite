import 'dart:async';
import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../services/community_service.dart';

class CommunityProvider extends ChangeNotifier {
  List<CommunityPost> _posts = [];
  List<PostComment> _currentPostComments = [];
  bool _isLoading = false;
  String? _error;
  String _selectedTopic = 'all';
  StreamSubscription? _postsSub;
  StreamSubscription? _commentsSub;

  List<CommunityPost> get posts => _posts;
  List<PostComment> get currentPostComments => _currentPostComments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedTopic => _selectedTopic;

  CommunityProvider() {
    _loadPosts();
  }

  // Stream posts real-time
  void _loadPosts() {
    _isLoading = true;
    notifyListeners();

    _postsSub?.cancel();
    _postsSub = CommunityService.watchPosts(topic: _selectedTopic).listen(
      (postsData) {
        _posts = postsData
            .map((d) => CommunityPost.fromMap(d['id'] ?? '', d))
            .toList();
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Không thể tải bài viết: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Pull-to-refresh
  Future<void> refreshPosts() async {
    _postsSub?.cancel();
    _loadPosts();
  }

  // Thay đổi topic filter
  void setTopic(String topic) {
    _selectedTopic = topic;
    _commentsSub?.cancel();
    _currentPostComments.clear();
    _loadPosts();
  }

  // Stream comments cho bài viết
  void watchComments(String postId) {
    _commentsSub?.cancel();
    _commentsSub = CommunityService.watchComments(postId).listen(
      (commentsData) {
        _currentPostComments = commentsData
            .map((d) => PostComment.fromMap(d['id'] ?? '', d))
            .toList();
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Comments stream error: $e');
      },
    );
  }

  // Tạo bài viết
  Future<void> createPost({
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required String content,
    String topic = 'all',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await CommunityService.createPost(
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        content: content,
        topic: topic,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Không thể tạo bài viết: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Like/Unlike bài viết
  Future<void> toggleLike(String postId, String userId) async {
    try {
      await CommunityService.toggleLike(postId, userId);
      
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        final post = _posts[idx];
        final isLiked = post.likedBy.contains(userId);
        _posts[idx] = CommunityPost(
          id: post.id,
          authorId: post.authorId,
          authorName: post.authorName,
          authorAvatar: post.authorAvatar,
          content: post.content,
          topic: post.topic,
          likes: isLiked ? post.likes - 1 : post.likes + 1,
          comments: post.comments,
          likedBy: isLiked
              ? post.likedBy.where((id) => id != userId).toList()
              : [...post.likedBy, userId],
          createdAt: post.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Lỗi like bài viết: $e';
      notifyListeners();
    }
  }

  // Thêm comment (hỗ trợ ảnh + reply)
  Future<void> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
    String? imageUrl,
    String? replyToId,
    String? replyToName,
  }) async {
    try {
      await CommunityService.addComment(
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        content: content,
        imageUrl: imageUrl,
        replyToId: replyToId,
        replyToName: replyToName,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Không thể thêm bình luận: $e';
      notifyListeners();
    }
  }

  // Toggle reaction on comment
  Future<void> toggleCommentReaction(
    String postId,
    String commentId,
    String emoji,
    String userId,
  ) async {
    try {
      await CommunityService.toggleCommentReaction(
        postId,
        commentId,
        emoji,
        userId,
      );
    } catch (e) {
      _error = 'Lỗi reaction: $e';
      notifyListeners();
    }
  }

  // Xóa comment
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await CommunityService.deleteComment(postId, commentId);
      _currentPostComments.removeWhere((c) => c.id == commentId);
      notifyListeners();
    } catch (e) {
      _error = 'Không thể xóa bình luận: $e';
      notifyListeners();
    }
  }

  // Xóa bài viết
  Future<void> deletePost(String postId) async {
    try {
      await CommunityService.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
    } catch (e) {
      _error = 'Không thể xóa bài viết: $e';
      notifyListeners();
    }
  }

  // Báo cáo bài viết
  Future<void> reportPost(
    String postId,
    String reporterId,
    String reason,
  ) async {
    try {
      await CommunityService.reportPost(postId, reporterId, reason);
      notifyListeners();
    } catch (e) {
      _error = 'Không thể báo cáo bài viết: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _postsSub?.cancel();
    _commentsSub?.cancel();
    super.dispose();
  }
}
