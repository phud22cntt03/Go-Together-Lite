import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_search_service.dart';
import '../theme/app_theme.dart';

class PickedLocation {
  final String label;
  final double latitude;
  final double longitude;

  const PickedLocation({
    required this.label,
    required this.latitude,
    required this.longitude,
  });
}

class LocationPickerScreen extends StatefulWidget {
  final String title;
  final PickedLocation? initialLocation;

  const LocationPickerScreen({
    super.key,
    required this.title,
    this.initialLocation,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _defaultCenter = LatLng(10.7769, 106.7009);

  late final MapController _mapController;
  PickedLocation? _selectedLocation;
  bool _loadingAddress = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter = _selectedLocation != null
        ? LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude)
        : _defaultCenter;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: _selectedLocation == null ? 13 : 16,
              onTap: (_, point) => _handleMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'smart_carpool_connect',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _selectedLocation!.latitude,
                        _selectedLocation!.longitude,
                      ),
                      width: 56,
                      height: 56,
                      child: const _SelectedMarker(),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppTheme.radiusXxl,
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chạm lên bản đồ để chọn vị trí',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  if (_selectedLocation == null)
                    const Text(
                      'Chưa chọn điểm nào',
                      style: TextStyle(color: AppTheme.outline),
                    )
                  else ...[
                    Text(
                      _selectedLocation!.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_selectedLocation!.latitude.toStringAsFixed(5)}, ${_selectedLocation!.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.outline,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedLocation == null || _loadingAddress
                          ? null
                          : () => Navigator.pop(context, _selectedLocation),
                      child: _loadingAddress
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Xác nhận vị trí'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMapTap(LatLng point) async {
    setState(() {
      _loadingAddress = true;
      _selectedLocation = PickedLocation(
        label:
            'Vị trí ${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
        latitude: point.latitude,
        longitude: point.longitude,
      );
    });

    try {
      final resolvedLabel = await LocationSearchService.reverseGeocode(
        latitude: point.latitude,
        longitude: point.longitude,
      );

      if (!mounted) return;
      setState(() {
        _selectedLocation = PickedLocation(
          label: resolvedLabel ?? _selectedLocation!.label,
          latitude: point.latitude,
          longitude: point.longitude,
        );
      });
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() => _loadingAddress = false);
      }
    }
  }
}

class _SelectedMarker extends StatelessWidget {
  const _SelectedMarker();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.location_on, color: Colors.white, size: 24),
      ),
    );
  }
}
