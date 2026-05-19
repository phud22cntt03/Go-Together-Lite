import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  AuthProvider() {
    // Theo dõi trạng thái auth Firebase
    AuthService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        // Đã đăng nhập — lấy profile từ Firestore
        _currentUser = await AuthService.getCurrentUserProfile();
        // Fallback nếu Firestore chưa có (người dùng mới)
        _currentUser ??= AppUser(
          id: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? 'Người dùng',
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
      notifyListeners();
    });
  }

  // ─── Đăng nhập bằng Firebase Auth ───────────────────────────────
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
      _error = 'Đã xảy ra lỗi: $e';
      _setLoading(false);
      return false;
    }
  }

  // ─── Đăng ký ────────────────────────────────────────────────────
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
      _error = 'Đã xảy ra lỗi: $e';
      _setLoading(false);
      return false;
    }
  }

  // ─── Đăng xuất ──────────────────────────────────────────────────
  Future<void> logout() async {
    await AuthService.logout();
    _currentUser = null;
    notifyListeners();
  }

  // ─── Quên mật khẩu ──────────────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await AuthService.sendPasswordReset(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Không thể gửi email đặt lại mật khẩu';
      _setLoading(false);
      return false;
    }
  }

  // ─── Cập nhật profile ───────────────────────────────────────────
  Future<void> updateProfile(AppUser updated) async {
    try {
      await AuthService.updateProfile(updated);
      _currentUser = updated;
      notifyListeners();
    } catch (e) {
      _error = 'Không thể cập nhật hồ sơ';
      notifyListeners();
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  // ─── Map mã lỗi Firebase sang tiếng Việt ───────────────────────
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'wrong-password':
        return 'Mật khẩu không chính xác';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng';
      default:
        return 'Lỗi xác thực ($code)';
    }
  }
}
