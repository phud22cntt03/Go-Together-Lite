import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/trip_card.dart';
import '../widgets/filter_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  DateTime? _selectedDate;
  int _passengerCount = 1;
  String _selectedFilter = 'Tất cả';
  final _filters = ['Tất cả', 'Ô tô', 'Xe máy', 'Giá rẻ', 'Gần nhất'];
  bool _hasSearched = false;

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  void _doSearch() {
    FocusScope.of(context).unfocus();
    context.read<TripProvider>().search(_fromCtrl.text, _toCtrl.text);
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
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<TripProvider>(),
        child: const FilterBottomSheet(),
      ),
    );
  }

  String get _dateLabel {
    if (_selectedDate == null) return 'Hôm nay';
    final d = _selectedDate!;
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final trips = tripProvider.searchResults;

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
                  Text('Tìm kiếm', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showFilter,
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: tripProvider.vehicleFilter != 'all' || tripProvider.sortBy != 'newest' || tripProvider.minSeats > 1
                            ? AppTheme.primary
                            : AppTheme.surfaceContainerLow,
                        borderRadius: AppTheme.radiusFull,
                      ),
                      child: Icon(
                        Icons.tune,
                        color: tripProvider.vehicleFilter != 'all' || tripProvider.sortBy != 'newest' || tripProvider.minSeats > 1
                            ? Colors.white
                            : AppTheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search card
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: AppTheme.radiusXxl, boxShadow: AppTheme.cardShadow),
                child: Column(children: [
                  // From
                  _buildSearchInput(
                    controller: _fromCtrl,
                    hint: 'Điểm đón',
                    icon: Icons.circle,
                    iconColor: AppTheme.primaryContainer,
                    onChanged: (_) {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Row(children: [
                      Container(width: 2, height: 18, color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
                    ]),
                  ),
                  // To
                  _buildSearchInput(
                    controller: _toCtrl,
                    hint: 'Điểm đến',
                    icon: Icons.location_on,
                    iconColor: AppTheme.secondary,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 12),
                  // Date/Pax/Search row
                  Row(children: [
                    // Date
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: _inputChip(Icons.calendar_today, _dateLabel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Passengers
                    Expanded(
                      child: GestureDetector(
                        onTap: _showPassengerPicker,
                        child: _inputChip(Icons.person, '$_passengerCount người'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Search button
                    GestureDetector(
                      onTap: _doSearch,
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF00A366)]),
                          borderRadius: AppTheme.radiusLg,
                        ),
                        child: const Icon(Icons.search, color: Colors.white, size: 22),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),

            // Filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filters.length,
                  itemBuilder: (ctx, i) {
                    final selected = _filters[i] == _selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedFilter = _filters[i]);
                          _applyQuickFilter(_filters[i]);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.primary : AppTheme.surfaceContainerLow,
                            borderRadius: AppTheme.radiusFull,
                            border: Border.all(color: selected ? AppTheme.primary : AppTheme.outlineVariant.withValues(alpha: 0.4)),
                          ),
                          child: Text(_filters[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? Colors.white : AppTheme.onSurface)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Results header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  _hasSearched ? 'Kết quả tìm kiếm' : 'Chuyến đi hiện có',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 15),
                ),
                if (tripProvider.isLoading)
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
                else
                  Text('${trips.length} chuyến', style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),

            // Results list
            Expanded(
              child: tripProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : trips.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: trips.length,
                          itemBuilder: (ctx, i) => TripCard(
                            trip: trips[i],
                            onTap: () => Navigator.pushNamed(ctx, '/trip-detail', arguments: trips[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyQuickFilter(String f) {
    final p = context.read<TripProvider>();
    switch (f) {
      case 'Ô tô': p.setVehicleFilter('car'); break;
      case 'Xe máy': p.setVehicleFilter('motorbike'); break;
      case 'Giá rẻ': p.setSort('price_asc'); p.setVehicleFilter('all'); break;
      case 'Gần nhất': p.setSort('newest'); p.setVehicleFilter('all'); break;
      default: p.resetFilters();
    }
  }

  void _showPassengerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: StatefulBuilder(builder: (ctx, setS) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Số hành khách', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _paxBtn(Icons.remove, () => setS(() { if (_passengerCount > 1) { _passengerCount--; setState(() {}); } })),
              const SizedBox(width: 32),
              Text('$_passengerCount', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              const SizedBox(width: 32),
              _paxBtn(Icons.add, () => setS(() { if (_passengerCount < 4) { _passengerCount++; setState(() {}); } })),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context.read<TripProvider>().setMinSeats(_passengerCount);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg), elevation: 0),
                child: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        )),
      ),
    );
  }

  Widget _paxBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, shape: BoxShape.circle),
        child: Icon(icon, color: AppTheme.primary),
      ),
    );
  }

  Widget _buildSearchInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required Function(String) onChanged,
  }) {
    return Row(children: [
      Icon(icon, size: 14, color: iconColor),
      const SizedBox(width: 12),
      Expanded(
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: (_) => _doSearch(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.outline.withValues(alpha: 0.6), fontSize: 14),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    ]);
  }

  Widget _inputChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: AppTheme.radiusMd),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 14, color: AppTheme.outline),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant)),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, shape: BoxShape.circle),
          child: const Icon(Icons.search_off, size: 32, color: AppTheme.outline),
        ),
        const SizedBox(height: 16),
        const Text('Không tìm thấy chuyến đi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 6),
        Text('Thử thay đổi điểm đi hoặc ngày khởi hành', style: TextStyle(color: AppTheme.outline, fontSize: 13)),
      ]),
    );
  }
}
