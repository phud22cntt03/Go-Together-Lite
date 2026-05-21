import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_theme.dart';

class TripRouteMap extends StatelessWidget {
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final double height;

  const TripRouteMap({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (pickupLat == null ||
        pickupLng == null ||
        dropoffLat == null ||
        dropoffLng == null) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: AppTheme.radiusXxl,
          border: Border.all(
            color: AppTheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 40,
                color: AppTheme.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Chưa có dữ liệu bản đồ cho lộ trình này',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.outline.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pickup = LatLng(pickupLat!, pickupLng!);
    final dropoff = LatLng(dropoffLat!, dropoffLng!);
    final bounds = LatLngBounds.fromPoints([pickup, dropoff]);

    return ClipRRect(
      borderRadius: AppTheme.radiusXxl,
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCameraFit: CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(28),
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'smart_carpool_connect',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [pickup, dropoff],
                  strokeWidth: 4,
                  color: AppTheme.primary,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: pickup,
                  width: 44,
                  height: 44,
                  child: const _TripMapMarker(
                    icon: Icons.trip_origin,
                    color: AppTheme.primary,
                  ),
                ),
                Marker(
                  point: dropoff,
                  width: 44,
                  height: 44,
                  child: const _TripMapMarker(
                    icon: Icons.location_on,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TripMapMarker extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _TripMapMarker({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
