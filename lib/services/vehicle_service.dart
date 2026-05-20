import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';

class VehicleService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _col = 'vehicles';

  static Stream<List<Vehicle>> watchVehicles(String ownerId) {
    return _db
        .collection(_col)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snap) => _sortVehicles(snap.docs));
  }

  static Future<List<Vehicle>> getVehicles(String ownerId) async {
    final snap = await _db
        .collection(_col)
        .where('ownerId', isEqualTo: ownerId)
        .get();
    return _sortVehicles(snap.docs);
  }

  static Future<Vehicle> createVehicle({
    required String ownerId,
    required String name,
    required String licensePlate,
    required String type,
    required String color,
    required int seats,
    bool isDefault = false,
  }) async {
    final ref = _db.collection(_col).doc();
    final shouldBeDefault = isDefault || (await getVehicles(ownerId)).isEmpty;

    final vehicle = Vehicle(
      id: ref.id,
      ownerId: ownerId,
      name: name,
      licensePlate: licensePlate,
      type: type,
      color: color,
      seats: seats,
      isDefault: shouldBeDefault,
      createdAt: DateTime.now(),
    );

    await ref.set(vehicle.toMap());

    if (shouldBeDefault) {
      await setDefaultVehicle(ownerId, ref.id);
    }

    return vehicle.copyWith(isDefault: shouldBeDefault);
  }

  static Future<void> updateVehicle(Vehicle vehicle) async {
    await _db.collection(_col).doc(vehicle.id).update(vehicle.toMap());
  }

  static Future<void> deleteVehicle(String vehicleId) async {
    final doc = await _db.collection(_col).doc(vehicleId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final ownerId = data['ownerId'] as String? ?? '';
    final isDefault = data['isDefault'] as bool? ?? false;

    await _db.collection(_col).doc(vehicleId).delete();

    if (ownerId.isNotEmpty && isDefault) {
      final remaining = await getVehicles(ownerId);
      if (remaining.isNotEmpty) {
        await setDefaultVehicle(ownerId, remaining.first.id);
      }
    }
  }

  static Future<void> setDefaultVehicle(
    String ownerId,
    String vehicleId,
  ) async {
    final snap = await _db
        .collection(_col)
        .where('ownerId', isEqualTo: ownerId)
        .get();
    final batch = _db.batch();

    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == vehicleId});
    }

    await batch.commit();
  }

  static List<Vehicle> _sortVehicles(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final vehicles = docs.map((d) => Vehicle.fromMap(d.id, d.data())).toList();

    vehicles.sort((a, b) {
      final createdCompare =
          (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
            a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
          );
      if (createdCompare != 0) {
        return createdCompare;
      }

      if (a.isDefault != b.isDefault) {
        return a.isDefault ? -1 : 1;
      }

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return vehicles;
  }
}
