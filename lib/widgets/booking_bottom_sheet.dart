import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/trip.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_theme.dart';

class BookingBottomSheet extends StatefulWidget {
  final Trip trip;

  const BookingBottomSheet({super.key, required this.trip});

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  int _seats = 1;
  String _paymentMethod = 'wallet';

  int get _total => _seats * widget.trip.pricePerSeat;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final walletProvider = context.watch<WalletProvider>();
    final maxSeats = widget.trip.availableSeats.clamp(1, 4);
    final canUseWallet = _total == 0 || walletProvider.balance >= _total;
    final canSubmit =
        !bookingProvider.isLoading &&
        (_paymentMethod != 'wallet' || canUseWallet);

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outlineVariant.withValues(alpha: 0.4),
                    borderRadius: AppTheme.radiusFull,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Xác nhận đặt chỗ',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.trip.pickupLocation} → ${widget.trip.dropoffLocation}',
                style: const TextStyle(color: AppTheme.outline, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.primaryContainer.withValues(
                      alpha: 0.2,
                    ),
                    child: Text(
                      widget.trip.driverName.isNotEmpty
                          ? widget.trip.driverName[0]
                          : '?',
                      style: const TextStyle(
                        color: AppTheme.primary,
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
                          widget.trip.driverName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${widget.trip.vehicleName} · ${widget.trip.licensePlate}',
                          style: const TextStyle(
                            color: AppTheme.outline,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.trip.driverRating}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Số ghế',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: AppTheme.radiusLg,
                    ),
                    child: Row(
                      children: [
                        _seatBtn(Icons.remove, () {
                          if (_seats > 1) setState(() => _seats--);
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$_seats',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        _seatBtn(Icons.add, () {
                          if (_seats < maxSeats) setState(() => _seats++);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Còn ${widget.trip.availableSeats} chỗ trống',
                style: const TextStyle(color: AppTheme.outline, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: AppTheme.radiusXxl,
                ),
                child: Column(
                  children: [
                    _priceRow(
                      'Giá mỗi ghế',
                      _fmtPrice(widget.trip.pricePerSeat),
                    ),
                    const SizedBox(height: 8),
                    _priceRow('Số ghế', 'x $_seats'),
                    const Divider(height: 20),
                    _priceRow('Tổng cộng', _fmtPrice(_total), isTotal: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Khởi hành: ${widget.trip.pickupTime}',
                    style: const TextStyle(
                      color: AppTheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Thanh toán',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 10),
              _paymentOption(
                icon: Icons.account_balance_wallet,
                title: 'Ví SmartCarpool',
                subtitle: _total == 0
                    ? 'Chuyến này miễn phí'
                    : 'Số dư: ${_fmtPrice(walletProvider.balance)}',
                value: 'wallet',
                enabled: canUseWallet,
              ),
              const SizedBox(height: 8),
              _paymentOption(
                icon: Icons.payments_outlined,
                title: 'Tiền mặt',
                subtitle: 'Ghi nhận đặt chỗ, thanh toán khi lên xe',
                value: 'cash',
                enabled: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: !canSubmit
                      ? null
                      : () => _submitBooking(context, auth.currentUser),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusLg,
                    ),
                    elevation: 0,
                  ),
                  child: bookingProvider.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Đặt chỗ · ${_fmtPrice(_total)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitBooking(BuildContext context, dynamic user) async {
    final bookingProvider = context.read<BookingProvider>();
    final paymentMethod = _total == 0 ? 'free' : _paymentMethod;
    final booking = await bookingProvider.bookTrip(
      tripId: widget.trip.id,
      passengerId: user?.id ?? 'guest',
      passengerName: user?.fullName ?? 'Khách',
      passengerAvatar: user?.avatarUrl ?? '',
      seatsBooked: _seats,
      pricePerSeat: widget.trip.pricePerSeat,
      paymentMethod: paymentMethod,
    );

    if (!context.mounted) return;
    if (booking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bookingProvider.error?.replaceAll('Exception: ', '') ??
                'Không thể đặt chỗ',
          ),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    context.read<TripProvider>().applyBookedSeats(widget.trip.id, _seats);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSuccessScreen(
          trip: widget.trip,
          seatsBooked: _seats,
          totalPrice: _total,
          paymentMethod: paymentMethod,
        ),
      ),
    );
  }

  Widget _seatBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusLg,
        ),
        child: Icon(icon, size: 18, color: AppTheme.primary),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isTotal ? AppTheme.onSurface : AppTheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? AppTheme.primary : AppTheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _paymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required bool enabled,
  }) {
    final selected = _paymentMethod == value;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GestureDetector(
        onTap: enabled ? () => setState(() => _paymentMethod = value) : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withValues(alpha: 0.08)
                : AppTheme.surfaceContainerLow,
            borderRadius: AppTheme.radiusLg,
            border: Border.all(
              color: selected ? AppTheme.primary : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppTheme.primary : AppTheme.outline),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      enabled ? subtitle : 'Số dư ví không đủ',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: AppTheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtPrice(int price) {
    final raw = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$raw đ';
  }
}

class BookingSuccessScreen extends StatefulWidget {
  final Trip trip;
  final int seatsBooked;
  final int totalPrice;
  final String paymentMethod;

  const BookingSuccessScreen({
    super.key,
    required this.trip,
    required this.seatsBooked,
    required this.totalPrice,
    required this.paymentMethod,
  });

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, Color(0xFF00A366)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          Text(
                            'Đặt chỗ thành công!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Chuyến đi của bạn đã được xác nhận',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.outline,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: AppTheme.radiusXxl,
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        children: [
                          _summaryRow(
                            Icons.person,
                            'Tài xế',
                            widget.trip.driverName,
                          ),
                          const Divider(height: 20),
                          _summaryRow(
                            Icons.circle,
                            'Điểm đón',
                            widget.trip.pickupLocation,
                          ),
                          const SizedBox(height: 8),
                          _summaryRow(
                            Icons.location_on,
                            'Điểm đến',
                            widget.trip.dropoffLocation,
                          ),
                          const Divider(height: 20),
                          _summaryRow(
                            Icons.access_time,
                            'Khởi hành',
                            widget.trip.pickupTime,
                          ),
                          const SizedBox(height: 8),
                          _summaryRow(
                            Icons.event_seat,
                            'Số ghế',
                            '${widget.seatsBooked} ghế',
                          ),
                          const SizedBox(height: 8),
                          _summaryRow(
                            Icons.account_balance_wallet_outlined,
                            'Thanh toán',
                            _paymentLabel(widget.paymentMethod),
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Icon(
                                Icons.payments_outlined,
                                size: 18,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Tổng tiền',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _fmtPrice(widget.totalPrice),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/main',
                            (r) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.radiusLg,
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Về trang chủ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/main',
                            (r) => false,
                          );
                          Navigator.pushNamed(context, '/my-trips');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.radiusLg,
                          ),
                        ),
                        child: const Text(
                          'Xem chuyến đi của tôi',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.outline),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: AppTheme.outline, fontSize: 13),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _paymentLabel(String method) {
    switch (method) {
      case 'free':
        return 'Miễn phí';
      case 'wallet':
        return 'Đã trừ Ví SmartCarpool';
      default:
        return 'Tiền mặt khi lên xe';
    }
  }

  String _fmtPrice(int price) {
    final raw = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$raw đ';
  }
}
