import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userId;
  final String
  type; // booking_new, booking_cancel, trip_cancel, rating, community
  final String title;
  final String body;
  final String? relatedId;
  final bool isRead;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.relatedId,
    this.isRead = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'type': type,
    'title': title,
    'body': body,
    'relatedId': relatedId,
    'isRead': isRead,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };

  factory AppNotification.fromMap(String id, Map<String, dynamic> d) =>
      AppNotification(
        id: id,
        userId: d['userId'] ?? '',
        type: d['type'] ?? 'community',
        title: d['title'] ?? '',
        body: d['body'] ?? '',
        relatedId: d['relatedId'],
        isRead: d['isRead'] ?? false,
        createdAt: _readDateTime(d['createdAt']),
      );

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      relatedId: relatedId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
