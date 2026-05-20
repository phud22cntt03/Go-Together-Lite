import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  AuthProvider() {
    AuthService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        _currentUser = await AuthService.getCurrentUserProfile();
        _currentUser ??= AppUser(
          id: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? 'Nguoi dung',
          email: firebaseUser.email ?? '',
          phone: '',
          rating: 5.0,
          totalTrips: 0,
          totalKm: 0,
          role: 'both',
          isVerified: firebaseUser.emailVerified,
        );
      } else {
        _currentUser = null;
      }
      _isInitialized = true;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      _currentUser = await AuthService.login(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Da xay ra loi: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      _currentUser = await AuthService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Da xay ra loi: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await AuthService.sendPasswordReset(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Khong the gui email dat lai mat khau';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile(AppUser updated) async {
    try {
      await AuthService.updateProfile(updated);
      _currentUser = updated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Khong the cap nhat ho so: $e';
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Khong tim thay tai khoan voi email nay';
      case 'wrong-password':
        return 'Mat khau khong chinh xac';
      case 'invalid-email':
        return 'Email khong hop le';
      case 'user-disabled':
        return 'Tai khoan da bi vo hieu hoa';
      case 'email-already-in-use':
        return 'Email nay da duoc su dung';
      case 'weak-password':
        return 'Mat khau qua yeu, toi thieu 6 ky tu';
      case 'too-many-requests':
        return 'Qua nhieu yeu cau. Vui long thu lai sau';
      case 'invalid-credential':
        return 'Email hoac mat khau khong dung';
      default:
        return 'Loi xac thuc ($code)';
    }
  }
}
