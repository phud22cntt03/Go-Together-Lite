import 'package:cloud_firestore/cloud_firestore.dart';

import 'trip.dart';

class Booking {
  final String id;
  final String tripId;
  final String passengerId;
  final String passengerName;
  final String passengerAvatar;
  final int seatsBooked;
  final int totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final DateTime createdAt;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final double? passengerRating;
  final double? driverRating;
  final String? ratingComment;
  final DateTime? ratedAt;
  final String paymentMethod; // free, cash, wallet
  final String paymentStatus; // not_required, pending_cash, paid, refunded

  Booking({
    required this.id,
    required this.tripId,
    required this.passengerId,
    required this.passengerName,
    this.passengerAvatar = '',
    this.seatsBooked = 1,
    required this.totalPrice,
    this.status = 'pending',
    required this.createdAt,
    this.cancelReason,
    this.cancelledAt,
    this.passengerRating,
    this.driverRating,
    this.ratingComment,
    this.ratedAt,
    this.paymentMethod = 'cash',
    this.paymentStatus = 'pending_cash',
  });

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get isPaid => paymentStatus == 'paid';
  bool get isRefunded => paymentStatus == 'refunded';

  String get paymentLabel {
    if (paymentMethod == 'free') return 'Miễn phí';
    if (paymentMethod == 'wallet') {
      return isRefunded ? 'Đã hoàn ví' : 'Đã trừ ví';
    }
    return 'Tiền mặt';
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'cancelled':
        return 'Đã hủy';
      case 'completed':
        return 'Hoàn thành';
      default:
        return status;
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'tripId': tripId,
    'passengerId': passengerId,
    'passengerName': passengerName,
    'passengerAvatar': passengerAvatar,
    'seatsBooked': seatsBooked,
    'totalPrice': totalPrice,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
    'cancelReason': cancelReason,
    'cancelledAt': cancelledAt != null
        ? Timestamp.fromDate(cancelledAt!)
        : null,
    'passengerRating': passengerRating,
    'driverRating': driverRating,
    'ratingComment': ratingComment,
    'ratedAt': ratedAt != null ? Timestamp.fromDate(ratedAt!) : null,
    'paymentMethod': paymentMethod,
    'paymentStatus': paymentStatus,
  };

  factory Booking.fromMap(String id, Map<String, dynamic> d) => Booking(
    id: id,
    tripId: d['tripId'] ?? '',
    passengerId: d['passengerId'] ?? '',
    passengerName: d['passengerName'] ?? '',
    passengerAvatar: d['passengerAvatar'] ?? '',
    seatsBooked: (d['seatsBooked'] as num?)?.toInt() ?? 1,
    totalPrice: (d['totalPrice'] as num?)?.toInt() ?? 0,
    status: d['status'] ?? 'pending',
    createdAt: _readDateTime(d['createdAt']) ?? DateTime.now(),
    cancelReason: d['cancelReason'],
    cancelledAt: _readDateTime(d['cancelledAt']),
    passengerRating: (d['passengerRating'] as num?)?.toDouble(),
    driverRating: (d['driverRating'] as num?)?.toDouble(),
    ratingComment: d['ratingComment'],
    ratedAt: _readDateTime(d['ratedAt']),
    paymentMethod: d['paymentMethod'] ?? 'cash',
    paymentStatus: d['paymentStatus'] ?? 'pending_cash',
  );

  Booking copyWith({
    String? status,
    String? cancelReason,
    DateTime? cancelledAt,
    double? passengerRating,
    double? driverRating,
    String? ratingComment,
    DateTime? ratedAt,
    String? paymentMethod,
    String? paymentStatus,
  }) {
    return Booking(
      id: id,
      tripId: tripId,
      passengerId: passengerId,
      passengerName: passengerName,
      passengerAvatar: passengerAvatar,
      seatsBooked: seatsBooked,
      totalPrice: totalPrice,
      status: status ?? this.status,
      createdAt: createdAt,
      cancelReason: cancelReason ?? this.cancelReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      passengerRating: passengerRating ?? this.passengerRating,
      driverRating: driverRating ?? this.driverRating,
      ratingComment: ratingComment ?? this.ratingComment,
      ratedAt: ratedAt ?? this.ratedAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

class MyTrip {
  final Trip trip;
  final Booking? booking; // null nếu là tài xế
  final bool isDriver;

  MyTrip({required this.trip, this.booking, this.isDriver = false});
}
