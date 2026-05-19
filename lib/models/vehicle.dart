import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String ownerId;
  final String name; // e.g. 'Toyota Vios'
  final String licensePlate;
  final String type; // 'car', 'motorbike'
  final String color;
  final int seats;
  final bool isDefault;
  final DateTime? createdAt;

  Vehicle({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.licensePlate,
    this.type = 'car',
    this.color = 'Trắng',
    this.seats = 4,
    this.isDefault = false,
    this.createdAt,
  });

  String get typeLabel => type == 'car' ? 'Ô tô' : 'Xe máy';

  Map<String, dynamic> toMap() => {
    'id': id,
    'ownerId': ownerId,
    'name': name,
    'licensePlate': licensePlate,
    'type': type,
    'color': color,
    'seats': seats,
    'isDefault': isDefault,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };

  factory Vehicle.fromMap(String id, Map<String, dynamic> d) => Vehicle(
    id: id,
    ownerId: d['ownerId'] ?? '',
    name: d['name'] ?? '',
    licensePlate: d['licensePlate'] ?? '',
    type: d['type'] ?? 'car',
    color: d['color'] ?? 'Trắng',
    seats: (d['seats'] as num?)?.toInt() ?? 4,
    isDefault: d['isDefault'] ?? false,
    createdAt: _readDateTime(d['createdAt']),
  );

  Vehicle copyWith({
    String? name,
    String? licensePlate,
    String? type,
    String? color,
    int? seats,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Vehicle(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      licensePlate: licensePlate ?? this.licensePlate,
      type: type ?? this.type,
      color: color ?? this.color,
      seats: seats ?? this.seats,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
