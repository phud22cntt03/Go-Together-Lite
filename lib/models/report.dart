import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String postId;
  final String reporterId;
  final String reason;
  final String status; // pending, reviewed, resolved
  final DateTime? createdAt;

  Report({
    required this.id,
    required this.postId,
    required this.reporterId,
    required this.reason,
    this.status = 'pending',
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'postId': postId,
    'reporterId': reporterId,
    'reason': reason,
    'status': status,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };

  factory Report.fromMap(String id, Map<String, dynamic> d) => Report(
    id: id,
    postId: d['postId'] ?? '',
    reporterId: d['reporterId'] ?? '',
    reason: d['reason'] ?? '',
    status: d['status'] ?? 'pending',
    createdAt: _readDateTime(d['createdAt']),
  );

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
