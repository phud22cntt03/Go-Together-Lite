import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final double rating;
  final int totalTrips;
  final int totalKm;
  final String role; // 'passenger', 'driver', 'both'
  final bool isVerified;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.rating = 5.0,
    this.totalTrips = 0,
    this.totalKm = 0,
    this.role = 'both',
    this.isVerified = false,
    this.createdAt,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'avatarUrl': avatarUrl,
    'rating': rating,
    'totalTrips': totalTrips,
    'totalKm': totalKm,
    'role': role,
    'isVerified': isVerified,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };

  factory AppUser.fromMap(String id, Map<String, dynamic> d) => AppUser(
    id: id,
    fullName: d['fullName'] ?? '',
    email: d['email'] ?? '',
    phone: d['phone'] ?? '',
    avatarUrl: d['avatarUrl'],
    rating: (d['rating'] as num?)?.toDouble() ?? 5.0,
    totalTrips: (d['totalTrips'] as num?)?.toInt() ?? 0,
    totalKm: (d['totalKm'] as num?)?.toInt() ?? 0,
    role: d['role'] ?? 'both',
    isVerified: d['isVerified'] ?? false,
    createdAt: _readDateTime(d['createdAt']),
  );

  AppUser copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    double? rating,
    int? totalTrips,
    int? totalKm,
    String? role,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      totalKm: totalKm ?? this.totalKm,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
