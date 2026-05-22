import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/trip_card.dart';
import 'create_trip_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final auth = context.watch<AuthProvider>();
    final recentTrips = tripProvider.recentTrips;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(context, auth),
            _buildSearchBar(context),
            _buildCategories(context),
            _buildBanner(context, auth),
            _buildSectionTitle(context),
            if (tripProvider.isLoading && recentTrips.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                ),
              )
            else if (tripProvider.error != null && recentTrips.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppTheme.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tripProvider.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.outline),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (recentTrips.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 48,
                          color: AppTheme.outline.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Chưa có chuyến nào mới được đăng',
                          style: TextStyle(color: AppTheme.outline),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => TripCard(
                    trip: recentTrips[i],
                    onTap: () => Navigator.pushNamed(
                      ctx,
                      '/trip-detail',
                      arguments: recentTrips[i],
                    ),
                  ),
                  childCount: recentTrips.length,
                ),
              ),
            _buildSuggestions(context),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider auth) {
    final user = auth.currentUser;
    final greeting = _greetingForHour(DateTime.now().hour);
    final displayName = user?.fullName ?? 'Người dùng';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.outline),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/notifications'),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: AppTheme.radiusFull,
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.onSurface,
                      size: 22,
                    ),
                  ),
                  Builder(
                    builder: (ctx) {
                      final unread = ctx.watch<NotificationProvider>().unreadCount;
                      if (unread == 0) return const SizedBox.shrink();
                      return Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 21,
              backgroundColor: AppTheme.primaryContainer.withValues(alpha: 0.3),
              backgroundImage: _avatarImage(user?.avatarUrl),
              child: _avatarImage(user?.avatarUrl) == null
                  ? Text(
                      user?.initials ?? 'U',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: GestureDetector(
          onTap: () => _openSearch(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: AppTheme.radiusLg,
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppTheme.outline, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Bạn muốn đi đâu?',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.outline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      _HomeCategory(
        label: 'Mới đăng',
        icon: Icons.access_time,
        quickFilter: 'newest',
      ),
      _HomeCategory(
        label: 'Ô tô',
        icon: Icons.directions_car_outlined,
        quickFilter: 'car',
      ),
      _HomeCategory(
        label: 'Xe máy',
        icon: Icons.two_wheeler_outlined,
        quickFilter: 'motorbike',
      ),
      _HomeCategory(
        label: 'Giá rẻ',
        icon: Icons.local_offer_outlined,
        quickFilter: 'cheap',
      ),
      _HomeCategory(
        label: 'Quanh bạn',
        icon: Icons.my_location,
        quickFilter: 'nearby',
      ),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _openSearch(
                        context,
                        initialQuickFilter: category.quickFilter,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: AppTheme.radiusFull,
                          border: Border.all(
                            color: AppTheme.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category.label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, AuthProvider auth) {
    final firstName =
        auth.currentUser?.fullName.trim().split(' ').last ?? 'bạn';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, Color(0xFF00A366)],
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào $firstName',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tìm chuyến phù hợp, đặt chỗ và thanh toán nhanh bằng ví SmartCarpool.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _openSearch(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppTheme.radiusFull,
                        ),
                        child: const Text(
                          'Tìm chuyến ngay',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.directions_car_filled_rounded,
                color: Colors.white24,
                size: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Các chuyến đăng gần đây',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontSize: 16),
            ),
            TextButton(
              onPressed: () => _openSearch(context),
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
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final suggestions = [
      _HomeSuggestion(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Nạp ví',
        subtitle: 'Thêm số dư để đặt chỗ nhanh',
        color: const Color(0xFFA50064),
        routeName: '/wallet',
      ),
      _HomeSuggestion(
        icon: Icons.confirmation_number_outlined,
        title: 'Chuyến đã đặt',
        subtitle: 'Theo dõi, hủy hoặc đánh giá',
        color: AppTheme.secondary,
        routeName: '/my-trips',
      ),
      _HomeSuggestion(
        icon: Icons.local_offer_outlined,
        title: 'Giá tốt',
        subtitle: 'Ưu tiên chuyến tiết kiệm',
        color: AppTheme.primary,
        quickFilter: 'cheap',
      ),
      _HomeSuggestion(
        icon: Icons.add_road_outlined,
        title: 'Đăng chuyến',
        subtitle: 'Chia sẻ ghế trống của bạn',
        color: AppTheme.tertiary,
        opensCreateTrip: true,
      ),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiện ích nhanh',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return GestureDetector(
                    onTap: () => _openSuggestion(context, suggestion),
                    child: _suggestionCard(
                      context,
                      icon: suggestion.icon,
                      title: suggestion.title,
                      subtitle: suggestion.subtitle,
                      color: suggestion.color,
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

  Widget _suggestionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppTheme.radiusXxl,
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppTheme.radiusLg,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.outline,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _openSearch(
    BuildContext context, {
    String initialQuickFilter = 'all',
    String initialTo = '',
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          initialQuickFilter: initialQuickFilter,
          initialTo: initialTo,
        ),
      ),
    );
  }

  void _openSuggestion(BuildContext context, _HomeSuggestion suggestion) {
    if (suggestion.opensCreateTrip) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateTripScreen()),
      );
      return;
    }

    final routeName = suggestion.routeName;
    if (routeName != null) {
      Navigator.pushNamed(context, routeName);
      return;
    }

    _openSearch(context, initialQuickFilter: suggestion.quickFilter);
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

  String _greetingForHour(int hour) {
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }
}

class _HomeCategory {
  const _HomeCategory({
    required this.label,
    required this.icon,
    required this.quickFilter,
  });

  final String label;
  final IconData icon;
  final String quickFilter;
}

class _HomeSuggestion {
  const _HomeSuggestion({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.quickFilter = 'all',
    this.routeName,
    this.opensCreateTrip = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String quickFilter;
  final String? routeName;
  final bool opensCreateTrip;
}
