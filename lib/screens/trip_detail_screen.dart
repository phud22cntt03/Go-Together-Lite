import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../theme/app_theme.dart';
import '../widgets/booking_bottom_sheet.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = ModalRoute.of(context)!.settings.arguments as Trip;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                const Spacer(),
                Text('Chi tiết chuyến đi', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Driver card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: AppTheme.radiusXxl, boxShadow: AppTheme.cardShadow),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryContainer.withValues(alpha: 0.3),
                        child: Text(trip.driverName[0], style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 22)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(trip.driverName, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppTheme.primaryContainer.withValues(alpha: 0.2), borderRadius: AppTheme.radiusFull),
                            child: const Text('Thành viên Bạc', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.primary)),
                          ),
                          const SizedBox(width: 8),
                          Text('152 chuyến đi', style: Theme.of(context).textTheme.bodySmall),
                        ]),
                      ])),
                      Column(children: [
                        Row(children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${trip.driverRating}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ]),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Quick info
                  Row(children: [
                    _infoChip(context, Icons.event_seat, '${trip.availableSeats} chỗ', 'Trống'),
                    const SizedBox(width: 8),
                    _infoChip(context, Icons.access_time, trip.pickupTime, 'Khởi hành'),
                    const SizedBox(width: 8),
                    _infoChip(context, Icons.attach_money, _formatPrice(trip.pricePerSeat), 'Giá/Ghế'),
                  ]),
                  const SizedBox(height: 24),

                  // Route
                  Text('Lộ trình', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 15)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: AppTheme.radiusXxl, boxShadow: AppTheme.cardShadow),
                    child: Column(children: [
                      _routePoint(context, 'Điểm đón', trip.pickupLocation, 'Đợi tại sảnh chính', AppTheme.primaryContainer, true),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Row(children: [
                          Container(width: 2, height: 36, decoration: BoxDecoration(color: AppTheme.outlineVariant.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(1))),
                        ]),
                      ),
                      _routePoint(context, 'Điểm đến', trip.dropoffLocation, trip.dropoffTime.isNotEmpty ? 'Dự kiến ${trip.dropoffTime}' : '', AppTheme.secondary, false),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Map placeholder
                  Text('Bản đồ lộ trình', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 15)),
                  const SizedBox(height: 12),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: AppTheme.radiusXxl,
                      border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.map_outlined, size: 40, color: AppTheme.outline.withValues(alpha: 0.5)),
                      const SizedBox(height: 8),
                      Text('Bản đồ sẽ hiển thị ở đây', style: TextStyle(fontSize: 13, color: AppTheme.outline.withValues(alpha: 0.5))),
                    ])),
                  ),
                  const SizedBox(height: 24),

                  // Vehicle info
                  Text('Thông tin bổ sung', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 15)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: AppTheme.radiusXxl, boxShadow: AppTheme.cardShadow),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: AppTheme.radiusLg),
                          child: const Icon(Icons.directions_car, color: AppTheme.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Phương tiện', style: TextStyle(fontSize: 12, color: AppTheme.outline)),
                          const SizedBox(height: 2),
                          Text('${trip.vehicleName} • ${trip.licensePlate}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ]),
                      ]),
                      if (trip.driverNote != null) ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        const Text('Ghi chú từ tài xế', style: TextStyle(fontSize: 12, color: AppTheme.outline)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: AppTheme.radiusLg),
                          child: Text('"${trip.driverNote}"', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppTheme.onSurfaceVariant, height: 1.5)),
                        ),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
            // Bottom action
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
              ),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Giá mỗi ghế', style: TextStyle(fontSize: 12, color: AppTheme.outline)),
                  Text(_formatPrice(trip.pricePerSeat), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                ]),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: trip.availableSeats == 0 ? null : () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => BookingBottomSheet(trip: trip),
                      );
                    },
                    child: Text(trip.availableSeats == 0 ? 'Hết chỗ' : 'Đặt chỗ ngay'),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: AppTheme.radiusXxl, boxShadow: AppTheme.cardShadow),
        child: Column(children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onSurface)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.outline)),
        ]),
      ),
    );
  }

  Widget _routePoint(BuildContext context, String label, String location, String detail, Color dotColor, bool isPickup) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 32, height: 32, margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(color: dotColor.withValues(alpha: 0.2), shape: BoxShape.circle),
        child: Icon(isPickup ? Icons.circle : Icons.location_on, size: 14, color: dotColor),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.outline)),
        const SizedBox(height: 4),
        Text(location, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        if (detail.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(detail, style: const TextStyle(fontSize: 12, color: AppTheme.outline)),
        ],
      ])),
    ]);
  }

  String _formatPrice(int price) {
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}k';
    return '${price}đ';
  }
}
