import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  List<Booking> _myBookings = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _bookingsSub;

  List<Booking> get myBookings => _myBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void watchMyBookings(String userId) {
    _bookingsSub?.cancel();
    _bookingsSub = BookingService.watchMyBookings(userId).listen(
      (bookings) {
        _myBookings = bookings;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Không thể tải booking: $e';
        notifyListeners();
      },
    );
  }

  Future<Booking?> bookTrip({
    required String tripId,
    required String passengerId,
    required String passengerName,
    required String passengerAvatar,
    required int seatsBooked,
    required int pricePerSeat,
    String paymentMethod = 'cash',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final booking = await BookingService.bookTrip(
        tripId: tripId,
        passengerId: passengerId,
        passengerName: passengerName,
        passengerAvatar: passengerAvatar,
        seatsBooked: seatsBooked,
        pricePerSeat: pricePerSeat,
        paymentMethod: paymentMethod,
      );
      _myBookings.insert(0, booking);
      return booking;
    } on FirebaseException catch (e) {
      _error = _mapFirebaseError(e);
      return null;
    } catch (e) {
      _error = _cleanError(e);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking({
    required String bookingId,
    required String tripId,
    required int seatsToRestore,
    required String reason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await BookingService.cancelBooking(
        bookingId: bookingId,
        tripId: tripId,
        seatsToRestore: seatsToRestore,
        reason: reason,
      );
      final idx = _myBookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        _myBookings[idx] = _myBookings[idx].copyWith(
          status: 'cancelled',
          cancelReason: reason,
          paymentStatus: _myBookings[idx].paymentMethod == 'wallet'
              ? 'refunded'
              : _myBookings[idx].paymentStatus,
        );
      }
    } on FirebaseException catch (e) {
      _error = _mapFirebaseError(e);
    } catch (e) {
      _error = 'Không thể hủy booking: ${_cleanError(e)}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rateTrip({
    required String bookingId,
    required double passengerRating,
    String? comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await BookingService.rateTrip(
        bookingId: bookingId,
        passengerRating: passengerRating,
        comment: comment,
      );
      final idx = _myBookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        _myBookings[idx] = _myBookings[idx].copyWith(
          passengerRating: passengerRating,
          ratingComment: comment,
          status: 'completed',
        );
      }
    } on FirebaseException catch (e) {
      _error = _mapFirebaseError(e);
    } catch (e) {
      _error = 'Không thể đánh giá: ${_cleanError(e)}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Booking>> getBookingsForTrip(String tripId) {
    return BookingService.getBookingsForTrip(tripId);
  }

  @override
  void dispose() {
    _bookingsSub?.cancel();
    super.dispose();
  }

  String _mapFirebaseError(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return 'Firebase chưa cho phép ghi booking/ví. Hãy deploy firestore.rules rồi thử lại.';
    }
    if (e.code == 'not-found') {
      return 'Không tìm thấy dữ liệu cần cập nhật. Hãy nạp ví hoặc chọn chuyến khác rồi thử lại.';
    }
    return e.message ?? 'Lỗi Firebase (${e.code})';
  }

  String _cleanError(Object e) {
    final message = e.toString().replaceAll('Exception: ', '');
    if (message.contains('converted Future')) {
      return 'Không thể đặt chỗ. Kiểm tra số dư ví, Firestore rules hoặc dữ liệu chuyến đi.';
    }
    return message;
  }
}
