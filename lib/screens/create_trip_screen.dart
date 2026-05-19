import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/auth_provider.dart';
import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});
  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final String _selectedVehicle = 'VinFast VF8 - Trắng';
  final _pickupCtrl = TextEditingController();
  final _dropoffCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '50000');
  final _noteCtrl = TextEditingController();
  int _seats = 3;
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng chuyến'),
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
            // Vehicle selector
            _sectionTitle('Phương tiện'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppTheme.radiusXxl,
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: AppTheme.radiusLg,
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: AppTheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedVehicle,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '29A-123.45',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.outline),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.outline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Route
            _sectionTitle('Lộ trình'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppTheme.radiusXxl,
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  _routeField(
                    Icons.circle,
                    'Điểm đón',
                    'Nhập điểm đón',
                    AppTheme.primaryContainer,
                    _pickupCtrl,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Row(
                      children: [
                        Container(
                          width: 2,
                          height: 24,
                          color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                  _routeField(
                    Icons.location_on,
                    'Điểm đến',
                    'Nhập điểm đến',
                    AppTheme.secondary,
                    _dropoffCtrl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date & Time
            _sectionTitle('Thời gian'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    Icons.calendar_today,
                    'Ngày',
                    '${_date.day}/${_date.month}/${_date.year}',
                    () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) setState(() => _date = d);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard(
                    Icons.access_time,
                    'Giờ',
                    '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                    () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: _time,
                      );
                      if (t != null) setState(() => _time = t);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Seats & Price
            _sectionTitle('Chi tiết'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.radiusXxl,
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Số ghế trống',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _seatBtn(Icons.remove, () {
                              if (_seats > 1) setState(() => _seats--);
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                '$_seats',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                            _seatBtn(Icons.add, () {
                              if (_seats < 6) setState(() => _seats++);
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.radiusXxl,
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Giá/Ghế',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                          decoration: const InputDecoration(
                            hintText: '50000',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Note
            _sectionTitle('Ghi chú'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Thêm ghi chú cho hành khách...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: AppTheme.radiusXl,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: () async {
                final auth = context.read<AuthProvider>();
                final tripProv = context.read<TripProvider>();
                final user = auth.currentUser;

                if (_pickupCtrl.text.isEmpty || _dropoffCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập điểm đón và điểm đến'),
                    ),
                  );
                  return;
                }

                final trip = Trip(
                  id: '',
                  driverName: user?.fullName ?? 'Tài xế',
                  driverRating: user?.rating ?? 5.0,
                  vehicleName: _selectedVehicle,
                  licensePlate: '29A-123.45',
                  pickupLocation: _pickupCtrl.text,
                  dropoffLocation: _dropoffCtrl.text,
                  pickupTime:
                      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                  pricePerSeat:
                      int.tryParse(_priceCtrl.text.replaceAll('.', '')) ??
                      50000,
                  totalSeats: _seats,
                  availableSeats: _seats,
                  driverNote: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
                );

                final created = await tripProv.createTrip(
                  trip,
                  user?.id ?? 'anonymous',
                );
                if (!context.mounted) return;

                if (created != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Đã đăng chuyến thành công!'),
                      backgroundColor: AppTheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.radiusLg,
                      ),
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tripProv.error ?? 'Không thể tạo chuyến'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Đăng chuyến'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppTheme.onSurfaceVariant,
    ),
  );

  Widget _routeField(
    IconData icon,
    String label,
    String hint,
    Color color,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
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
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintStyle: TextStyle(fontSize: 14, color: AppTheme.outline),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoCard(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusXxl,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.outline),
            ),
            const SizedBox(height: 4),
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
    );
  }

  Widget _seatBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: AppTheme.radiusFull,
        ),
        child: Icon(icon, size: 18, color: AppTheme.primary),
      ),
    );
  }
}
