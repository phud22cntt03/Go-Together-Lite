import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class BookingService {
  static final _db = FirebaseFirestore.instance;
  static const _bookingsCol = 'bookings';
  static const _tripsCol = 'trips';

  static Future<Booking> bookTrip({
    required String tripId,
    required String passengerId,
    required String passengerName,
    required String passengerAvatar,
    required int seatsBooked,
    required int pricePerSeat,
  }) async {
    late Booking booking;

    await _db.runTransaction((tx) async {
      final tripRef = _db.collection(_tripsCol).doc(tripId);
      final tripSnap = await tx.get(tripRef);

      if (!tripSnap.exists) throw Exception('Chuyến đi không tồn tại');

      final available =
          (tripSnap.data()?['availableSeats'] as num?)?.toInt() ?? 0;
      if (available < seatsBooked) {
        throw Exception('Không đủ ghế trống (còn $available ghế)');
      }

      final bookingRef = _db.collection(_bookingsCol).doc();
      booking = Booking(
        id: bookingRef.id,
        tripId: tripId,
        passengerId: passengerId,
        passengerName: passengerName,
        passengerAvatar: passengerAvatar,
        seatsBooked: seatsBooked,
        totalPrice: seatsBooked * pricePerSeat,
        status: 'confirmed',
        createdAt: DateTime.now(),
      );

      final bookingData = booking.toMap();
      bookingData['createdAt'] = FieldValue.serverTimestamp();
      tx.set(bookingRef, bookingData);

      final newAvailable = available - seatsBooked;
      tx.update(tripRef, {
        'availableSeats': newAvailable,
        'status': newAvailable == 0 ? 'full' : 'available',
      });
    });

    return booking;
  }

  static Future<void> cancelBooking({
    required String bookingId,
    required String tripId,
    required int seatsToRestore,
    required String reason,
  }) async {
    await _db.runTransaction((tx) async {
      final bookingRef = _db.collection(_bookingsCol).doc(bookingId);
      final tripRef = _db.collection(_tripsCol).doc(tripId);

      final tripSnap = await tx.get(tripRef);
      if (tripSnap.exists) {
        final currentAvailable =
            (tripSnap.data()?['availableSeats'] as num?)?.toInt() ?? 0;
        tx.update(tripRef, {
          'availableSeats': currentAvailable + seatsToRestore,
          'status': 'available',
        });
      }

      tx.update(bookingRef, {
        'status': 'cancelled',
        'cancelReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Stream<List<Booking>> watchMyBookings(String passengerId) {
    return _db
        .collection(_bookingsCol)
        .where('passengerId', isEqualTo: passengerId)
        .snapshots()
        .map(
          (snap) => _sortBookings(
            snap.docs.map((d) => Booking.fromMap(d.id, d.data())).toList(),
          ),
        );
  }

  static Future<List<Booking>> getMyBookings(String passengerId) async {
    final snap = await _db
        .collection(_bookingsCol)
        .where('passengerId', isEqualTo: passengerId)
        .get();
    return _sortBookings(
      snap.docs.map((d) => Booking.fromMap(d.id, d.data())).toList(),
    );
  }

  static Future<List<Booking>> getBookingsForTrip(String tripId) async {
    final snap = await _db
        .collection(_bookingsCol)
        .where('tripId', isEqualTo: tripId)
        .get();
    return snap.docs.map((d) => Booking.fromMap(d.id, d.data())).toList();
  }

  static Future<void> rateTrip({
    required String bookingId,
    required double passengerRating,
    String? comment,
  }) async {
    await _db.collection(_bookingsCol).doc(bookingId).update({
      'passengerRating': passengerRating,
      'ratingComment': comment,
      'ratedAt': FieldValue.serverTimestamp(),
      'status': 'completed',
    });
  }

  static List<Booking> _sortBookings(List<Booking> bookings) {
    bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bookings;
  }
}
