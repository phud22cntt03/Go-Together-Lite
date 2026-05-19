import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/trip_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _sort;
  late String _vehicle;
  late int _seats;

  @override
  void initState() {
    super.initState();
    final p = context.read<TripProvider>();
    _sort = p.sortBy;
    _vehicle = p.vehicleFilter;
    _seats = p.minSeats;
  }

  void _apply() {
    final p = context.read<TripProvider>();
    p.setSort(_sort);
    p.setVehicleFilter(_vehicle);
    p.setMinSeats(_seats);
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _sort = 'newest';
      _vehicle = 'all';
      _seats = 1;
    });
    context.read<TripProvider>().resetFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.outlineVariant.withValues(alpha: 0.4), borderRadius: AppTheme.radiusFull),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(children: [
            Text('Bộ lọc tìm kiếm', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(onPressed: _reset, child: const Text('Đặt lại', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 24),

          // Sort section
          _sectionTitle('Sắp xếp theo'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip('Mới nhất', 'newest'),
              _chip('Giá thấp nhất', 'price_asc'),
              _chip('Giá cao nhất', 'price_desc'),
              _chip('Đánh giá cao', 'rating'),
            ],
          ),
          const SizedBox(height: 24),

          // Vehicle type
          _sectionTitle('Loại phương tiện'),
          const SizedBox(height: 12),
          Row(children: [
            _vehicleChip('Tất cả', 'all', Icons.all_inclusive),
            const SizedBox(width: 8),
            _vehicleChip('Ô tô', 'car', Icons.directions_car_outlined),
            const SizedBox(width: 8),
            _vehicleChip('Xe máy', 'motorbike', Icons.two_wheeler_outlined),
          ]),
          const SizedBox(height: 24),

          // Min seats
          _sectionTitle('Số ghế tối thiểu: $_seats'),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.surfaceContainerLow,
              thumbColor: AppTheme.primary,
              overlayColor: AppTheme.primary.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
            ),
            child: Slider(
              value: _seats.toDouble(),
              min: 1,
              max: 4,
              divisions: 3,
              onChanged: (v) => setState(() => _seats = v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (i) => Text('${i + 1}', style: const TextStyle(fontSize: 12, color: AppTheme.outline))),
          ),
          const SizedBox(height: 28),

          // Apply button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg),
                elevation: 0,
              ),
              child: const Text('Áp dụng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.onSurface));
  }

  Widget _chip(String label, String value) {
    final selected = _sort == value;
    return GestureDetector(
      onTap: () => setState(() => _sort = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surfaceContainerLow,
          borderRadius: AppTheme.radiusFull,
          border: Border.all(color: selected ? AppTheme.primary : Colors.transparent),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? Colors.white : AppTheme.onSurface,
        )),
      ),
    );
  }

  Widget _vehicleChip(String label, String value, IconData icon) {
    final selected = _vehicle == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _vehicle = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary.withValues(alpha: 0.08) : AppTheme.surfaceContainerLow,
            borderRadius: AppTheme.radiusLg,
            border: Border.all(color: selected ? AppTheme.primary : Colors.transparent, width: 1.5),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 22, color: selected ? AppTheme.primary : AppTheme.outline),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppTheme.primary : AppTheme.onSurface,
            )),
          ]),
        ),
      ),
    );
  }
}
