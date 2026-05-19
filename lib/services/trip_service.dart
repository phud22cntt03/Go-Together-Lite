import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';

class TripService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'trips';

  static Stream<List<Trip>> watchAvailableTrips() {
    return _db
        .collection(_col)
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => Trip.fromMap(d.id, d.data())).toList(),
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
    var results = snap.docs.map((d) => Trip.fromMap(d.id, d.data())).toList();

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
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Trip.fromMap(d.id, d.data())).toList();
  }

  static Future<void> cancelTrip(String tripId) async {
    await _db.collection(_col).doc(tripId).update({'status': 'cancelled'});
  }
}
