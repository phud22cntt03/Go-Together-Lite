import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static User? get currentFirebaseUser => _auth.currentUser;

  static Future<AppUser?> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;

    await cred.user!.updateDisplayName(fullName);

    final appUser = AppUser(
      id: uid,
      fullName: fullName,
      email: email,
      phone: phone,
      rating: 5.0,
      totalTrips: 0,
      totalKm: 0,
      role: 'both',
      isVerified: false,
    );

    await _db.collection('users').doc(uid).set(appUser.toMap());
    return appUser;
  }

  static Future<AppUser?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _fetchUser(cred.user!.uid);
  }

  static Future<AppUser?> loginWithGoogle() async {
    UserCredential credential;

    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');
      credential = await _auth.signInWithPopup(provider);
    } else {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'Google sign-in was cancelled by the user.',
        );
      }

      final googleAuth = await googleUser.authentication;
      final authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      credential = await _auth.signInWithCredential(authCredential);
    }

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Google sign-in completed without a Firebase user.',
      );
    }

    final existingUser = await _fetchUser(firebaseUser.uid);
    if (existingUser != null) {
      return existingUser;
    }

    final newUser = AppUser(
      id: firebaseUser.uid,
      fullName: firebaseUser.displayName ?? 'Người dùng Google',
      email: firebaseUser.email ?? '',
      phone: firebaseUser.phoneNumber ?? '',
      avatarUrl: firebaseUser.photoURL,
      rating: 5.0,
      totalTrips: 0,
      totalKm: 0,
      role: 'both',
      isVerified: firebaseUser.emailVerified,
    );

    await _db.collection('users').doc(newUser.id).set(newUser.toMap());
    return newUser;
  }

  static Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  static Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  static Future<AppUser?> _fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  static Future<AppUser?> getCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _fetchUser(uid);
  }

  static Future<void> updateProfile(AppUser user) async {
    await _db.collection('users').doc(user.id).update({
      'fullName': user.fullName,
      'phone': user.phone,
      'avatarUrl': user.avatarUrl,
    });
    await _auth.currentUser?.updateDisplayName(user.fullName);
    if (user.avatarUrl != null && !user.avatarUrl!.startsWith('data:image/')) {
      await _auth.currentUser?.updatePhotoURL(user.avatarUrl);
    }
  }

  static Future<String> uploadAvatarBytes({
    required String userId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final ext = fileName.split('.').last.toLowerCase();
    final contentType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
    if (kIsWeb) {
      return _buildFirestoreAvatarDataUrl(bytes, contentType);
    }

    final ref = FirebaseStorage.instance
        .ref()
        .child('avatars')
        .child(userId)
        .child(fileName);

    try {
      await ref
          .putData(bytes, SettableMetadata(contentType: contentType))
          .timeout(const Duration(seconds: 10));
      return ref.getDownloadURL().timeout(const Duration(seconds: 10));
    } catch (_) {
      return _buildFirestoreAvatarDataUrl(bytes, contentType);
    }
  }

  static String _buildFirestoreAvatarDataUrl(
    Uint8List bytes,
    String contentType,
  ) {
    const maxFirestoreSafeBytes = 650 * 1024;
    if (bytes.lengthInBytes > maxFirestoreSafeBytes) {
      throw Exception(
        'Anh qua lon. Hay chon anh nho hon 650KB hoac nang cap Firebase Storage.',
      );
    }
    return 'data:$contentType;base64,${base64Encode(bytes)}';
  }
}
