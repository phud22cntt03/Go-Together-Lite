import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_notification.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationProvider _notificationProvider;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _notificationProvider = context.read<NotificationProvider>();
      _notificationProvider.watchNotifications(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.notifications.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 56,
                            color: AppTheme.outline.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có thông báo',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppTheme.outline),
                          ),
                        ],
                      ),
                    );
                  }

                  final groupedNotifications = _groupNotificationsByTime(
                    provider.notifications,
                  );

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: groupedNotifications.length,
                    itemBuilder: (ctx, i) {
                      final group = groupedNotifications[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                            child: Text(
                              group['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.outline,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          ...((group['notifications'] as List<AppNotification>)
                              .map((n) => _buildNotificationCard(context, n))
                              .toList()),
                        ],
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
          const SizedBox(width: 12),
          Text(
            'Thông báo',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  final user = context.read<AuthProvider>().currentUser;
                  if (user != null) {
                    provider.markAllAsRead(user.id);
                  }
                },
                child: const Text(
                  'Đọc tất cả',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, AppNotification n) {
    final icon = _getNotificationIcon(n.type);
    final color = _getNotificationColor(n.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: n.isRead ? Colors.white : AppTheme.primary.withValues(alpha: 0.03),
        border: Border.all(
          color: n.isRead
              ? AppTheme.outlineVariant
              : AppTheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: AppTheme.radiusXl,
        boxShadow: n.isRead
            ? []
            : [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Dismissible(
        key: Key(n.id),
        onDismissed: (direction) {
          context.read<NotificationProvider>().deleteNotification(n.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thông báo đã xóa')),
          );
        },
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: AppTheme.radiusXl,
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Icon(
            Icons.delete_outline,
            color: Colors.red[600],
            size: 20,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
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
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            width: 10,
                            height: 10,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(n.createdAt),
                          style: TextStyle(
                            color: AppTheme.outline,
                            fontSize: 11,
                          ),
                        ),
                        if (!n.isRead)
                          GestureDetector(
                            onTap: () {
                              context
                                  .read<NotificationProvider>()
                                  .markAsRead(n.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Đánh dấu đã đọc',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupNotificationsByTime(
    List<AppNotification> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final groups = <String, List<AppNotification>>{
      'Hôm nay': [],
      'Hôm qua': [],
      'Tuần này': [],
      'Cũ hơn': [],
    };

    for (final n in notifications) {
      if (n.createdAt == null) {
        groups['Cũ hơn']!.add(n);
        continue;
      }

      final nDate = DateTime(
        n.createdAt!.year,
        n.createdAt!.month,
        n.createdAt!.day,
      );

      if (nDate == today) {
        groups['Hôm nay']!.add(n);
      } else if (nDate == yesterday) {
        groups['Hôm qua']!.add(n);
      } else if (nDate.isAfter(weekAgo)) {
        groups['Tuần này']!.add(n);
      } else {
        groups['Cũ hơn']!.add(n);
      }
    }

    final result = <Map<String, dynamic>>[];
    for (final entry in groups.entries) {
      if (entry.value.isNotEmpty) {
        result.add({
          'label': entry.key,
          'notifications': entry.value,
        });
      }
    }

    return result;
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'booking_new':
        return Icons.check_circle;
      case 'booking_cancel':
        return Icons.cancel;
      case 'trip_cancel':
        return Icons.cancel;
      case 'rating':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'booking_new':
        return Colors.green;
      case 'booking_cancel':
      case 'trip_cancel':
        return Colors.red;
      case 'rating':
        return Colors.amber;
      default:
        return AppTheme.primary;
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
