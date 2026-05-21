import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../theme/app_theme.dart';

class HistoryCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;

  const HistoryCard({super.key, required this.trip, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCompleted = trip.status == 'completed';
    final isCancelled = trip.status == 'cancelled';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusXxl,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: isCompleted
                        ? AppTheme.primaryContainer.withValues(alpha: 0.3)
                        : AppTheme.errorContainer.withValues(alpha: 0.5),
                    child: Text(
                      trip.driverName[0],
                      style: TextStyle(
                        color: isCompleted ? AppTheme.primary : AppTheme.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.driverName,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${trip.vehicleName} • ${trip.licensePlate}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.outline),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatPrice(trip.pricePerSeat),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.primary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.primaryContainer.withValues(alpha: 0.2)
                              : isCancelled
                              ? AppTheme.errorContainer.withValues(alpha: 0.3)
                              : AppTheme.surfaceContainerHigh,
                          borderRadius: AppTheme.radiusFull,
                        ),
                        child: Text(
                          isCompleted
                              ? 'Hoàn thành'
                              : isCancelled
                              ? 'Đã hủy'
                              : trip.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? AppTheme.primary
                                : isCancelled
                                ? AppTheme.error
                                : AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 56),
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppTheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${trip.pickupLocation} • ${trip.pickupTime}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 56),
                  const Icon(
                    Icons.flag_outlined,
                    size: 14,
                    color: AppTheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      trip.dropoffLocation,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    if (price >= 1000) {
      final formatted = (price / 1000).toStringAsFixed(0);
      return '$formatted.000đ';
    }
    return '$priceđ';
  }
}
