import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking.dart';

class BookingService {
  static final _db = FirebaseFirestore.instance;
  static const _bookingsCol = 'bookings';
  static const _tripsCol = 'trips';
  static const _walletsCol = 'wallets';
  static const _walletTxCol = 'wallet_transactions';

  static Future<Booking> bookTrip({
    required String tripId,
    required String passengerId,
    required String passengerName,
    required String passengerAvatar,
    required int seatsBooked,
    required int pricePerSeat,
    String paymentMethod = 'cash',
  }) async {
    final tripRef = _db.collection(_tripsCol).doc(tripId);
    final bookingRef = _db.collection(_bookingsCol).doc();
    final tripSnap = await tripRef.get();

    if (!tripSnap.exists) {
      throw Exception('Chuyến đi không tồn tại');
    }

    final tripData = tripSnap.data() ?? {};
    final available = (tripData['availableSeats'] as num?)?.toInt() ?? 0;
    if (available < seatsBooked) {
      throw Exception('Không đủ ghế trống. Còn $available ghế');
    }

    final amount = seatsBooked * pricePerSeat;
    final driverId = tripData['driverId'] as String? ?? '';
    if (driverId.isNotEmpty && driverId == passengerId) {
      throw Exception('Bạn không thể đặt chuyến của chính mình');
    }

    final method = amount == 0 ? 'free' : paymentMethod;
    var paymentStatus = method == 'free' ? 'not_required' : 'pending_cash';
    final shouldPayByWallet = method == 'wallet' && amount > 0;
    final passengerWalletRef = _db.collection(_walletsCol).doc(passengerId);

    if (shouldPayByWallet) {
      final passengerWalletSnap = await passengerWalletRef.get();
      final balance = passengerWalletSnap.exists
          ? (passengerWalletSnap.data()?['balance'] as num?)?.toInt() ?? 0
          : 0;

      if (balance < amount) {
        throw Exception('Số dư ví không đủ để giữ chỗ');
      }
      paymentStatus = 'paid';
    }

    final booking = Booking(
      id: bookingRef.id,
      tripId: tripId,
      passengerId: passengerId,
      passengerName: passengerName,
      passengerAvatar: passengerAvatar,
      seatsBooked: seatsBooked,
      totalPrice: amount,
      status: 'confirmed',
      createdAt: DateTime.now(),
      paymentMethod: method,
      paymentStatus: paymentStatus,
    );

    final batch = _db.batch();
    if (shouldPayByWallet) {
      batch.update(passengerWalletRef, {
        'balance': FieldValue.increment(-amount),
        'totalSpent': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (driverId.isNotEmpty) {
        final driverWalletRef = _db.collection(_walletsCol).doc(driverId);
        batch.set(driverWalletRef, {
          'userId': driverId,
          'balance': FieldValue.increment(amount),
          'totalSpent': FieldValue.increment(0),
          'totalReceived': FieldValue.increment(amount),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      _addWalletTx(
        batch,
        userId: passengerId,
        type: 'trip_payment',
        amount: -amount,
        title: 'Giữ chỗ chuyến đi',
        bookingId: bookingRef.id,
        tripId: tripId,
      );

      if (driverId.isNotEmpty) {
        _addWalletTx(
          batch,
          userId: driverId,
          type: 'trip_income',
          amount: amount,
          title: 'Nhận tiền giữ chỗ',
          bookingId: bookingRef.id,
          tripId: tripId,
        );
      }
    }

    final bookingData = booking.toMap();
    bookingData['createdAt'] = FieldValue.serverTimestamp();
    batch.set(bookingRef, bookingData);

    final newAvailable = available - seatsBooked;
    batch.update(tripRef, {
      'availableSeats': newAvailable,
      'status': newAvailable == 0 ? 'full' : 'available',
    });

    await batch.commit();
    return booking;
  }

  static Future<void> cancelBooking({
    required String bookingId,
    required String tripId,
    required int seatsToRestore,
    required String reason,
  }) async {
    final bookingRef = _db.collection(_bookingsCol).doc(bookingId);
    final tripRef = _db.collection(_tripsCol).doc(tripId);
    final bookingSnap = await bookingRef.get();
    final tripSnap = await tripRef.get();
    final bookingData = bookingSnap.data();
    final passengerId = bookingData?['passengerId'] as String? ?? '';
    final paymentMethod = bookingData?['paymentMethod'] as String? ?? 'cash';
    final paymentStatus =
        bookingData?['paymentStatus'] as String? ?? 'pending_cash';
    final totalPrice = (bookingData?['totalPrice'] as num?)?.toInt() ?? 0;
    final driverId = tripSnap.data()?['driverId'] as String? ?? '';
    final shouldRefundWallet =
        paymentMethod == 'wallet' &&
        paymentStatus == 'paid' &&
        totalPrice > 0 &&
        passengerId.isNotEmpty;

    final batch = _db.batch();
    if (tripSnap.exists) {
      final currentAvailable =
          (tripSnap.data()?['availableSeats'] as num?)?.toInt() ?? 0;
      batch.update(tripRef, {
        'availableSeats': currentAvailable + seatsToRestore,
        'status': 'available',
      });
    }

    final updates = <String, dynamic>{
      'status': 'cancelled',
      'cancelReason': reason,
      'cancelledAt': FieldValue.serverTimestamp(),
    };

    if (shouldRefundWallet) {
      final passengerWalletRef = _db.collection(_walletsCol).doc(passengerId);
      batch.set(passengerWalletRef, {
        'userId': passengerId,
        'balance': FieldValue.increment(totalPrice),
        'totalSpent': FieldValue.increment(-totalPrice),
        'totalReceived': FieldValue.increment(0),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (driverId.isNotEmpty) {
        final driverWalletRef = _db.collection(_walletsCol).doc(driverId);
        batch.set(driverWalletRef, {
          'userId': driverId,
          'balance': FieldValue.increment(-totalPrice),
          'totalSpent': FieldValue.increment(0),
          'totalReceived': FieldValue.increment(-totalPrice),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      _addWalletTx(
        batch,
        userId: passengerId,
        type: 'refund',
        amount: totalPrice,
        title: 'Hoàn tiền hủy đặt chỗ',
        bookingId: bookingId,
        tripId: tripId,
      );
      updates['paymentStatus'] = 'refunded';
    }

    batch.update(bookingRef, updates);
    await batch.commit();
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

  static void _addWalletTx(
    WriteBatch batch, {
    required String userId,
    required String type,
    required int amount,
    required String title,
    required String bookingId,
    required String tripId,
  }) {
    final ref = _db.collection(_walletTxCol).doc();
    batch.set(ref, {
      'id': ref.id,
      'userId': userId,
      'type': type,
      'amount': amount,
      'title': title,
      'bookingId': bookingId,
      'tripId': tripId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
