// lib/features/auth/data/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../main.dart' show firebaseInitialized;
import '../models/user_model.dart';

class AuthService {
  FirebaseAuth? _firebaseAuth;
  GoogleSignIn? _googleSignIn;
  FirebaseFirestore? _firestore;
  bool _initialized = false;

  AuthService() {
    _initializeServices();
  }
  
  void _initializeServices() {
    if (_initialized) return;
    
    // Only initialize if Firebase was successfully initialized in main.dart
    final shouldUseFirebase = !kIsWeb && firebaseInitialized;
    
    if (shouldUseFirebase) {
      try {
        _firebaseAuth = FirebaseAuth.instance;
        _googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'https://www.googleapis.com/auth/spreadsheets',
            'https://www.googleapis.com/auth/drive.file',
          ],
          // Web Client ID from Firebase Console - required for Android release builds
          serverClientId: '943368254932-vdvpkpmmm9dq441i1sc2jk8p4mbc35ki.apps.googleusercontent.com',
        );
        _firestore = FirebaseFirestore.instance;
        debugPrint('✅ AuthService initialized with Firebase');
      } catch (e) {
        debugPrint('⚠️ AuthService Firebase init error: $e');
        _firebaseAuth = null;
        _googleSignIn = null;
        _firestore = null;
      }
    } else {
      debugPrint('ℹ️ AuthService running in offline mode');
    }
    _initialized = true;
  }
  
  // Check if Firebase auth is available
  bool get isFirebaseAvailable => _firebaseAuth != null;

  // Stream of auth state changes
  Stream<User?> get authStateChanges {
    if (_firebaseAuth == null) return Stream.value(null);
    return _firebaseAuth!.authStateChanges();
  }

  // Current user
  User? get currentUser {
    if (_firebaseAuth == null) return null;
    return _firebaseAuth!.currentUser;
  }

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    if (_googleSignIn == null || _firebaseAuth == null || _firestore == null) {
      throw AuthException('Demo mode: Firebase belum dikonfigurasi');
    }

    try {
      // Check if Google Play Services is available (Android only)
      final isAvailable = await _googleSignIn!.isSignedIn();
      debugPrint('Google Sign-In available, current status: $isAvailable');
      
      // Sign out first to ensure fresh login prompt
      if (isAvailable) {
        await _googleSignIn!.signOut();
      }
      
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      
      if (googleUser == null) {
        debugPrint('⚠️ Google Sign-In cancelled by user');
        return null;
      }
      
      debugPrint('Google user email: ${googleUser.email}');

      // Get auth details
      final GoogleSignInAuthentication googleAuth;
      try {
        googleAuth = await googleUser.authentication;
      } catch (e) {
        debugPrint('⚠️ Failed to get Google auth: $e');
        throw AuthException('Gagal mendapatkan autentikasi Google. Pastikan SHA-1 fingerprint sudah dikonfigurasi di Firebase Console.');
      }
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint('⚠️ Missing tokens - accessToken: ${googleAuth.accessToken != null}, idToken: ${googleAuth.idToken != null}');
        throw AuthException('Token autentikasi tidak lengkap. Pastikan OAuth client sudah dikonfigurasi di Firebase Console.');
      }

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential;
      try {
        userCredential = await _firebaseAuth!.signInWithCredential(credential);
      } catch (e) {
        debugPrint('⚠️ Firebase signInWithCredential failed: $e');
        if (e.toString().contains('CONFIGURATION_NOT_FOUND')) {
          throw AuthException('Konfigurasi Firebase tidak lengkap. Pastikan SHA-1 dan SHA-256 fingerprint sudah ditambahkan di Firebase Console.');
        }
        rethrow;
      }
      
      final User? user = userCredential.user;
      if (user == null) {
        throw AuthException('Login gagal: User tidak ditemukan');
      }
      
      debugPrint('✅ Firebase sign-in successful for ${user.email}');

      // Create/update user in Firestore
      final userModel = await _createOrUpdateUser(user);
      
      return userModel;
    } on AuthException {
      rethrow;
    } catch (e) {
      debugPrint('⚠️ Google Sign-In failed: $e');
      
      // Provide user-friendly error messages
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('network')) {
        throw AuthException('Koneksi internet bermasalah. Periksa koneksi Anda dan coba lagi.');
      } else if (errorStr.contains('canceled') || errorStr.contains('cancelled')) {
        return null; // User cancelled
      } else if (errorStr.contains('sign_in_failed') || errorStr.contains('api_not_connected')) {
        throw AuthException('Google Sign-In gagal. Pastikan:\n1. Google Play Services sudah update\n2. SHA-1 fingerprint sudah dikonfigurasi\n3. OAuth consent screen sudah disetup');
      } else if (errorStr.contains('configuration')) {
        throw AuthException('Konfigurasi Google Sign-In belum lengkap. Hubungi developer.');
      }
      
      throw AuthException('Login gagal: $e');
    }
  }

  // Create or update user in Firestore
  Future<UserModel> _createOrUpdateUser(User user) async {
    if (_firestore == null) {
      throw AuthException('Firestore not available in demo mode');
    }
    final userDoc = _firestore!.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    final now = DateTime.now();
    
    if (docSnapshot.exists) {
      // Update last login
      await userDoc.update({
        'lastLoginAt': now.toIso8601String(),
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
      });
      
      final data = docSnapshot.data()!;
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: DateTime.parse(data['createdAt'] as String),
        lastLoginAt: now,
        isPremium: data['isPremium'] == true,
      );
    } else {
      // Create new user
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: now,
        lastLoginAt: now,
        isPremium: false,
      );

      await userDoc.set({
        'id': userModel.id,
        'email': userModel.email,
        'displayName': userModel.displayName,
        'photoUrl': userModel.photoUrl,
        'createdAt': userModel.createdAt.toIso8601String(),
        'lastLoginAt': userModel.lastLoginAt?.toIso8601String(),
        'isPremium': userModel.isPremium,
      });

      return userModel;
    }
  }

  // Get current user model from Firestore
  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (user == null || _firestore == null) return null;

    final docSnapshot = await _firestore!
        .collection('users')
        .doc(user.uid)
        .get();
    
    if (!docSnapshot.exists) return null;

    final data = docSnapshot.data()!;
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: DateTime.parse(data['createdAt'] as String),
      lastLoginAt: data['lastLoginAt'] != null 
          ? DateTime.parse(data['lastLoginAt'] as String)
          : null,
      isPremium: data['isPremium'] == true,
    );
  }

  // Sign out
  Future<void> signOut() async {
    if (_firebaseAuth == null || _googleSignIn == null) return;
    await Future.wait([
      _firebaseAuth!.signOut(),
      _googleSignIn!.signOut(),
    ]);
  }

  // Get Google access token for Sheets API
  Future<String?> getGoogleAccessToken() async {
    if (_googleSignIn == null) return null;
    
    try {
      final googleUser = await _googleSignIn!.signInSilently();
      if (googleUser == null) return null;
      
      final auth = await googleUser.authentication;
      return auth.accessToken;
    } catch (e) {
      debugPrint('⚠️ getGoogleAccessToken error: $e');
      return null;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null || _firestore == null || _googleSignIn == null) return;

    // Delete user data from Firestore
    await _firestore!.collection('users').doc(user.uid).delete();
    
    // Delete Firebase Auth account
    await user.delete();
    
    // Sign out from Google
    await _googleSignIn!.signOut();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
}
