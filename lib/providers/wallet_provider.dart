import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/wallet.dart';
import '../services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  UserWallet? _wallet;
  List<WalletTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  String? _activeUserId;
  StreamSubscription? _walletSub;
  StreamSubscription? _txSub;

  UserWallet? get wallet => _wallet;
  List<WalletTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get balance => _wallet?.balance ?? 0;

  void watchUser(String userId) {
    if (_activeUserId == userId && _walletSub != null && _txSub != null) {
      return;
    }

    _activeUserId = userId;
    _walletSub?.cancel();
    _txSub?.cancel();

    _walletSub = WalletService.watchWallet(userId).listen(
      (wallet) {
        _wallet = wallet;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Không thể tải ví: $e';
        notifyListeners();
      },
    );

    _txSub = WalletService.watchTransactions(userId).listen(
      (items) {
        _transactions = items;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Không thể tải lịch sử ví: $e';
        notifyListeners();
      },
    );
  }

  Future<bool> topUp(String userId, int amount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await WalletService.topUp(userId: userId, amount: amount);
      return true;
    } on FirebaseException catch (e) {
      _error = _mapFirebaseError(e);
      return false;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _walletSub?.cancel();
    _txSub?.cancel();
    super.dispose();
  }

  String _mapFirebaseError(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return 'Firebase chưa cho phép ghi ví. Hãy deploy firestore.rules rồi thử lại.';
    }
    return e.message ?? 'Lỗi Firebase (${e.code})';
  }

  String _cleanError(Object e) {
    final message = e.toString().replaceAll('Exception: ', '');
    if (message.contains('converted Future')) {
      return 'Không thể nạp ví. Kiểm tra Firestore rules hoặc kết nối Firebase.';
    }
    return message;
  }
}
