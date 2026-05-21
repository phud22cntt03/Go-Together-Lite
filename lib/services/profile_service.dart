import '../models/trip.dart';
import 'booking_service.dart';
import 'trip_service.dart';

class ProfileCompanion {
  final String name;
  final String subtitle;
  final int count;

  const ProfileCompanion({
    required this.name,
    required this.subtitle,
    required this.count,
  });
}

class ProfileOverview {
  final List<Trip> historyTrips;
  final List<ProfileCompanion> companions;
  final int totalBookedTrips;
  final int totalCompletedTrips;
  final int totalAmountBooked;

  const ProfileOverview({
    required this.historyTrips,
    required this.companions,
    required this.totalBookedTrips,
    required this.totalCompletedTrips,
    required this.totalAmountBooked,
  });
}

class ProfileService {
  static Future<ProfileOverview> loadOverview({
    required String userId,
    required String currentUserName,
  }) async {
    final bookingsFuture = BookingService.getMyBookings(userId);
    final driverTripsFuture = TripService.getDriverTrips(userId);

    final bookings = await bookingsFuture;
    final driverTrips = await driverTripsFuture;

    final historyEntries = <_HistoryEntry>[];
    final companionCounts = <String, int>{};

    for (final booking in bookings) {
      final trip = await TripService.getTripById(booking.tripId);
      if (trip == null) {
        continue;
      }

      final tripForHistory = trip.copyWith(
        status: booking.status,
        createdAt: booking.createdAt,
      );
      historyEntries.add(
        _HistoryEntry(trip: tripForHistory, sortTime: booking.createdAt),
      );

      _increaseCompanionCount(companionCounts, trip.driverName);
    }

    for (final trip in driverTrips) {
      historyEntries.add(
        _HistoryEntry(
          trip: trip,
          sortTime: trip.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );

      final tripBookings = await BookingService.getBookingsForTrip(trip.id);
      for (final booking in tripBookings) {
        if (booking.passengerName.trim().isEmpty) {
          continue;
        }
        if (booking.passengerName.trim().toLowerCase() ==
            currentUserName.trim().toLowerCase()) {
          continue;
        }
        _increaseCompanionCount(companionCounts, booking.passengerName);
      }
    }

    historyEntries.sort((a, b) => b.sortTime.compareTo(a.sortTime));

    final companions = companionCounts.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) {
          return countCompare;
        }
        return a.key.toLowerCase().compareTo(b.key.toLowerCase());
      });

    final topCompanions = companions.take(5).map((entry) {
      final count = entry.value;
      final subtitle = count == 1
          ? 'Đã đi cùng 1 chuyến'
          : 'Đã đi cùng $count chuyến';
      return ProfileCompanion(
        name: entry.key,
        subtitle: subtitle,
        count: count,
      );
    }).toList();

    final totalCompletedTrips = historyEntries
        .where((entry) => entry.trip.status == 'completed')
        .length;
    final totalBookedTrips = bookings.where((booking) => !booking.isCancelled).length;
    final totalAmountBooked = bookings.fold<int>(
      0,
      (sum, booking) => sum + booking.totalPrice,
    );

    return ProfileOverview(
      historyTrips: historyEntries.map((entry) => entry.trip).toList(),
      companions: topCompanions,
      totalBookedTrips: totalBookedTrips,
      totalCompletedTrips: totalCompletedTrips,
      totalAmountBooked: totalAmountBooked,
    );
  }

  static void _increaseCompanionCount(Map<String, int> counts, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    counts.update(trimmed, (value) => value + 1, ifAbsent: () => 1);
  }
}

class _HistoryEntry {
  final Trip trip;
  final DateTime sortTime;

  const _HistoryEntry({required this.trip, required this.sortTime});
}
