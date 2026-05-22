import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/trip_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    this.initialFrom = '',
    this.initialTo = '',
    this.initialQuickFilter = 'all',
  });

  final String initialFrom;
  final String initialTo;
  final String initialQuickFilter;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _passengerCount = 1;
  String _selectedFilter = 'all';
  bool _hasSearched = false;
  bool _isLocating = false;
  bool _usesCurrentLocation = false;
  double _radiusKm = 5;
  double? _currentLatitude;
  double? _currentLongitude;
  String? _locationMessage;

  static const _radiusOptions = [3.0, 5.0, 10.0, 20.0];
  static const _filters = [
    _SearchQuickFilter('all', 'Tất cả'),
    _SearchQuickFilter('newest', 'Mới đăng'),
    _SearchQuickFilter('car', 'Ô tô'),
    _SearchQuickFilter('motorbike', 'Xe máy'),
    _SearchQuickFilter('cheap', 'Giá rẻ'),
    _SearchQuickFilter('nearby', 'Quanh bạn'),
  ];

  @override
  void initState() {
    super.initState();
    _fromCtrl.text = widget.initialFrom;
    _toCtrl.text = widget.initialTo;
    _selectedFilter = widget.initialQuickFilter;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyInitialState();
    });
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  Future<void> _applyInitialState() async {
    final provider = context.read<TripProvider>();
    provider.resetFilters();
    provider.setMinSeats(_passengerCount);

    if (!mounted) return;
    await _applyQuickFilter(_selectedFilter, autoSearch: true);
  }

  Future<void> _doSearch() async {
    FocusScope.of(context).unfocus();
    await context.read<TripProvider>().search(
      _fromCtrl.text,
      _toCtrl.text,
      date: _selectedDate,
      time: _selectedTime,
      useCurrentLocation: _usesCurrentLocation,
      currentLatitude: _currentLatitude,
      currentLongitude: _currentLongitude,
      radiusKm: _radiusKm,
    );
    if (!mounted) return;
    setState(() => _hasSearched = true);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _showFilter() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<TripProvider>(),
        child: const FilterBottomSheet(),
      ),
    );

    if (!mounted) return;
    await _doSearch();
  }

  Future<void> _applyQuickFilter(
    String filter, {
    bool autoSearch = true,
  }) async {
    final provider = context.read<TripProvider>();

    provider.setVehicleFilter('all');
    provider.setSort(_usesCurrentLocation ? 'distance' : 'newest');

    switch (filter) {
      case 'car':
        provider.setVehicleFilter('car');
        break;
      case 'motorbike':
        provider.setVehicleFilter('motorbike');
        break;
      case 'cheap':
        provider.setSort('price_asc');
        break;
      case 'nearby':
        provider.setSort('distance');
        final enabled = await _enableCurrentLocation();
        if (!enabled) {
          if (!mounted) return;
          setState(() => _selectedFilter = 'all');
          provider.setSort('newest');
          return;
        }
        break;
      default:
        if (_usesCurrentLocation) {
          await provider.clearLocationSearch();
          if (!mounted) return;
          setState(() {
            _usesCurrentLocation = false;
            _locationMessage = null;
            _currentLatitude = null;
            _currentLongitude = null;
          });
        }
    }

    if (autoSearch) {
      await _doSearch();
    }
  }

  Future<bool> _enableCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _locationMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLocating = false;
          _locationMessage = 'Hãy bật định vị để tìm chuyến quanh bạn.';
        });
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _isLocating = false;
          _locationMessage = 'Ứng dụng chưa có quyền truy cập vị trí.';
        });
        return false;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return false;

      setState(() {
        _isLocating = false;
        _usesCurrentLocation = true;
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
        _locationMessage =
            'Đang hiển thị chuyến trong bán kính ${_radiusKm.toInt()} km.';
      });
      return true;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _isLocating = false;
        _locationMessage = 'Không lấy được vị trí hiện tại của bạn.';
      });
      return false;
    }
  }

  Future<void> _toggleCurrentLocation() async {
    if (_usesCurrentLocation) {
      await context.read<TripProvider>().clearLocationSearch();
      if (!mounted) return;
      setState(() {
        _usesCurrentLocation = false;
        _currentLatitude = null;
        _currentLongitude = null;
        _locationMessage = null;
        if (_selectedFilter == 'nearby') {
          _selectedFilter = 'all';
        }
      });
      await _doSearch();
      return;
    }

    final enabled = await _enableCurrentLocation();
    if (!enabled) return;

    if (!mounted) return;
    setState(() => _selectedFilter = 'nearby');
    context.read<TripProvider>().setSort('distance');
    await _doSearch();
  }

  Future<void> _changeRadius(double radiusKm) async {
    setState(() {
      _radiusKm = radiusKm;
      if (_usesCurrentLocation) {
        _locationMessage =
            'Đang hiển thị chuyến trong bán kính ${_radiusKm.toInt()} km.';
      }
    });
    context.read<TripProvider>().setSearchRadiusKm(radiusKm);
    if (_usesCurrentLocation) {
      await _doSearch();
    }
  }

  Future<void> _clearDateTime() async {
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });
    await _doSearch();
  }

  String get _dateLabel {
    if (_selectedDate == null) return 'Ngày bất kỳ';
    final d = _selectedDate!;
    return '${d.day}/${d.month}/${d.year}';
  }

  String get _timeLabel {
    if (_selectedTime == null) return 'Giờ bất kỳ';
    return _selectedTime!.format(context);
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final trips = tripProvider.searchResults;
    final hasDateTimeFilter = _selectedDate != null || _selectedTime != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Tìm kiếm',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showFilter,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color:
                            tripProvider.vehicleFilter != 'all' ||
                                tripProvider.sortBy != 'newest' ||
                                tripProvider.minSeats > 1
                            ? AppTheme.primary
                            : AppTheme.surfaceContainerLow,
                        borderRadius: AppTheme.radiusFull,
                      ),
                      child: Icon(
                        Icons.tune,
                        color:
                            tripProvider.vehicleFilter != 'all' ||
                                tripProvider.sortBy != 'newest' ||
                                tripProvider.minSeats > 1
                            ? Colors.white
                            : AppTheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTheme.radiusXxl,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    _buildSearchInput(
                      controller: _fromCtrl,
                      hint: 'Điểm đón',
                      icon: Icons.circle,
                      iconColor: AppTheme.primaryContainer,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 7),
                      child: Row(
                        children: [
                          Container(
                            width: 2,
                            height: 18,
                            color: AppTheme.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSearchInput(
                      controller: _toCtrl,
                      hint: 'Điểm đến',
                      icon: Icons.location_on,
                      iconColor: AppTheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickDate,
                            child: _inputChip(Icons.calendar_today, _dateLabel),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickTime,
                            child: _inputChip(Icons.schedule, _timeLabel),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: _showPassengerPicker,
                            child: _inputChip(
                              Icons.person,
                              '$_passengerCount người',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _doSearch,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primary, Color(0xFF00A366)],
                              ),
                              borderRadius: AppTheme.radiusLg,
                            ),
                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLocating ? null : _toggleCurrentLocation,
                            icon: Icon(
                              _usesCurrentLocation
                                  ? Icons.my_location
                                  : Icons.location_searching,
                              size: 18,
                            ),
                            label: Text(
                              _usesCurrentLocation
                                  ? 'Đang dùng vị trí của bạn'
                                  : 'Dùng vị trí hiện tại',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: BorderSide(
                                color: AppTheme.primary.withValues(alpha: 0.35),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.radiusLg,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: AppTheme.radiusLg,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<double>(
                              value: _radiusKm,
                              items: _radiusOptions
                                  .map(
                                    (km) => DropdownMenuItem(
                                      value: km,
                                      child: Text('${km.toInt()} km'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                _changeRadius(value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (hasDateTimeFilter) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _clearDateTime,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(color: AppTheme.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.radiusLg,
                            ),
                          ),
                          child: const Text('Xóa ngày giờ'),
                        ),
                      ),
                    ],
                    if (_locationMessage != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            _usesCurrentLocation
                                ? Icons.info_outline
                                : Icons.warning_amber_rounded,
                            size: 16,
                            color: _usesCurrentLocation
                                ? AppTheme.primary
                                : AppTheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _locationMessage!,
                              style: TextStyle(
                                fontSize: 12,
                                color: _usesCurrentLocation
                                    ? AppTheme.primary
                                    : AppTheme.outline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filters.length,
                  itemBuilder: (ctx, i) {
                    final filter = _filters[i];
                    final selected = filter.id == _selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () async {
                          setState(() => _selectedFilter = filter.id);
                          await _applyQuickFilter(filter.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.surfaceContainerLow,
                            borderRadius: AppTheme.radiusFull,
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.outlineVariant.withValues(
                                      alpha: 0.4,
                                    ),
                            ),
                          ),
                          child: Text(
                            filter.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : AppTheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _usesCurrentLocation
                        ? 'Chuyến trong bán kính ${_radiusKm.toInt()} km'
                        : _hasSearched
                        ? 'Kết quả tìm kiếm'
                        : 'Tất cả chuyến hiện có',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(fontSize: 15),
                  ),
                  if (tripProvider.isLoading || _isLocating)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary,
                      ),
                    )
                  else
                    Text(
                      '${trips.length} chuyến',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Expanded(
              child: tripProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : trips.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: trips.length,
                      itemBuilder: (ctx, i) {
                        final trip = trips[i];
                        final distanceKm = tripProvider.distanceForTrip(trip.id);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (distanceKm != null)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  8,
                                  20,
                                  0,
                                ),
                                child: Text(
                                  'Cách bạn ${distanceKm.toStringAsFixed(1)} km',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            TripCard(
                              trip: trip,
                              onTap: () => Navigator.pushNamed(
                                ctx,
                                '/trip-detail',
                                arguments: trip,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPassengerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: StatefulBuilder(
          builder: (ctx, setS) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Số hành khách',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _paxBtn(
                    Icons.remove,
                    () => setS(() {
                      if (_passengerCount > 1) {
                        _passengerCount--;
                        setState(() {});
                      }
                    }),
                  ),
                  const SizedBox(width: 32),
                  Text(
                    '$_passengerCount',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 32),
                  _paxBtn(
                    Icons.add,
                    () => setS(() {
                      if (_passengerCount < 4) {
                        _passengerCount++;
                        setState(() {});
                      }
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    context.read<TripProvider>().setMinSeats(_passengerCount);
                    Navigator.pop(ctx);
                    await _doSearch();
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
                    'Xác nhận',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paxBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.primary),
      ),
    );
  }

  Widget _buildSearchInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: (_) => _doSearch(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppTheme.outline.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _inputChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: AppTheme.radiusMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppTheme.outline),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final message = _usesCurrentLocation
        ? 'Không có chuyến nào trong bán kính ${_radiusKm.toInt()} km.'
        : 'Thử thay đổi điểm đi, điểm đến, ngày giờ hoặc bộ lọc.';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 32,
              color: AppTheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy chuyến đi',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(color: AppTheme.outline, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SearchQuickFilter {
  const _SearchQuickFilter(this.id, this.label);

  final String id;
  final String label;
}
