// lib/features/geofencing/presentation/providers/geofence_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/geofence_model.dart';
import '../../data/services/geofence_service.dart';

final geofenceServiceProvider = Provider<GeofenceService>((ref) {
  final service = GeofenceService();
  ref.onDispose(() => service.dispose());
  return service;
});

final geofencesProvider = FutureProvider<List<GeofenceModel>>((ref) async {
  final service = ref.watch(geofenceServiceProvider);
  return await service.getAllGeofences();
});

final geofenceEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(geofenceServiceProvider);
  return await service.isEnabled();
});

final currentPositionProvider = FutureProvider<Position?>((ref) async {
  final service = ref.watch(geofenceServiceProvider);
  return await service.getCurrentPosition();
});

class GeofenceState {
  final bool isLoading;
  final List<GeofenceModel> geofences;
  final bool isEnabled;
  final String? error;
  final Position? currentPosition;

  const GeofenceState({
    this.isLoading = false,
    this.geofences = const [],
    this.isEnabled = false,
    this.error,
    this.currentPosition,
  });

  GeofenceState copyWith({
    bool? isLoading,
    List<GeofenceModel>? geofences,
    bool? isEnabled,
    String? error,
    Position? currentPosition,
  }) {
    return GeofenceState(
      isLoading: isLoading ?? this.isLoading,
      geofences: geofences ?? this.geofences,
      isEnabled: isEnabled ?? this.isEnabled,
      error: error,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}

class GeofenceNotifier extends StateNotifier<GeofenceState> {
  final GeofenceService _service;
  final Uuid _uuid = const Uuid();

  GeofenceNotifier(this._service) : super(const GeofenceState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.initialize();
      final geofences = await _service.getAllGeofences();
      final isEnabled = await _service.isEnabled();
      final position = await _service.getCurrentPosition();
      
      state = state.copyWith(
        isLoading: false,
        geofences: geofences,
        isEnabled: isEnabled,
        currentPosition: position,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final geofences = await _service.getAllGeofences();
      state = state.copyWith(
        isLoading: false,
        geofences: geofences,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addGeofence({
    required String name,
    required double latitude,
    required double longitude,
    double radius = 200,
    String? budgetCategory,
    double? budgetAmount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final geofence = GeofenceModel(
        id: _uuid.v4(),
        name: name,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        budgetCategory: budgetCategory,
        budgetAmount: budgetAmount,
        createdAt: DateTime.now(),
      );
      
      await _service.addGeofence(geofence);
      await refresh();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateGeofence(GeofenceModel geofence) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.updateGeofence(geofence);
      await refresh();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteGeofence(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.deleteGeofence(id);
      await refresh();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleGeofence(String id, bool isActive) async {
    try {
      await _service.toggleGeofence(id, isActive);
      await refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> setEnabled(bool enabled) async {
    try {
      await _service.setEnabled(enabled);
      state = state.copyWith(isEnabled: enabled);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateCurrentPosition() async {
    final position = await _service.getCurrentPosition();
    state = state.copyWith(currentPosition: position);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final geofenceNotifierProvider = StateNotifierProvider<GeofenceNotifier, GeofenceState>((ref) {
  final service = ref.watch(geofenceServiceProvider);
  return GeofenceNotifier(service);
});
