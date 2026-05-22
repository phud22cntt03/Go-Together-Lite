import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wallet.dart';

class WalletService {
  static final _db = FirebaseFirestore.instance;
  static const _walletsCol = 'wallets';
  static const _txCol = 'wallet_transactions';

  static Stream<UserWallet> watchWallet(String userId) {
    return _db.collection(_walletsCol).doc(userId).snapshots().map((snap) {
      if (snap.exists && snap.data() != null) {
        return UserWallet.fromMap(snap.data()!);
      }
      return UserWallet(userId: userId);
    });
  }

  static Stream<List<WalletTransaction>> watchTransactions(String userId) {
    return _db
        .collection(_txCol)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final items = snap.docs
              .map((doc) => WalletTransaction.fromMap(doc.id, doc.data()))
              .toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  static Future<void> topUp({
    required String userId,
    required int amount,
  }) async {
    if (amount <= 0) {
      throw Exception('Số tiền nạp không hợp lệ');
    }

    final walletRef = _db.collection(_walletsCol).doc(userId);
    final txRef = _db.collection(_txCol).doc();
    final batch = _db.batch();

    batch.set(walletRef, {
      'userId': userId,
      'balance': FieldValue.increment(amount),
      'totalSpent': FieldValue.increment(0),
      'totalReceived': FieldValue.increment(0),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    batch.set(txRef, {
      'id': txRef.id,
      'userId': userId,
      'type': 'topup',
      'amount': amount,
      'title': 'Nạp ví SmartCarpool qua MoMo Sandbox',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
