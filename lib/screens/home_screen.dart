import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/trip_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final recentTrips = tripProvider.allTrips;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            _buildSearchBar(context),
            _buildChips(context),
            _buildBanner(context),
            _buildSectionTitle(context),
            if (tripProvider.isLoading && recentTrips.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                ),
              )
            else if (recentTrips.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.directions_car_outlined, size: 48, color: AppTheme.outline.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      const Text('Chưa có chuyến đi nào', style: TextStyle(color: AppTheme.outline)),
                    ]),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => TripCard(
                    trip: recentTrips[i],
                    onTap: () => Navigator.pushNamed(ctx, '/trip-detail', arguments: recentTrips[i]),
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

  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryContainer]),
                borderRadius: AppTheme.radiusLg,
              ),
              child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Carpool', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w800)),
            const Spacer(),
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: AppTheme.radiusFull),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                child: const Icon(Icons.notifications_outlined, color: AppTheme.onSurface, size: 22),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 21,
              backgroundColor: AppTheme.primaryContainer.withValues(alpha: 0.3),
              child: const Text('MT', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14)),
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: AppTheme.radiusLg),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppTheme.outline, size: 20),
              const SizedBox(width: 12),
              Text('Bạn muốn đi đâu?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.outline)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChips(BuildContext context) {
    final chips = [('Gần đây', Icons.access_time), ('Yêu thích', Icons.star_outline), ('Đường quen', Icons.route), ('Giá rẻ', Icons.local_offer_outlined)];
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: chips.map((c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: AppTheme.radiusFull, border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(c.$2, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(c.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.onSurface)),
                ]),
              ),
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF00A366)]),
            borderRadius: AppTheme.radiusXxl,
            boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Giảm 20%', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('cho chuyến đi đầu tiên', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: AppTheme.radiusFull),
                child: const Text('Sử dụng ngay', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ])),
            const Icon(Icons.directions_car_filled_rounded, color: Colors.white24, size: 80),
          ]),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Chuyến đi mới nhất gần bạn', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16)),
          TextButton(onPressed: () {}, child: const Text('Xem tất cả', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13))),
        ]),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Gợi ý cho bạn', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              _suggestionCard(context, Icons.work_outline, 'Đi làm', 'Tìm chuyến hàng ngày', AppTheme.secondary),
              const SizedBox(width: 12),
              _suggestionCard(context, Icons.school_outlined, 'Đi học', 'Kết nối sinh viên', AppTheme.tertiary),
              const SizedBox(width: 12),
              _suggestionCard(context, Icons.flight_takeoff, 'Sân bay', 'Đón/trả sân bay', AppTheme.primary),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _suggestionCard(BuildContext context, IconData icon, String title, String subtitle, Color color) {
    return Container(
      width: 150, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: AppTheme.radiusXxl, border: Border.all(color: color.withValues(alpha: 0.15))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: AppTheme.radiusLg), child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 12),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 2),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.outline, fontSize: 11)),
      ]),
    );
  }
}
