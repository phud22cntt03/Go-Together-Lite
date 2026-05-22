import 'package:cloud_firestore/cloud_firestore.dart';

class UserWallet {
  const UserWallet({
    required this.userId,
    this.balance = 0,
    this.totalSpent = 0,
    this.totalReceived = 0,
    this.updatedAt,
  });

  final String userId;
  final int balance;
  final int totalSpent;
  final int totalReceived;
  final DateTime? updatedAt;

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'balance': balance,
    'totalSpent': totalSpent,
    'totalReceived': totalReceived,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory UserWallet.fromMap(Map<String, dynamic> data) => UserWallet(
    userId: data['userId'] ?? '',
    balance: (data['balance'] as num?)?.toInt() ?? 0,
    totalSpent: (data['totalSpent'] as num?)?.toInt() ?? 0,
    totalReceived: (data['totalReceived'] as num?)?.toInt() ?? 0,
    updatedAt: _readDateTime(data['updatedAt']),
  );

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.title,
    required this.createdAt,
    this.bookingId,
    this.tripId,
  });

  final String id;
  final String userId;
  final String type; // topup, trip_payment, trip_income, refund
  final int amount;
  final String title;
  final DateTime createdAt;
  final String? bookingId;
  final String? tripId;

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'type': type,
    'amount': amount,
    'title': title,
    'bookingId': bookingId,
    'tripId': tripId,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory WalletTransaction.fromMap(String id, Map<String, dynamic> data) {
    return WalletTransaction(
      id: id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'topup',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      title: data['title'] ?? '',
      bookingId: data['bookingId'],
      tripId: data['tripId'],
      createdAt: _readDateTime(data['createdAt']) ?? DateTime.now(),
    );
  }

  bool get isIncome => amount >= 0;

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
