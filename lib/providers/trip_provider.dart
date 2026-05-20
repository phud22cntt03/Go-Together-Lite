import 'dart:async';
import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';

class TripProvider extends ChangeNotifier {
  List<Trip> _allTrips = [];
  List<Trip> _searchResults = [];
  List<Trip> _myCreatedTrips = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _tripsSub;

  String _sortBy = 'newest';
  String _vehicleFilter = 'all';
  int _minSeats = 1;

  List<Trip> get allTrips => _allTrips;
  List<Trip> get searchResults => _filteredResults;
  List<Trip> get myCreatedTrips => _myCreatedTrips;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sortBy => _sortBy;
  String get vehicleFilter => _vehicleFilter;
  int get minSeats => _minSeats;

  TripProvider() {
    _loadTrips();
  }

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
        _error = 'Khong the tai chuyen di: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> loadDriverTrips(String driverId) async {
    try {
      _myCreatedTrips = await TripService.getDriverTrips(driverId);
      notifyListeners();
    } catch (e) {
      debugPrint('Load driver trips error: $e');
    }
  }

  Future<Trip?> createTrip(Trip trip, String driverId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final created = await TripService.createTrip(trip, driverId);
      _myCreatedTrips.insert(0, created);
      return created;
    } catch (e) {
      _error = 'Khong the tao chuyen: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
      _error = 'Loi tim kiem: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Trip? getTripById(String id) {
    try {
      return _allTrips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _tripsSub?.cancel();
    super.dispose();
  }
}
