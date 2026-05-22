import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../theme/app_theme.dart';
import '../widgets/booking_bottom_sheet.dart';
import '../widgets/trip_route_map.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = ModalRoute.of(context)!.settings.arguments as Trip;
    final pickupDate = _extractDate(trip.pickupTime);
    final pickupTime = _extractTime(trip.pickupTime);
    final dropoffTime = _extractTime(trip.dropoffTime);
    final hasPickupDate = pickupDate != null;
    final hasDropoffTime = trip.dropoffTime.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'Chi tiết chuyến đi',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.radiusXxl,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppTheme.primaryContainer
                                .withValues(alpha: 0.3),
                            child: Text(
                              trip.driverName.isNotEmpty
                                  ? trip.driverName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip.driverName,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(fontSize: 16),
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
                                        color: AppTheme.primaryContainer
                                            .withValues(alpha: 0.2),
                                        borderRadius: AppTheme.radiusFull,
                                      ),
                                      child: const Text(
                                        'Thành viên Bạc',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '152 chuyến đi',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${trip.driverRating}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _infoChip(
                          icon: Icons.event_seat,
                          value: '${trip.availableSeats} chỗ',
                          label: 'Còn trống',
                        ),
                        const SizedBox(width: 8),
                        _infoChip(
                          icon: Icons.schedule,
                          value: pickupTime,
                          label: 'Giờ đi',
                        ),
                        const SizedBox(width: 8),
                        _infoChip(
                          icon: Icons.attach_money,
                          value: _formatPrice(trip.pricePerSeat),
                          label: 'Giá/ghế',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.radiusXxl,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lịch trình thời gian',
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          if (hasPickupDate) ...[
                            _scheduleRow(
                              icon: Icons.calendar_today,
                              label: 'Ngày khởi hành',
                              value: pickupDate,
                            ),
                            const SizedBox(height: 10),
                          ],
                          _scheduleRow(
                            icon: Icons.access_time,
                            label: 'Giờ khởi hành',
                            value: pickupTime,
                          ),
                          if (hasDropoffTime) ...[
                            const SizedBox(height: 10),
                            _scheduleRow(
                              icon: Icons.flag_outlined,
                              label: 'Dự kiến đến',
                              value: dropoffTime,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Lộ trình',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.radiusXxl,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          _routePoint(
                            label: 'Điểm đón',
                            location: trip.pickupLocation,
                            detail: hasPickupDate
                                ? 'Khởi hành $pickupTime - $pickupDate'
                                : 'Khởi hành $pickupTime',
                            dotColor: AppTheme.primaryContainer,
                            isPickup: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Row(
                              children: [
                                Container(
                                  width: 2,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.outlineVariant.withValues(
                                      alpha: 0.4,
                                    ),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _routePoint(
                            label: 'Điểm đến',
                            location: trip.dropoffLocation,
                            detail: hasDropoffTime
                                ? 'Dự kiến $dropoffTime'
                                : '',
                            dotColor: AppTheme.secondary,
                            isPickup: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bản đồ lộ trình',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    TripRouteMap(
                      pickupLat: trip.pickupLat,
                      pickupLng: trip.pickupLng,
                      dropoffLat: trip.dropoffLat,
                      dropoffLng: trip.dropoffLng,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Thông tin bổ sung',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.radiusXxl,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainerLow,
                                  borderRadius: AppTheme.radiusLg,
                                ),
                                child: Icon(
                                  trip.vehicleType == 'motorbike'
                                      ? Icons.two_wheeler
                                      : Icons.directions_car,
                                  color: AppTheme.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Phương tiện',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.outline,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${trip.vehicleName} • ${trip.licensePlate}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (trip.driverNote != null &&
                              trip.driverNote!.trim().isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            const Text(
                              'Ghi chú từ tài xế',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.outline,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLow,
                                borderRadius: AppTheme.radiusLg,
                              ),
                              child: Text(
                                trip.driverNote!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giá mỗi ghế',
                        style: TextStyle(fontSize: 12, color: AppTheme.outline),
                      ),
                      Text(
                        _formatPrice(trip.pricePerSeat),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: trip.availableSeats == 0
                          ? null
                          : () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => BookingBottomSheet(trip: trip),
                              );
                            },
                      child: Text(
                        trip.availableSeats == 0 ? 'Hết chỗ' : 'Đặt chỗ ngay',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusXxl,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: AppTheme.radiusLg,
          ),
          child: Icon(icon, size: 18, color: AppTheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.outline),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _routePoint({
    required String label,
    required String location,
    required String detail,
    required Color dotColor,
    required bool isPickup,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: dotColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPickup ? Icons.circle : Icons.location_on,
            size: 14,
            color: dotColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppTheme.outline),
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (detail.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(fontSize: 12, color: AppTheme.outline),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String? _extractDate(String raw) {
    final match = RegExp(r'(\d{1,2})/(\d{1,2})').firstMatch(raw);
    if (match == null) {
      return null;
    }

    final day = match.group(1)!.padLeft(2, '0');
    final month = match.group(2)!.padLeft(2, '0');
    return '$day/$month';
  }

  String _extractTime(String raw) {
    final match = RegExp(
      r'(\d{1,2}):(\d{2})(?:\s*(AM|PM))?',
      caseSensitive: false,
    ).firstMatch(raw);

    if (match == null) {
      return raw.isEmpty ? '--:--' : raw;
    }

    final hour = match.group(1)!.padLeft(2, '0');
    final minute = match.group(2)!;
    final period = match.group(3);
    if (period == null) {
      return '$hour:$minute';
    }

    return '$hour:$minute ${period.toUpperCase()}';
  }

  String _formatPrice(int price) {
    if (price == 0) {
      return 'Miễn phí';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}k';
    }
    return '$priceđ';
  }
}
