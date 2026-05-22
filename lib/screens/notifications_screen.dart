import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_notification.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.notifications;
    final userId = auth.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: AppTheme.radiusFull,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Thông báo',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: notifications.any((n) => !n.isRead)
                        ? () => notifProvider.markAllAsRead(userId)
                        : null,
                    child: Text(
                      'Đọc tất cả',
                      style: TextStyle(
                        color: notifications.any((n) => !n.isRead)
                            ? AppTheme.primary
                            : AppTheme.outline,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Content ──
            Expanded(
              child: _buildContent(context, notifProvider, notifications),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    NotificationProvider provider,
    List<AppNotification> notifications,
  ) {
    // Loading
    if (provider.isLoading && notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    // Error
    if (provider.error != null && notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.error),
              const SizedBox(height: 12),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.outline),
              ),
            ],
          ),
        ),
      );
    }

    // Empty
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: AppTheme.outline.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có thông báo nào',
              style: TextStyle(
                color: AppTheme.outline,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Thông báo sẽ hiển thị khi có hoạt động mới',
              style: TextStyle(color: AppTheme.outline, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // List
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: notifications.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final n = notifications[i];
        return Dismissible(
          key: ValueKey(n.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red.withValues(alpha: 0.1),
            child: const Icon(Icons.delete_outline, color: Colors.red),
          ),
          onDismissed: (_) => provider.deleteNotification(n.id),
          child: GestureDetector(
            onTap: () {
              if (!n.isRead) {
                provider.markAsRead(n.id);
              }
            },
            child: Container(
              color: n.isRead
                  ? Colors.transparent
                  : AppTheme.primary.withValues(alpha: 0.03),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _iconColor(n.type).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _iconData(n.type),
                      color: _iconColor(n.type),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                n.title,
                                style: TextStyle(
                                  fontWeight:
                                      n.isRead ? FontWeight.w500 : FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (!n.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n.body,
                          style: const TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(n.createdAt),
                          style: const TextStyle(
                            color: AppTheme.outline,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Helper: icon theo type ──
  IconData _iconData(String type) {
    switch (type) {
      case 'booking_new':
        return Icons.check_circle;
      case 'booking_cancel':
        return Icons.cancel;
      case 'trip_cancel':
        return Icons.cancel_outlined;
      case 'rating':
        return Icons.star;
      case 'community':
        return Icons.forum_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'booking_new':
        return Colors.green;
      case 'booking_cancel':
      case 'trip_cancel':
        return Colors.red;
      case 'rating':
        return Colors.amber;
      case 'community':
        return Colors.purple;
      default:
        return AppTheme.primary;
    }
  }

  // ── Helper: format thời gian tương đối ──
  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
