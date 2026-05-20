import 'dart:async';
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
        _error = 'Khong the tai booking: $e';
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
      );
      _myBookings.insert(0, booking);
      return booking;
    } catch (e) {
      _error = e.toString();
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
        );
      }
    } catch (e) {
      _error = 'Khong the huy booking: $e';
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
    } catch (e) {
      _error = 'Khong the danh gia: $e';
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
}
