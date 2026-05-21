import 'dart:convert';

import 'package:http/http.dart' as http;

class LocationSearchService {
  static const _userAgent = 'smart-carpool-connect/1.0';

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
}
