import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityService {
  static final _db = FirebaseFirestore.instance;
  static const _postsCol = 'community_posts';

  // ─── Stream posts real-time ──────────────────────────────────────
  static Stream<List<Map<String, dynamic>>> watchPosts({String topic = 'all'}) {
    Query<Map<String, dynamic>> q = _db
        .collection(_postsCol)
        .orderBy('createdAt', descending: true)
        .limit(30);
    if (topic != 'all') {
      q = q.where('topic', isEqualTo: topic);
    }
    return q.snapshots().map(
      (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
    );
  }

  // ─── Tạo bài đăng ───────────────────────────────────────────────
  static Future<String> createPost({
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required String content,
    String topic = 'all',
  }) async {
    final ref = _db.collection(_postsCol).doc();
    await ref.set({
      'id': ref.id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'topic': topic,
      'likes': 0,
      'comments': 0,
      'likedBy': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // ─── Like / Unlike (Toggle) ──────────────────────────────────────
  static Future<void> toggleLike(String postId, String userId) async {
    final ref = _db.collection(_postsCol).doc(postId);
    final snap = await ref.get();
    if (!snap.exists) return;

    final likedBy = List<String>.from(snap['likedBy'] ?? []);
    if (likedBy.contains(userId)) {
      // Unlike
      await ref.update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likes': FieldValue.increment(-1),
      });
    } else {
      // Like
      await ref.update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likes': FieldValue.increment(1),
      });
    }
  }

  // ─── Comments ───────────────────────────────────────────────────
  static Stream<List<Map<String, dynamic>>> watchComments(String postId) {
    return _db
        .collection(_postsCol)
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  static Future<void> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
    String? imageUrl,
    String? replyToId,
    String? replyToName,
  }) async {
    final postRef = _db.collection(_postsCol).doc(postId);
    final commentRef = postRef.collection('comments').doc();

    // Batch: thêm comment + tăng count
    final batch = _db.batch();
    batch.set(commentRef, {
      'id': commentRef.id,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'imageUrl': imageUrl,
      'reactions': {},
      'replyToId': replyToId,
      'replyToName': replyToName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(postRef, {'comments': FieldValue.increment(1)});
    await batch.commit();
  }

  static Future<void> deleteComment(String postId, String commentId) async {
    final batch = _db.batch();
    batch.delete(
      _db
          .collection(_postsCol)
          .doc(postId)
          .collection('comments')
          .doc(commentId),
    );
    batch.update(_db.collection(_postsCol).doc(postId), {
      'comments': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  // ─── Toggle reaction on comment ──────────────────────────────────
  static Future<void> toggleCommentReaction(
    String postId,
    String commentId,
    String emoji,
    String userId,
  ) async {
    final ref = _db
        .collection(_postsCol)
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    final snap = await ref.get();
    if (!snap.exists) return;

    final data = snap.data()!;
    final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});
    final users = List<String>.from(reactions[emoji] ?? []);

    if (users.contains(userId)) {
      users.remove(userId);
    } else {
      users.add(userId);
    }

    if (users.isEmpty) {
      reactions.remove(emoji);
    } else {
      reactions[emoji] = users;
    }

    await ref.update({'reactions': reactions});
  }

  // ─── Xóa / Báo cáo bài ──────────────────────────────────────────
  static Future<void> deletePost(String postId) async {
    await _db.collection(_postsCol).doc(postId).delete();
  }

  static Future<void> reportPost(
    String postId,
    String reporterId,
    String reason,
  ) async {
    await _db.collection('reports').add({
      'postId': postId,
      'reporterId': reporterId,
      'reason': reason,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
