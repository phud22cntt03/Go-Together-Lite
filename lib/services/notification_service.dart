import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';

class NotificationService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'notifications';

  /// Stream thông báo realtime theo userId, sắp xếp mới nhất trước
  static Stream<List<AppNotification>> watchNotifications(String userId) {
    return _db
        .collection(_col)
        .where('userId', isEqualTo: userId)
        .limit(50)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => AppNotification.fromMap(d.id, d.data()))
          .toList();
      // Sort client-side để không cần composite index
      list.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(2000);
        final bTime = b.createdAt ?? DateTime(2000);
        return bTime.compareTo(aTime); // mới nhất trước
      });
      return list;
    });
  }

  /// Tạo thông báo mới
  static Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    String? relatedId,
  }) async {
    final ref = _db.collection(_col).doc();
    await ref.set({
      'id': ref.id,
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'relatedId': relatedId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Đánh dấu 1 thông báo đã đọc
  static Future<void> markAsRead(String notificationId) async {
    await _db.collection(_col).doc(notificationId).update({'isRead': true});
  }

  /// Đánh dấu tất cả thông báo của user đã đọc
  static Future<void> markAllAsRead(String userId) async {
    final snap = await _db
        .collection(_col)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Xóa một thông báo
  static Future<void> deleteNotification(String notificationId) async {
    await _db.collection(_col).doc(notificationId).delete();
  }
}
