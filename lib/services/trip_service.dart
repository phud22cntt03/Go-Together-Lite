import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';

class TripService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'trips';

  static Stream<List<Trip>> watchAvailableTrips() {
    return _db
        .collection(_col)
        .where('status', isEqualTo: 'available')
        .limit(100)
        .snapshots()
        .map(
          (snap) => _sortTrips(
            snap.docs
                .map((d) => Trip.fromMap(d.id, d.data()))
                .where(_shouldShowInActiveLists)
                .toList(),
          ),
        );
  }

  static Future<Trip?> getTripById(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    if (!doc.exists) return null;
    return Trip.fromMap(doc.id, doc.data()!);
  }

  static Future<List<Trip>> searchTrips({
    String? fromQuery,
    String? toQuery,
    String vehicleType = 'all',
    int minSeats = 1,
    String sortBy = 'newest',
  }) async {
    Query<Map<String, dynamic>> query = _db
        .collection(_col)
        .where('status', isEqualTo: 'available')
        .where('availableSeats', isGreaterThanOrEqualTo: minSeats);

    if (vehicleType != 'all') {
      query = query.where('vehicleType', isEqualTo: vehicleType);
    }

    switch (sortBy) {
      case 'price_asc':
        query = query.orderBy('availableSeats').orderBy('pricePerSeat');
        break;
      case 'price_desc':
        query = query
            .orderBy('availableSeats')
            .orderBy('pricePerSeat', descending: true);
        break;
      case 'rating':
        query = query
            .orderBy('availableSeats')
            .orderBy('driverRating', descending: true);
        break;
      default:
        query = query
            .orderBy('availableSeats')
            .orderBy('createdAt', descending: true);
    }

    final snap = await query.limit(50).get();
    var results = snap.docs
        .map((d) => Trip.fromMap(d.id, d.data()))
        .where(_shouldShowInActiveLists)
        .toList();

    if (fromQuery != null && fromQuery.isNotEmpty) {
      results = results
          .where(
            (t) => t.pickupLocation.toLowerCase().contains(
              fromQuery.toLowerCase(),
            ),
          )
          .toList();
    }
    if (toQuery != null && toQuery.isNotEmpty) {
      results = results
          .where(
            (t) =>
                t.dropoffLocation.toLowerCase().contains(toQuery.toLowerCase()),
          )
          .toList();
    }

    return results;
  }

  static Future<Trip> createTrip(Trip trip, String driverId) async {
    final ref = _db.collection(_col).doc();
    final data = trip.toMap();
    data['id'] = ref.id;
    data['driverId'] = driverId;
    data['createdAt'] = FieldValue.serverTimestamp();
    data['totalSeats'] = trip.totalSeats;
    data['availableSeats'] = trip.availableSeats;
    await ref.set(data);

    return trip.copyWith(
      id: ref.id,
      driverId: driverId,
      totalSeats: trip.totalSeats,
      availableSeats: trip.availableSeats,
      createdAt: DateTime.now(),
    );
  }

  static Future<List<Trip>> getDriverTrips(String driverId) async {
    final snap = await _db
        .collection(_col)
        .where('driverId', isEqualTo: driverId)
        .get();
    return _sortTrips(
      snap.docs
          .map((d) => Trip.fromMap(d.id, d.data()))
          .where(_shouldShowInDriverLists)
          .toList(),
    );
  }

  static Future<void> cancelTrip(String tripId) async {
    await _db.collection(_col).doc(tripId).update({'status': 'cancelled'});
  }

  static Future<void> completeTrip(String tripId) async {
    final tripRef = _db.collection(_col).doc(tripId);
    final bookingsSnap = await _db
        .collection('bookings')
        .where('tripId', isEqualTo: tripId)
        .get();

    final batch = _db.batch();
    batch.update(tripRef, {'status': 'completed'});

    for (final bookingDoc in bookingsSnap.docs) {
      final status = bookingDoc.data()['status'] as String? ?? '';
      if (status == 'cancelled' || status == 'completed') {
        continue;
      }
      batch.update(bookingDoc.reference, {'status': 'completed'});
    }

    await batch.commit();
  }

  static List<Trip> _sortTrips(List<Trip> trips) {
    trips.sort((a, b) {
      final createdCompare =
          (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
            a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
          );
      if (createdCompare != 0) {
        return createdCompare;
      }

      return a.pickupTime.compareTo(b.pickupTime);
    });
    return trips;
  }

  static bool _shouldShowInActiveLists(Trip trip) {
    if (trip.status == 'completed' || trip.status == 'cancelled') {
      return false;
    }

    final cutoff = DateTime.now().subtract(const Duration(days: 1));
    final scheduledAt = _parseTripSchedule(trip.pickupTime);

    if (scheduledAt != null) {
      return !scheduledAt.isBefore(cutoff);
    }

    if (trip.createdAt != null) {
      return !trip.createdAt!.isBefore(cutoff);
    }

    return true;
  }

  static bool _shouldShowInDriverLists(Trip trip) {
    return _shouldShowInActiveLists(trip);
  }

  static DateTime? _parseTripSchedule(String raw) {
    final match = RegExp(
      r'(\d{1,2}):(\d{2})(?:\s*(AM|PM))?\s*-\s*(\d{1,2})/(\d{1,2})',
      caseSensitive: false,
    ).firstMatch(raw);

    if (match == null) {
      return null;
    }

    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    final period = match.group(3)?.toUpperCase();
    final day = int.tryParse(match.group(4) ?? '');
    final month = int.tryParse(match.group(5) ?? '');
    if (hour == null || minute == null || day == null || month == null) {
      return null;
    }

    final normalizedHour = _normalizeHour(hour, period);
    final now = DateTime.now();
    return DateTime(now.year, month, day, normalizedHour, minute);
  }

  static int _normalizeHour(int hour, String? period) {
    if (period == null) {
      return hour;
    }
    if (period == 'AM') {
      return hour == 12 ? 0 : hour;
    }
    return hour == 12 ? 12 : hour + 12;
  }
}
