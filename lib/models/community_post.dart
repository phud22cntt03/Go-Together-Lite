import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final String topic; // 'all', 'tips', 'help', 'share'
  final int likes;
  final int comments;
  final List<String> likedBy;
  final DateTime? createdAt;
  final String? timeAgo;

  CommunityPost({
    required this.id,
    this.authorId = '',
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.topic = 'all',
    this.likes = 0,
    this.comments = 0,
    this.likedBy = const [],
    this.createdAt,
    this.timeAgo,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'authorId': authorId,
    'authorName': authorName,
    'authorAvatar': authorAvatar,
    'content': content,
    'topic': topic,
    'likes': likes,
    'comments': comments,
    'likedBy': likedBy,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };

  factory CommunityPost.fromMap(String id, Map<String, dynamic> d) =>
      CommunityPost(
        id: id,
        authorId: d['authorId'] ?? '',
        authorName: d['authorName'] ?? '',
        authorAvatar: d['authorAvatar'],
        content: d['content'] ?? '',
        topic: d['topic'] ?? 'all',
        likes: (d['likes'] as num?)?.toInt() ?? 0,
        comments: (d['comments'] as num?)?.toInt() ?? 0,
        likedBy: List<String>.from(d['likedBy'] ?? const <String>[]),
        createdAt: _readDateTime(d['createdAt']),
      );

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

class PostComment {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final String? imageUrl;
  final Map<String, List<String>> reactions; // emoji -> list of userIds
  final String? replyToId;
  final String? replyToName;
  final DateTime? createdAt;

  PostComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.imageUrl,
    this.reactions = const {},
    this.replyToId,
    this.replyToName,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'authorId': authorId,
    'authorName': authorName,
    'content': content,
    'imageUrl': imageUrl,
    'reactions': reactions,
    'replyToId': replyToId,
    'replyToName': replyToName,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };

  factory PostComment.fromMap(String id, Map<String, dynamic> d) => PostComment(
    id: id,
    authorId: d['authorId'] ?? '',
    authorName: d['authorName'] ?? '',
    content: d['content'] ?? '',
    imageUrl: d['imageUrl'],
    reactions: _parseReactions(d['reactions']),
    replyToId: d['replyToId'],
    replyToName: d['replyToName'],
    createdAt: _readDateTime(d['createdAt']),
  );

  static Map<String, List<String>> _parseReactions(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    final result = <String, List<String>>{};
    for (final entry in raw.entries) {
      result[entry.key.toString()] = List<String>.from(entry.value ?? []);
    }
    return result;
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
