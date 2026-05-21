import 'dart:convert';

import 'package:http/http.dart' as http;

class LocationPoint {
  const LocationPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class LocationSearchService {
  static const _userAgent = 'smart-carpool-connect/1.0';
  static final Map<String, LocationPoint> _searchCache = {};

  static Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'zoom': '18',
      'addressdetails': '1',
    });

    final response = await http.get(
      uri,
      headers: const {'User-Agent': _userAgent, 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      return null;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final displayName = body['display_name'] as String?;
    if (displayName == null || displayName.trim().isEmpty) {
      return null;
    }
    return displayName;
  }

  static Future<LocationPoint?> searchCoordinates(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return null;
    }

    final cached = _searchCache[normalizedQuery];
    if (cached != null) {
      return cached;
    }

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'format': 'jsonv2',
      'q': query,
      'limit': '1',
      'countrycodes': 'vn',
    });

    final response = await http.get(
      uri,
      headers: const {'User-Agent': _userAgent, 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      return null;
    }

    final body = jsonDecode(response.body);
    if (body is! List || body.isEmpty) {
      return null;
    }

    final first = body.first;
    if (first is! Map<String, dynamic>) {
      return null;
    }

    final latitude = double.tryParse('${first['lat']}');
    final longitude = double.tryParse('${first['lon']}');
    if (latitude == null || longitude == null) {
      return null;
    }

    final result = LocationPoint(latitude: latitude, longitude: longitude);
    _searchCache[normalizedQuery] = result;
    return result;
  }
}
