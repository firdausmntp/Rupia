// lib/features/auth/presentation/providers/auth_providers.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../main.dart' show firebaseInitialized;
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Helper to check if Firebase auth is available
bool get _isFirebaseAuthAvailable {
  return !kIsWeb && firebaseInitialized;
}

// Auth State Stream Provider (with fallback for offline mode)
final authStateProvider = StreamProvider<User?>((ref) {
  if (!_isFirebaseAuthAvailable) {
    // Return null stream for offline/demo mode
    debugPrint('ℹ️ Auth state: Offline mode, returning null stream');
    return Stream.value(null);
  }
  
  try {
    final authService = ref.watch(authServiceProvider);
    if (!authService.isFirebaseAvailable) {
      debugPrint('ℹ️ Auth state: Firebase not available in AuthService');
      return Stream.value(null);
    }
    return authService.authStateChanges;
  } catch (e) {
    debugPrint('⚠️ Auth state error: $e');
    return Stream.value(null);
  }
});

// Current User Provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  if (!_isFirebaseAuthAvailable) {
    return null; // No user in offline mode
  }
  
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      try {
        final authService = ref.read(authServiceProvider);
        return await authService.getCurrentUserModel();
      } catch (e) {
        debugPrint('⚠️ getCurrentUserModel error: $e');
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(const AuthState());

  Future<void> signInWithGoogle() async {
    // Check if Firebase is available
    if (!_isFirebaseAuthAvailable || !_authService.isFirebaseAvailable) {
      state = state.copyWith(
        isLoading: false,
        error: 'Mode offline: Firebase tidak tersedia. Pastikan koneksi internet dan coba lagi.',
      );
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.signInWithGoogle();
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: user != null,
      );
    } catch (e) {
      debugPrint('⚠️ signInWithGoogle error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Login gagal: ${e.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.deleteAccount();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth State
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

// Auth Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Is Signed In Provider
final isSignedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});
