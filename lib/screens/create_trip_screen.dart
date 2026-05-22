import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trip.dart';
import '../models/vehicle.dart';
import '../providers/auth_provider.dart';
import '../providers/trip_provider.dart';
import '../services/vehicle_service.dart';
import '../theme/app_theme.dart';
import '../widgets/trip_route_map.dart';
import 'location_picker_screen.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _priceCtrl = TextEditingController(text: '0');
  final _noteCtrl = TextEditingController();

  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  PickedLocation? _pickupLocation;
  PickedLocation? _dropoffLocation;
  bool _loadingVehicles = true;

  int _seats = 1;
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVehicles());
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

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
            _sectionTitle('Phương tiện'),
            const SizedBox(height: 8),
            _buildVehicleSelector(),
            const SizedBox(height: 24),
            _sectionTitle('Lộ trình'),
            const SizedBox(height: 8),
            _buildRouteSelector(),
            const SizedBox(height: 16),
            TripRouteMap(
              pickupLat: _pickupLocation?.latitude,
              pickupLng: _pickupLocation?.longitude,
              dropoffLat: _dropoffLocation?.latitude,
              dropoffLng: _dropoffLocation?.longitude,
            ),
            const SizedBox(height: 24),
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
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (selectedDate != null) {
                        setState(() => _date = selectedDate);
                      }
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
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: _time,
                      );
                      if (selectedTime != null) {
                        setState(() => _time = selectedTime);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle('Chi tiết'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildSeatsCard()),
                const SizedBox(width: 12),
                Expanded(child: _buildPriceCard()),
              ],
            ),
            const SizedBox(height: 24),
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
            ElevatedButton(
              onPressed: () =>
                  _submitTrip(user?.id, user?.fullName, user?.rating),
              child: const Text('Đăng chuyến'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelector() {
    if (_loadingVehicles) {
      return Container(
        height: 92,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusXxl,
          boxShadow: AppTheme.cardShadow,
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_vehicles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusXxl,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn chưa có phương tiện nào để đăng chuyến.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thêm xe trước rồi quay lại màn đăng chuyến để chọn xe thực tế.',
              style: TextStyle(color: AppTheme.outline),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(context, '/vehicles');
                if (mounted) {
                  setState(() => _loadingVehicles = true);
                  await _loadVehicles();
                }
              },
              icon: const Icon(Icons.directions_car_outlined),
              label: const Text('Quản lý phương tiện'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusXxl,
        boxShadow: AppTheme.cardShadow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Vehicle>(
          value: _selectedVehicle,
          isExpanded: true,
          items: _vehicles.map((vehicle) {
            return DropdownMenuItem<Vehicle>(
              value: vehicle,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: AppTheme.radiusLg,
                    ),
                    child: Icon(
                      vehicle.type == 'car'
                          ? Icons.directions_car
                          : Icons.two_wheeler,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          vehicle.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${vehicle.licensePlate} • ${vehicle.color} • ${vehicle.seats} chỗ',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (vehicle) {
            if (vehicle == null) return;
            setState(() {
              _selectedVehicle = vehicle;
              final maxSeats = _maxSelectableSeats(vehicle);
              if (_seats > maxSeats) {
                _seats = maxSeats;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildRouteSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusXxl,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          _routeTile(
            label: 'Điểm đón',
            value: _pickupLocation?.label ?? 'Chọn điểm đón trên bản đồ',
            icon: Icons.trip_origin,
            color: AppTheme.primary,
            onTap: () => _pickLocation(isPickup: true),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
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
          _routeTile(
            label: 'Điểm đến',
            value: _dropoffLocation?.label ?? 'Chọn điểm đến trên bản đồ',
            icon: Icons.location_on,
            color: AppTheme.secondary,
            onTap: () => _pickLocation(isPickup: false),
          ),
        ],
      ),
    );
  }

  Widget _routeTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final hasValue =
        value.trim().isNotEmpty &&
        value != 'Chọn điểm đón trên bản đồ' &&
        value != 'Chọn điểm đến trên bản đồ';

    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.radiusLg,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                      color: hasValue ? AppTheme.onSurface : AppTheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.map_outlined, color: AppTheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatsCard() {
    final maxSeats = _selectedVehicle == null
        ? 6
        : _maxSelectableSeats(_selectedVehicle!);

    return Container(
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
            style: TextStyle(fontSize: 12, color: AppTheme.outline),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _seatBtn(Icons.remove, () {
                if (_seats > 1) {
                  setState(() => _seats--);
                }
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                if (_seats < maxSeats) {
                  setState(() => _seats++);
                }
              }),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tối đa $maxSeats ghế với xe hiện tại',
            style: const TextStyle(fontSize: 11, color: AppTheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
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
            style: TextStyle(fontSize: 12, color: AppTheme.outline),
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
              hintText: '0',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhap 0 neu ban cho di mien phi.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppTheme.outline),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gia tien hien chi de hien thi/thong ke, chua co tru tien tu dong.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppTheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppTheme.onSurfaceVariant,
    ),
  );

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

  int _maxSelectableSeats(Vehicle vehicle) {
    if (vehicle.type == 'motorbike') {
      return 1;
    }
    return vehicle.seats > 1 ? vehicle.seats - 1 : 1;
  }

  Future<void> _loadVehicles() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      setState(() => _loadingVehicles = false);
      return;
    }

    try {
      final vehicles = await VehicleService.getVehicles(user.id);
      if (!mounted) return;

      setState(() {
        _vehicles = vehicles;
        _selectedVehicle = vehicles.isEmpty
            ? null
            : vehicles.firstWhere(
                (vehicle) => vehicle.isDefault,
                orElse: () => vehicles.first,
              );
        _seats = _selectedVehicle == null
            ? 1
            : _maxSelectableSeats(_selectedVehicle!);
        _loadingVehicles = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingVehicles = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không tải được phương tiện: $e')));
    }
  }

  Future<void> _pickLocation({required bool isPickup}) async {
    final result = await Navigator.push<PickedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          title: isPickup ? 'Chọn điểm đón' : 'Chọn điểm đến',
          initialLocation: isPickup ? _pickupLocation : _dropoffLocation,
        ),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      if (isPickup) {
        _pickupLocation = result;
      } else {
        _dropoffLocation = result;
      }
    });
  }

  Future<void> _submitTrip(
    String? userId,
    String? fullName,
    double? rating,
  ) async {
    final tripProvider = context.read<TripProvider>();

    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phương tiện thực tế')),
      );
      return;
    }

    if (_pickupLocation == null || _dropoffLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn điểm đón và điểm đến trên bản đồ'),
        ),
      );
      return;
    }

    final price = int.tryParse(_priceCtrl.text.replaceAll('.', '').trim());
    if (price == null || price < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Giá tiền không hợp lệ')));
      return;
    }

    final trip = Trip(
      id: '',
      driverName: fullName ?? 'Tài xế',
      driverRating: rating ?? 5.0,
      vehicleName: _selectedVehicle!.name,
      licensePlate: _selectedVehicle!.licensePlate,
      vehicleType: _selectedVehicle!.type,
      pickupLocation: _pickupLocation!.label,
      dropoffLocation: _dropoffLocation!.label,
      pickupLat: _pickupLocation!.latitude,
      pickupLng: _pickupLocation!.longitude,
      dropoffLat: _dropoffLocation!.latitude,
      dropoffLng: _dropoffLocation!.longitude,
      pickupTime:
          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')} - ${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}',
      pricePerSeat: price,
      totalSeats: _selectedVehicle!.seats,
      availableSeats: _seats,
      driverNote: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    final created = await tripProvider.createTrip(trip, userId ?? 'anonymous');
    if (!mounted) return;

    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã đăng chuyến thành công'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg),
        ),
      );
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tripProvider.error ?? 'Không thể tạo chuyến'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
