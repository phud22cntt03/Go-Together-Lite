import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/trip.dart';
import '../services/location_search_service.dart';
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
  String _fromQuery = '';
  String _toQuery = '';
  DateTime? _searchDate;
  TimeOfDay? _searchTime;
  bool _searchUsesCurrentLocation = false;
  double? _currentLatitude;
  double? _currentLongitude;
  double _searchRadiusKm = 5;
  final Map<String, double> _distanceKmByTripId = {};

  List<Trip> get allTrips => _allTrips;
  List<Trip> get recentTrips => _allTrips.take(5).toList();
  List<Trip> get searchResults => _filteredResults;
  List<Trip> get myCreatedTrips => _myCreatedTrips;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sortBy => _sortBy;
  String get vehicleFilter => _vehicleFilter;
  int get minSeats => _minSeats;
  DateTime? get searchDate => _searchDate;
  TimeOfDay? get searchTime => _searchTime;
  bool get searchUsesCurrentLocation => _searchUsesCurrentLocation;
  double get searchRadiusKm => _searchRadiusKm;

  TripProvider() {
    _loadTrips();
  }

  void _loadTrips() {
    _isLoading = true;
    notifyListeners();

    _tripsSub = TripService.watchAvailableTrips().listen(
      (trips) {
        _allTrips = trips;
        _error = null;
        if (_fromQuery.isEmpty &&
            _toQuery.isEmpty &&
            !_searchUsesCurrentLocation) {
          _searchResults = List.from(trips);
          _isLoading = false;
          notifyListeners();
          return;
        }

        unawaited(_refreshSearchResults());
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
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Khong the tai chuyen da dang: $e';
      debugPrint('Load driver trips error: $e');
      notifyListeners();
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

  Future<bool> completeTrip(String tripId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await TripService.completeTrip(tripId);

      final driverTripIndex = _myCreatedTrips.indexWhere((t) => t.id == tripId);
      if (driverTripIndex != -1) {
        _myCreatedTrips[driverTripIndex] = _myCreatedTrips[driverTripIndex]
            .copyWith(status: 'completed');
      }

      _allTrips.removeWhere((trip) => trip.id == tripId);
      _searchResults.removeWhere((trip) => trip.id == tripId);
      return true;
    } catch (e) {
      _error = 'Khong the hoan thanh chuyen: $e';
      return false;
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
      case 'distance':
        results.sort((a, b) {
          final distanceA = _distanceKmByTripId[a.id] ?? double.infinity;
          final distanceB = _distanceKmByTripId[b.id] ?? double.infinity;
          return distanceA.compareTo(distanceB);
        });
        break;
      default:
        results.sort((a, b) {
          final createdA =
              a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final createdB =
              b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return createdB.compareTo(createdA);
        });
    }

    return results;
  }

  Future<void> search(
    String from,
    String to, {
    DateTime? date,
    TimeOfDay? time,
    bool useCurrentLocation = false,
    double? currentLatitude,
    double? currentLongitude,
    double? radiusKm,
  }) async {
    _fromQuery = from.trim();
    _toQuery = to.trim();
    _searchDate = date;
    _searchTime = time;
    _searchUsesCurrentLocation = useCurrentLocation;
    _currentLatitude = currentLatitude;
    _currentLongitude = currentLongitude;
    if (radiusKm != null) {
      _searchRadiusKm = radiusKm;
    }

    await _refreshSearchResults();
  }

  Future<void> refreshSearch() async {
    await _refreshSearchResults();
  }

  Future<void> _refreshSearchResults({bool notify = true}) async {
    _isLoading = true;
    _error = null;
    if (notify) {
      notifyListeners();
    }

    try {
      var results = List<Trip>.from(_allTrips);
      _distanceKmByTripId.clear();

      if (_fromQuery.isNotEmpty) {
        results = results
            .where(
              (t) => t.pickupLocation.toLowerCase().contains(
                _fromQuery.toLowerCase(),
              ),
            )
            .toList();
      }
      if (_toQuery.isNotEmpty) {
        results = results
            .where(
              (t) => t.dropoffLocation.toLowerCase().contains(
                _toQuery.toLowerCase(),
              ),
            )
            .toList();
      }

      if (_searchDate != null || _searchTime != null) {
        results = results.where(_matchesScheduledTime).toList();
      }

      if (_searchUsesCurrentLocation &&
          _currentLatitude != null &&
          _currentLongitude != null) {
        final nearbyTrips = <Trip>[];
        for (final trip in results) {
          final pickupPoint = await _resolvePickupPoint(trip);
          if (pickupPoint == null) {
            continue;
          }

          final distanceMeters = Geolocator.distanceBetween(
            _currentLatitude!,
            _currentLongitude!,
            pickupPoint.latitude,
            pickupPoint.longitude,
          );
          final distanceKm = distanceMeters / 1000;

          if (distanceKm <= _searchRadiusKm) {
            nearbyTrips.add(trip);
            _distanceKmByTripId[trip.id] = distanceKm;
          }
        }
        results = nearbyTrips;
      }

      _searchResults = results;
      _isLoading = false;
      if (notify) {
        notifyListeners();
      }
    } catch (e) {
      _error = 'Loi tim kiem: $e';
      _isLoading = false;
      if (notify) {
        notifyListeners();
      }
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

  void setSearchRadiusKm(double radiusKm) {
    _searchRadiusKm = radiusKm;
    notifyListeners();
  }

  Future<void> clearLocationSearch() async {
    _searchUsesCurrentLocation = false;
    _currentLatitude = null;
    _currentLongitude = null;
    _distanceKmByTripId.clear();
    await _refreshSearchResults();
  }

  void resetFilters() {
    _sortBy = 'newest';
    _vehicleFilter = 'all';
    _minSeats = 1;
    _fromQuery = '';
    _toQuery = '';
    _searchDate = null;
    _searchTime = null;
    _searchUsesCurrentLocation = false;
    _currentLatitude = null;
    _currentLongitude = null;
    _searchRadiusKm = 5;
    _distanceKmByTripId.clear();
    _searchResults = List.from(_allTrips);
    notifyListeners();
  }

  double? distanceForTrip(String tripId) => _distanceKmByTripId[tripId];

  Trip? getTripById(String id) {
    try {
      return _allTrips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<LocationPoint?> _resolvePickupPoint(Trip trip) async {
    if (trip.pickupLat != null && trip.pickupLng != null) {
      return LocationPoint(
        latitude: trip.pickupLat!,
        longitude: trip.pickupLng!,
      );
    }
    return LocationSearchService.searchCoordinates(trip.pickupLocation);
  }

  bool _matchesScheduledTime(Trip trip) {
    final scheduled = _parseTripDateTime(trip.pickupTime);

    if (_searchDate != null) {
      if (scheduled != null) {
        final sameDay =
            scheduled.day == _searchDate!.day &&
            scheduled.month == _searchDate!.month &&
            scheduled.year == _searchDate!.year;
        if (!sameDay) {
          return false;
        }
      } else {
        return false;
      }
    }

    if (_searchTime != null) {
      final tripMinutes = scheduled != null
          ? scheduled.hour * 60 + scheduled.minute
          : _parseTimeOnlyInMinutes(trip.pickupTime);
      if (tripMinutes == null) {
        return false;
      }

      final selectedMinutes = _searchTime!.hour * 60 + _searchTime!.minute;
      if (tripMinutes < selectedMinutes) {
        return false;
      }
    }

    return true;
  }

  DateTime? _parseTripDateTime(String raw) {
    final fullMatch = RegExp(
      r'(\d{1,2}):(\d{2})(?:\s*(AM|PM))?\s*-\s*(\d{1,2})/(\d{1,2})',
      caseSensitive: false,
    ).firstMatch(raw);

    if (fullMatch != null) {
      final hour = int.tryParse(fullMatch.group(1) ?? '');
      final minute = int.tryParse(fullMatch.group(2) ?? '');
      final period = fullMatch.group(3)?.toUpperCase();
      final day = int.tryParse(fullMatch.group(4) ?? '');
      final month = int.tryParse(fullMatch.group(5) ?? '');
      if (hour == null || minute == null || day == null || month == null) {
        return null;
      }

      final normalizedHour = _normalizeHour(hour, period);
      final referenceYear = _searchDate?.year ?? DateTime.now().year;
      return DateTime(referenceYear, month, day, normalizedHour, minute);
    }

    return null;
  }

  int? _parseTimeOnlyInMinutes(String raw) {
    final match = RegExp(
      r'(\d{1,2}):(\d{2})(?:\s*(AM|PM))?',
      caseSensitive: false,
    ).firstMatch(raw);
    if (match == null) {
      return null;
    }

    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    final period = match.group(3)?.toUpperCase();
    if (hour == null || minute == null) {
      return null;
    }

    final normalizedHour = _normalizeHour(hour, period);
    return normalizedHour * 60 + minute;
  }

  int _normalizeHour(int hour, String? period) {
    if (period == null) {
      return hour;
    }
    if (period == 'AM') {
      return hour == 12 ? 0 : hour;
    }
    return hour == 12 ? 12 : hour + 12;
  }

  @override
  void dispose() {
    _tripsSub?.cancel();
    super.dispose();
  }
}
