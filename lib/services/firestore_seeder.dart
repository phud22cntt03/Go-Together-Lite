import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/mock_data.dart';

/// Seed sample Firestore data for local development.
class FirestoreSeeder {
  static final _db = FirebaseFirestore.instance;

  static Future<bool> _collectionHasData(String collection) async {
    final snap = await _db.collection(collection).limit(1).get();
    return snap.docs.isNotEmpty;
  }

  static Future<void> seedAll() async {
    await _seedTrips();
    await _seedCommunityPosts();
    await _seedVehicles();
    await _seedNotifications();
    await _seedReports();
  }

  static Future<void> _seedTrips() async {
    if (await _collectionHasData('trips')) return;

    final batch = _db.batch();
    for (final trip in MockData.recentTrips) {
      final ref = _db.collection('trips').doc(trip.id);
      batch.set(ref, {
        'id': trip.id,
        'driverId': 'seed_driver_${trip.id}',
        'driverName': trip.driverName,
        'driverAvatar': trip.driverAvatar,
        'driverRating': trip.driverRating,
        'vehicleName': trip.vehicleName,
        'licensePlate': trip.licensePlate,
        'vehicleType': trip.vehicleType,
        'pickupLocation': trip.pickupLocation,
        'dropoffLocation': trip.dropoffLocation,
        'pickupTime': trip.pickupTime,
        'dropoffTime': trip.dropoffTime,
        'pricePerSeat': trip.pricePerSeat,
        'totalSeats': trip.totalSeats,
        'availableSeats': trip.availableSeats,
        'driverNote': trip.driverNote,
        'status': trip.status,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  static Future<void> _seedCommunityPosts() async {
    if (await _collectionHasData('community_posts')) return;

    final batch = _db.batch();
    for (final post in MockData.communityPosts) {
      final ref = _db.collection('community_posts').doc(post.id);
      batch.set(ref, {
        'id': post.id,
        'authorId': 'seed_author_${post.id}',
        'authorName': post.authorName,
        'authorAvatar': null,
        'content': post.content,
        'topic': 'all',
        'likes': post.likes,
        'comments': post.comments,
        'likedBy': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  static Future<void> _seedVehicles() async {
    if (await _collectionHasData('vehicles')) return;

    final batch = _db.batch();
    final ref = _db.collection('vehicles').doc('seed_vehicle_1');
    batch.set(ref, {
      'id': ref.id,
      'ownerId': 'seed_driver_1',
      'name': 'Toyota Vios',
      'licensePlate': '51A-123.45',
      'type': 'car',
      'color': 'Trắng',
      'seats': 4,
      'isDefault': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  static Future<void> _seedNotifications() async {
    if (await _collectionHasData('notifications')) return;

    final batch = _db.batch();
    final ref = _db.collection('notifications').doc('seed_notif_1');
    batch.set(ref, {
      'id': ref.id,
      'userId': 'seed_user_1',
      'type': 'booking_new',
      'title': 'Đặt chỗ thành công',
      'body': 'Bạn đã đặt 1 ghế cho chuyến đi Quận 7 -> Quận 1.',
      'relatedId': '1',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  static Future<void> _seedReports() async {
    if (await _collectionHasData('reports')) return;

    final batch = _db.batch();
    final ref = _db.collection('reports').doc('seed_report_1');
    batch.set(ref, {
      'id': ref.id,
      'postId': '1',
      'reporterId': 'seed_user_1',
      'reason': 'Spam content',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
