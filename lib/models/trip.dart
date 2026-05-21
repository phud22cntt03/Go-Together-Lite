import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String driverId;
  final String driverName;
  final String driverAvatar;
  final double driverRating;
  final String vehicleName;
  final String licensePlate;
  final String pickupLocation;
  final String dropoffLocation;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final String pickupTime;
  final String dropoffTime;
  final int pricePerSeat;
  final int totalSeats;
  final int availableSeats;
  final String vehicleType; // 'car' or 'motorbike'
  final String? driverNote;
  final String status; // 'available', 'full', 'completed', 'cancelled'
  final DateTime? createdAt;

  Trip({
    required this.id,
    this.driverId = '',
    required this.driverName,
    this.driverAvatar = '',
    required this.driverRating,
    required this.vehicleName,
    required this.licensePlate,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    required this.pickupTime,
    this.dropoffTime = '',
    required this.pricePerSeat,
    this.totalSeats = 4,
    this.availableSeats = 3,
    this.vehicleType = 'car',
    this.driverNote,
    this.status = 'available',
    this.createdAt,
  });

  bool get isAvailable => status == 'available';
  bool get isFull => status == 'full';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  Map<String, dynamic> toMap() => {
    'id': id,
    'driverId': driverId,
    'driverName': driverName,
    'driverAvatar': driverAvatar,
    'driverRating': driverRating,
    'vehicleName': vehicleName,
    'licensePlate': licensePlate,
    'vehicleType': vehicleType,
    'pickupLocation': pickupLocation,
    'dropoffLocation': dropoffLocation,
    'pickupLat': pickupLat,
    'pickupLng': pickupLng,
    'dropoffLat': dropoffLat,
    'dropoffLng': dropoffLng,
    'pickupTime': pickupTime,
    'dropoffTime': dropoffTime,
    'pricePerSeat': pricePerSeat,
    'totalSeats': totalSeats,
    'availableSeats': availableSeats,
    'driverNote': driverNote,
    'status': status,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };

  factory Trip.fromMap(String id, Map<String, dynamic> d) => Trip(
    id: id,
    driverId: d['driverId'] ?? '',
    driverName: d['driverName'] ?? '',
    driverAvatar: d['driverAvatar'] ?? '',
    driverRating: (d['driverRating'] as num?)?.toDouble() ?? 5.0,
    vehicleName: d['vehicleName'] ?? '',
    licensePlate: d['licensePlate'] ?? '',
    pickupLocation: d['pickupLocation'] ?? '',
    dropoffLocation: d['dropoffLocation'] ?? '',
    pickupLat: _readDouble(d['pickupLat']),
    pickupLng: _readDouble(d['pickupLng']),
    dropoffLat: _readDouble(d['dropoffLat']),
    dropoffLng: _readDouble(d['dropoffLng']),
    pickupTime: d['pickupTime'] ?? '',
    dropoffTime: d['dropoffTime'] ?? '',
    pricePerSeat: (d['pricePerSeat'] as num?)?.toInt() ?? 0,
    totalSeats: (d['totalSeats'] as num?)?.toInt() ?? 4,
    availableSeats: (d['availableSeats'] as num?)?.toInt() ?? 0,
    vehicleType: d['vehicleType'] ?? 'car',
    driverNote: d['driverNote'],
    status: d['status'] ?? 'available',
    createdAt: _readDateTime(d['createdAt']),
  );

  Trip copyWith({
    String? id,
    String? driverId,
    String? driverName,
    String? driverAvatar,
    double? driverRating,
    String? vehicleName,
    String? licensePlate,
    String? pickupLocation,
    String? dropoffLocation,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    String? pickupTime,
    String? dropoffTime,
    int? pricePerSeat,
    int? totalSeats,
    int? availableSeats,
    String? vehicleType,
    String? driverNote,
    String? status,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverAvatar: driverAvatar ?? this.driverAvatar,
      driverRating: driverRating ?? this.driverRating,
      vehicleName: vehicleName ?? this.vehicleName,
      licensePlate: licensePlate ?? this.licensePlate,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      pickupTime: pickupTime ?? this.pickupTime,
      dropoffTime: dropoffTime ?? this.dropoffTime,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      vehicleType: vehicleType ?? this.vehicleType,
      driverNote: driverNote ?? this.driverNote,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static double? _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return null;
  }
}
