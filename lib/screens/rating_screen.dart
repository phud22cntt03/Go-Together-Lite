import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/trip.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';

class RatingScreen extends StatefulWidget {
  final Booking booking;
  final Trip trip;

  const RatingScreen({super.key, required this.booking, required this.trip});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  late double _rating;
  final _commentCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.booking.passengerRating ?? 5.0;
    _commentCtrl.text = widget.booking.ratingComment ?? '';
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rated = widget.booking.passengerRating != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đánh giá chuyến đi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: AppTheme.radiusXxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.trip.driverName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.trip.pickupLocation} → ${widget.trip.dropoffLocation}',
                    style: const TextStyle(color: AppTheme.outline),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.trip.vehicleName} • ${widget.trip.licensePlate}',
                    style: const TextStyle(color: AppTheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bạn chấm bao nhiêu sao cho chuyến này?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1.0;
                final selected = _rating >= starValue;
                return IconButton(
                  onPressed: () => setState(() => _rating = starValue),
                  icon: Icon(
                    selected ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 34,
                    color: selected ? Colors.amber : AppTheme.outline,
                  ),
                );
              }),
            ),
            Center(
              child: Text(
                _rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Thêm nhận xét của bạn...',
                filled: true,
                fillColor: AppTheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: AppTheme.radiusXl,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _saving = true);
                        try {
                          await BookingService.rateTrip(
                            bookingId: widget.booking.id,
                            passengerRating: _rating,
                            comment: _commentCtrl.text.trim().isEmpty
                                ? null
                                : _commentCtrl.text.trim(),
                          );
                          if (!mounted) return;
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                rated
                                    ? 'Đã cập nhật đánh giá'
                                    : 'Đã gửi đánh giá',
                              ),
                              backgroundColor: AppTheme.primary,
                            ),
                          );
                        } catch (e) {
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Không thể lưu đánh giá: $e'),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _saving = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusLg,
                  ),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(rated ? 'Cập nhật đánh giá' : 'Gửi đánh giá'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
