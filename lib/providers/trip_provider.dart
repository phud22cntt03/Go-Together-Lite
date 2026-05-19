import 'dart:async';
import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../models/booking.dart';
import '../services/trip_service.dart';
import '../services/booking_service.dart';

class TripProvider extends ChangeNotifier {
  List<Trip> _allTrips = [];
  List<Trip> _searchResults = [];
  List<Booking> _myBookings = [];
  List<Trip> _myCreatedTrips = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _tripsSub;
  StreamSubscription? _bookingsSub;

  // Filter state
  String _sortBy = 'newest';
  String _vehicleFilter = 'all';
  int _minSeats = 1;

  List<Trip> get allTrips => _allTrips;
  List<Trip> get searchResults => _filteredResults;
  List<Booking> get myBookings => _myBookings;
  List<Trip> get myCreatedTrips => _myCreatedTrips;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sortBy => _sortBy;
  String get vehicleFilter => _vehicleFilter;
  int get minSeats => _minSeats;

  TripProvider() {
    _loadTrips();
  }

  // ─── Khởi tạo: stream real-time từ Firestore ──────────────────
  void _loadTrips() {
    _isLoading = true;
    notifyListeners();

    _tripsSub = TripService.watchAvailableTrips().listen(
      (trips) {
        _allTrips = trips;
        _searchResults = List.from(trips);
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Không thể tải chuyến đi: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ─── Theo dõi bookings real-time cho user ──────────────────────
  void watchBookings(String userId) {
    _bookingsSub?.cancel();
    _bookingsSub = BookingService.watchMyBookings(userId).listen(
      (bookings) {
        _myBookings = bookings;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Booking stream error: $e');
      },
    );
  }

  // ─── Load chuyến đi do tài xế tạo ─────────────────────────────
  Future<void> loadDriverTrips(String driverId) async {
    try {
      _myCreatedTrips = await TripService.getDriverTrips(driverId);
      notifyListeners();
    } catch (e) {
      debugPrint('Load driver trips error: $e');
    }
  }

  // ─── Filtered results (client-side) ────────────────────────────
  List<Trip> get _filteredResults {
    var results = List<Trip>.from(_searchResults);

    if (_vehicleFilter != 'all') {
      results = results.where((t) => t.vehicleType == _vehicleFilter).toList();
    }

    results = results.where((t) => t.availableSeats >= _minSeats).toList();

    switch (_sortBy) {
      case 'price_asc':
        results.sort((a, b) => a.pricePerSeat.compareTo(b.pricePerSeat));
        break;
      case 'price_desc':
        results.sort((a, b) => b.pricePerSeat.compareTo(a.pricePerSeat));
        break;
      case 'rating':
        results.sort((a, b) => b.driverRating.compareTo(a.driverRating));
        break;
    }

    return results;
  }

  // ─── Tìm kiếm (Firestore query) ───────────────────────────────
  Future<void> search(String from, String to) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await TripService.searchTrips(
        fromQuery: from.isNotEmpty ? from : null,
        toQuery: to.isNotEmpty ? to : null,
        vehicleType: _vehicleFilter,
        minSeats: _minSeats,
        sortBy: _sortBy,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi tìm kiếm: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Filter setters ────────────────────────────────────────────
  void setSort(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void setVehicleFilter(String type) {
    _vehicleFilter = type;
    notifyListeners();
  }

  void setMinSeats(int seats) {
    _minSeats = seats;
    notifyListeners();
  }

  void resetFilters() {
    _sortBy = 'newest';
    _vehicleFilter = 'all';
    _minSeats = 1;
    _searchResults = List.from(_allTrips);
    notifyListeners();
  }

  // ─── Booking: đặt chỗ qua Firestore Transaction ──────────────
  Future<Booking?> bookTrip({
    required String tripId,
    required String passengerId,
    required String passengerName,
    required int seats,
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
        passengerAvatar: '',
        seatsBooked: seats,
        pricePerSeat: pricePerSeat,
      );
      _myBookings.insert(0, booking);
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ─── Hủy booking ──────────────────────────────────────────────
  Future<void> cancelBooking(String bookingId, String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      final idx = _myBookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        final booking = _myBookings[idx];
        await BookingService.cancelBooking(
          bookingId: bookingId,
          tripId: booking.tripId,
          seatsToRestore: booking.seatsBooked,
          reason: reason,
        );
        _myBookings[idx] = booking.copyWith(
          status: 'cancelled',
          cancelReason: reason,
        );
      }
    } catch (e) {
      _error = 'Không thể hủy: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Tạo chuyến mới ──────────────────────────────────────────
  Future<Trip?> createTrip(Trip trip, String driverId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final created = await TripService.createTrip(trip, driverId);
      _myCreatedTrips.insert(0, created);
      _isLoading = false;
      notifyListeners();
      return created;
    } catch (e) {
      _error = 'Không thể tạo chuyến: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────
  Trip? getTripById(String id) {
    try {
      return _allTrips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Booking? getBookingByTripId(String tripId) {
    try {
      return _myBookings.firstWhere((b) => b.tripId == tripId);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _tripsSub?.cancel();
    _bookingsSub?.cancel();
    super.dispose();
  }
}
