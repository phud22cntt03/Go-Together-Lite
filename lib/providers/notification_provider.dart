import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _sub;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  /// Bắt đầu lắng nghe thông báo realtime cho user
  void watchNotifications(String userId) {
    _sub?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    _sub = NotificationService.watchNotifications(userId).listen(
      (list) {
        _notifications = list;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Không thể tải thông báo: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Đánh dấu 1 thông báo đã đọc
  Future<void> markAsRead(String notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);
      final idx = _notifications.indexWhere((n) => n.id == notificationId);
      if (idx != -1) {
        _notifications[idx] = _notifications[idx].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Không thể đánh dấu đã đọc: $e';
      notifyListeners();
    }
  }

  /// Đánh dấu tất cả đã đọc
  Future<void> markAllAsRead(String userId) async {
    try {
      await NotificationService.markAllAsRead(userId);
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = 'Không thể đánh dấu tất cả: $e';
      notifyListeners();
    }
  }

  /// Xóa thông báo
  Future<void> deleteNotification(String notificationId) async {
    try {
      await NotificationService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      _error = 'Không thể xóa thông báo: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
