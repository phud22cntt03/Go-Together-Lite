import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/trip_provider.dart';
import '../providers/auth_provider.dart';
import '../models/booking.dart';
import '../data/mock_data.dart';
import 'rating_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String? _syncedUserId;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthProvider>().currentUser;
    final tripProvider = context.watch<TripProvider>();

    if (authUser != null && authUser.id != _syncedUserId) {
      _syncedUserId = authUser.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final provider = context.read<TripProvider>();
        provider.watchBookings(authUser.id);
        provider.loadDriverTrips(authUser.id);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                    'Chuyến đi của tôi',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: AppTheme.radiusLg,
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: AppTheme.radiusLg,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.onSurfaceVariant,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Đặt chỗ'),
                    Tab(text: 'Đăng chuyến'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildBookingList(tripProvider),
                  _buildCreatedTripList(tripProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(TripProvider provider) {
    final bookings = provider.myBookings;
    if (bookings.isEmpty) {
      return _buildEmptyState(
        'Bạn chưa đặt chuyến nào',
        Icons.confirmation_number_outlined,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: bookings.length,
      itemBuilder: (ctx, i) {
        final b = bookings[i];
        final trip =
            provider.getTripById(b.tripId) ??
            MockData.tripHistory.firstWhere(
              (t) => t.id == b.tripId,
              orElse: () => MockData.tripHistory[0],
            );
        return _BookingCard(
          booking: b,
          trip: trip,
          onCancel: () => _confirmCancel(b),
          onRate: b.isCompleted ? () => _openRating(b, trip) : null,
        );
      },
    );
  }

  Widget _buildCreatedTripList(TripProvider provider) {
    final trips = provider.myCreatedTrips;
    if (trips.isEmpty) {
      return _buildEmptyState(
        'Bạn chưa đăng chuyến nào',
        Icons.directions_car_outlined,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: trips.length,
      itemBuilder: (ctx, i) {
        final t = trips[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.radiusXxl,
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                  borderRadius: AppTheme.radiusLg,
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t.pickupLocation} → ${t.dropoffLocation}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${t.pickupTime} · ${t.availableSeats} ghế trống · ${_formatPrice(t.pricePerSeat)}/ghế',
                      style: TextStyle(color: AppTheme.outline, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: t.status),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: AppTheme.outline),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppTheme.outline, fontSize: 15),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Khám phá chuyến đi',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(Booking booking) {
    if (!booking.isPending && !booking.isConfirmed) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CancelBookingSheet(
        onConfirm: (reason) {
          context.read<TripProvider>().cancelBooking(booking.id, reason);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã hủy đặt chỗ'),
              backgroundColor: Colors.orange,
            ),
          );
        },
      ),
    );
  }

  void _openRating(Booking booking, dynamic trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RatingScreen(booking: booking, trip: trip),
      ),
    );
  }

  String _formatPrice(int price) => '${(price / 1000).toStringAsFixed(0)}k';
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final dynamic trip;
  final VoidCallback onCancel;
  final VoidCallback? onRate;

  const _BookingCard({
    required this.booking,
    required this.trip,
    required this.onCancel,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      'pending': Colors.orange,
      'confirmed': AppTheme.primary,
      'cancelled': Colors.red,
      'completed': Colors.green,
    };
    final color = statusColors[booking.status] ?? AppTheme.outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusXxl,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryContainer.withValues(
                  alpha: 0.2,
                ),
                child: Text(
                  trip.driverName.substring(0, 1),
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
                  children: [
                    Text(
                      trip.driverName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      trip.vehicleName,
                      style: TextStyle(color: AppTheme.outline, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: booking.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _row(Icons.circle, trip.pickupLocation, AppTheme.primaryContainer),
          const SizedBox(height: 6),
          _row(Icons.location_on, trip.dropoffLocation, AppTheme.secondary),
          const SizedBox(height: 12),
          Row(
            children: [
              _pill(Icons.access_time, trip.pickupTime),
              const SizedBox(width: 8),
              _pill(Icons.event_seat, '${booking.seatsBooked} ghế'),
              const Spacer(),
              Text(
                '${_fmt(booking.totalPrice)} đ',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          if (booking.isPending || booking.isConfirmed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusLg,
                  ),
                ),
                child: const Text(
                  'Hủy đặt chỗ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ] else if (booking.isCompleted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: booking.passengerRating == null ? onRate : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusLg,
                  ),
                ),
                child: Text(
                  booking.passengerRating == null
                      ? 'Đánh giá chuyến đi'
                      : 'Đã đánh giá ${booking.passengerRating!.toStringAsFixed(1)}★',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _pill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: AppTheme.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.outline),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int price) => price.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final map = {
      'pending': ('Chờ', Colors.orange),
      'confirmed': ('Xác nhận', AppTheme.primary),
      'cancelled': ('Đã hủy', Colors.red),
      'completed': ('Xong', Colors.green),
      'available': ('Còn chỗ', AppTheme.primary),
    };
    final info = map[status] ?? ('--', AppTheme.outline);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: info.$2.withValues(alpha: 0.1),
        borderRadius: AppTheme.radiusFull,
      ),
      child: Text(
        info.$1,
        style: TextStyle(
          color: info.$2,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _CancelBookingSheet extends StatefulWidget {
  final Function(String reason) onConfirm;
  const _CancelBookingSheet({required this.onConfirm});

  @override
  State<_CancelBookingSheet> createState() => _CancelBookingSheetState();
}

class _CancelBookingSheetState extends State<_CancelBookingSheet> {
  String? _selectedReason;
  final _reasons = [
    'Thay đổi lịch trình',
    'Đặt nhầm chuyến',
    'Tài xế hủy trước',
    'Lý do khác',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hủy đặt chỗ',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Vui lòng chọn lý do hủy',
            style: TextStyle(color: AppTheme.outline),
          ),
          const SizedBox(height: 20),
          ..._reasons.map(
            (r) => GestureDetector(
              onTap: () => setState(() => _selectedReason = r),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _selectedReason == r
                      ? AppTheme.primary.withValues(alpha: 0.08)
                      : AppTheme.surfaceContainerLow,
                  borderRadius: AppTheme.radiusLg,
                  border: Border.all(
                    color: _selectedReason == r
                        ? AppTheme.primary
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        r,
                        style: TextStyle(
                          fontWeight: _selectedReason == r
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _selectedReason == r
                              ? AppTheme.primary
                              : AppTheme.onSurface,
                        ),
                      ),
                    ),
                    if (_selectedReason == r)
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedReason == null
                  ? null
                  : () => widget.onConfirm(_selectedReason!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg),
                elevation: 0,
              ),
              child: const Text(
                'Xác nhận hủy',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
