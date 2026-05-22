import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/trip_provider.dart';
import '../providers/notification_provider.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/history_card.dart';
import 'my_trips_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploadingAvatar = false;
  Uint8List? _localAvatarBytes;
  Future<ProfileOverview>? _overviewFuture;
  String? _overviewUserId;
  String? _overviewDataKey;
  String? _syncedUserId;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final bookingProvider = context.watch<BookingProvider>();
    final tripProvider = context.watch<TripProvider>();

    if (user != null && user.id != _syncedUserId) {
      _syncedUserId = user.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<BookingProvider>().watchMyBookings(user.id);
        context.read<TripProvider>().loadDriverTrips(user.id);
      });
    }

    final overviewDataKey = [
      bookingProvider.myBookings.length,
      bookingProvider.myBookings.where((b) => b.isCompleted).length,
      bookingProvider.myBookings.where((b) => b.isCancelled).length,
      tripProvider.myCreatedTrips.length,
    ].join(':');
    _ensureOverviewLoaded(user, overviewDataKey);

    final displayName = user?.fullName ?? 'Người dùng';
    final initials = user?.initials ?? 'U';
    final rating = user?.rating.toStringAsFixed(1) ?? '5.0';
    final avatarImage = _localAvatarBytes != null
        ? MemoryImage(_localAvatarBytes!)
        : _avatarImage(user?.avatarUrl);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Text(
                      'Cá nhân',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: AppTheme.radiusFull,
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: AppTheme.onSurface,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF00A366)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppTheme.radiusXxl,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: user == null ? null : () => _pickAndUploadAvatar(user),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            backgroundImage: avatarImage,
                            child: avatarImage == null
                                ? Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22,
                                    ),
                                  )
                                : null,
                          ),
                          if (_uploadingAvatar)
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 12,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: AppTheme.radiusFull,
                                ),
                                child: Text(
                                  user?.isVerified == true
                                      ? 'Đã xác minh'
                                      : 'Thành viên',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                rating,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
            SliverToBoxAdapter(
              child: FutureBuilder<ProfileOverview>(
                future: _overviewFuture,
                builder: (context, snapshot) {
                  final overview = snapshot.data;
                  final totalBookedTrips =
                      overview?.totalBookedTrips.toString() ?? '0';
                  final amountText = _formatAmount(
                    overview?.totalAmountBooked ?? 0,
                  );

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        _statCard(context, totalBookedTrips, 'Chuyến đã đặt'),
                        const SizedBox(width: 8),
                        _statCard(context, rating, 'Đánh giá'),
                        const SizedBox(width: 8),
                        _statCard(context, amountText, 'Đã chi'),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Bạn đồng hành nổi bật',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontSize: 16),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<ProfileOverview>(
                future: _overviewFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return _infoMessage('Không tải được dữ liệu bạn đồng hành');
                  }

                  final companions = snapshot.data?.companions ?? [];
                  if (companions.isEmpty) {
                    return _infoMessage(
                      'Chưa có dữ liệu bạn đồng hành từ các chuyến thực tế.',
                    );
                  }

                  return SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: companions.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final companion = companions[index];
                        return _companionCard(
                          context,
                          companion.name,
                          companion.subtitle,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lịch sử chuyến đi',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyTripsScreen(
                              initialTab: 0,
                              title: 'Lịch sử chuyến đi',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Xem tất cả',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder<ProfileOverview>(
              future: _overviewFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: _infoMessage('Không tải được lịch sử chuyến đi'),
                  );
                }

                final history = snapshot.data?.historyTrips ?? [];
                if (history.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _infoMessage('Chưa có lịch sử chuyến đi thực tế.'),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => HistoryCard(trip: history[i]),
                    childCount: history.length,
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppTheme.radiusXxl,
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      _menuItem(
                        context,
                        Icons.directions_car_outlined,
                        'Phương tiện của tôi',
                        onTap: () => Navigator.pushNamed(context, '/vehicles'),
                      ),
                      _menuDivider(),
                      _menuItem(
                        context,
                        Icons.payment,
                        'Phương thức thanh toán',
                      ),
                      _menuDivider(),
                      _menuItem(
                        context,
                        Icons.notifications_outlined,
                        'Thông báo',
                        onTap: () =>
                            Navigator.pushNamed(context, '/notifications'),
                      ),
                      _menuDivider(),
                      _menuItem(
                        context,
                        Icons.help_outline,
                        'Trung tâm hỗ trợ',
                      ),
                      _menuDivider(),
                      _menuItem(
                        context,
                        Icons.logout,
                        'Đăng xuất',
                        isDestructive: true,
                        onTap: () {
                          context.read<AuthProvider>().logout();
                          Navigator.pushReplacementNamed(context, '/');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(AppUser user) async {
    if (_uploadingAvatar) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    setState(() {
      _localAvatarBytes = bytes;
      _uploadingAvatar = true;
    });

    try {
      final ext = file.extension ?? 'jpg';
      final url = await AuthService.uploadAvatarBytes(
        userId: user.id,
        bytes: bytes,
        fileName: 'avatar.$ext',
      );
      if (!mounted) return;

      final auth = context.read<AuthProvider>();
      final ok = await auth.updateProfile(user.copyWith(avatarUrl: url));
      if (!ok) {
        throw Exception(auth.error ?? 'Không thể cập nhật avatar');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật ảnh đại diện')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không upload được avatar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
  }

  void _ensureOverviewLoaded(AppUser? user, String overviewDataKey) {
    if (user == null) {
      _overviewFuture = null;
      _overviewUserId = null;
      _overviewDataKey = null;
      return;
    }

    if (_overviewFuture != null &&
        _overviewUserId == user.id &&
        _overviewDataKey == overviewDataKey) {
      return;
    }

    _overviewUserId = user.id;
    _overviewDataKey = overviewDataKey;
    _overviewFuture = ProfileService.loadOverview(
      userId: user.id,
      currentUserName: user.fullName,
    );
  }

  Widget _statCard(BuildContext context, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusXxl,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusXxl,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.outline),
        ),
      ),
    );
  }

  ImageProvider? _avatarImage(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) return null;
    if (avatarUrl.startsWith('data:image/')) {
      final commaIndex = avatarUrl.indexOf(',');
      if (commaIndex == -1) return null;
      final encoded = avatarUrl.substring(commaIndex + 1);
      return MemoryImage(base64Decode(encoded));
    }
    return NetworkImage(avatarUrl);
  }

  Widget _companionCard(BuildContext context, String name, String subtitle) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusXxl,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryContainer.withValues(alpha: 0.3),
            child: Text(
              name[0],
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: AppTheme.outline),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.error : AppTheme.onSurface,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppTheme.error : AppTheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.outline.withValues(alpha: 0.5),
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _menuDivider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppTheme.onSurface.withValues(alpha: 0.05),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return '$amount';
  }

  Widget _buildNotificationMenuItem(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final unreadCount = notificationProvider.unreadCount;
        return Stack(
          children: [
            _menuItem(
              context,
              Icons.notifications_outlined,
              'Thông báo',
              onTap: () => Navigator.pushNamed(context, '/notifications'),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 16,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
