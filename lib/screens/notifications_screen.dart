import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final _mockNotifications = [
    _Notif(icon: Icons.check_circle, color: Colors.green, title: 'Đặt chỗ thành công', subtitle: 'Chuyến Quận 7 → Quận 1 lúc 08:30', time: '2 phút trước', isRead: false),
    _Notif(icon: Icons.star, color: Colors.amber, title: 'Đánh giá chuyến đi', subtitle: 'Hãy đánh giá chuyến đi với Minh Tuấn', time: '1 giờ trước', isRead: false),
    _Notif(icon: Icons.directions_car, color: AppTheme.primary, title: 'Chuyến đi sắp khởi hành', subtitle: 'Tài xế đang trên đường đón bạn', time: '3 giờ trước', isRead: true),
    _Notif(icon: Icons.cancel, color: Colors.red, title: 'Đặt chỗ bị hủy', subtitle: 'Tài xế đã hủy chuyến Cầu Giấy → Nội Bài', time: '1 ngày trước', isRead: true),
    _Notif(icon: Icons.local_offer, color: Colors.purple, title: 'Ưu đãi đặc biệt', subtitle: 'Giảm 30% cho chuyến đi thứ 5 của bạn!', time: '2 ngày trước', isRead: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: AppTheme.radiusFull),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Thông báo', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(onPressed: () {}, child: const Text('Đọc tất cả', style: TextStyle(color: AppTheme.primary, fontSize: 13))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _mockNotifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final n = _mockNotifications[i];
                  return Container(
                    color: n.isRead ? Colors.transparent : AppTheme.primary.withValues(alpha: 0.03),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: n.color.withValues(alpha: 0.12), shape: BoxShape.circle),
                          child: Icon(n.icon, color: n.color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700, fontSize: 14))),
                              if (!n.isRead)
                                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                            ]),
                            const SizedBox(height: 4),
                            Text(n.subtitle, style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(n.time, style: TextStyle(color: AppTheme.outline, fontSize: 11)),
                          ]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notif {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;
  final bool isRead;

  _Notif({required this.icon, required this.color, required this.title, required this.subtitle, required this.time, required this.isRead});
}
