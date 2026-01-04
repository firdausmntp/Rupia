// lib/features/geofencing/data/services/geofence_service.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../models/geofence_model.dart';

class GeofenceService {
  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  StreamSubscription<Position>? _positionSubscription;
  final Set<String> _insideGeofences = {};
  
  static const String _tableName = 'geofences';
  static const String _enabledKey = 'geofencing_enabled';

  // Initialize notifications
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(initSettings);
    
    // Create geofences table if not exists
    await _createTable();
  }

  Future<void> _createTable() async {
    await DatabaseService.rawQuery('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        radius REAL DEFAULT 200,
        budgetCategory TEXT,
        budgetAmount REAL,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');
  }

  // Check if geofencing is enabled
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  // Enable/disable geofencing
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    
    if (enabled) {
      await startMonitoring();
    } else {
      stopMonitoring();
    }
  }

  // Request location permissions
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  // Start monitoring geofences
  Future<void> startMonitoring() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return;

    // Use lower accuracy for battery efficiency
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 50, // Update every 50 meters
    );

    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_onPositionUpdate);
  }

  // Stop monitoring
  void stopMonitoring() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _insideGeofences.clear();
  }

  // Handle position updates
  Future<void> _onPositionUpdate(Position position) async {
    final geofences = await getAllGeofences();
    final activeGeofences = geofences.where((g) => g.isActive).toList();

    for (final geofence in activeGeofences) {
      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        geofence.latitude,
        geofence.longitude,
      );

      final isInside = distance <= geofence.radius;
      final wasInside = _insideGeofences.contains(geofence.id);

      if (isInside && !wasInside) {
        // Entered geofence
        _insideGeofences.add(geofence.id);
        await _showEntryNotification(geofence);
      } else if (!isInside && wasInside) {
        // Exited geofence
        _insideGeofences.remove(geofence.id);
      }
    }
  }

  // Calculate distance between two points (Haversine formula)
  double _calculateDistance(
    double lat1, double lon1, 
    double lat2, double lon2,
  ) {
    const earthRadius = 6371000; // meters
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  // Show notification when entering a geofence
  Future<void> _showEntryNotification(GeofenceModel geofence) async {
    String body = 'Anda memasuki area ${geofence.name}';
    
    if (geofence.budgetAmount != null) {
      body += '\nBudget tersisa: ${CurrencyFormatter.format(geofence.budgetAmount!)}';
    }

    const androidDetails = AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Alerts',
      channelDescription: 'Notifikasi saat memasuki area tertentu',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      geofence.id.hashCode,
      '📍 ${geofence.name}',
      body,
      details,
    );
  }

  // CRUD Operations
  Future<void> addGeofence(GeofenceModel geofence) async {
    await DatabaseService.insert(_tableName, geofence.toMap());
  }

  Future<List<GeofenceModel>> getAllGeofences() async {
    final results = await DatabaseService.query(
      _tableName,
      orderBy: 'createdAt DESC',
    );
    return results.map((map) => GeofenceModel.fromMap(map)).toList();
  }

  Future<GeofenceModel?> getGeofenceById(String id) async {
    final results = await DatabaseService.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return GeofenceModel.fromMap(results.first);
  }

  Future<void> updateGeofence(GeofenceModel geofence) async {
    await DatabaseService.update(
      _tableName,
      geofence.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [geofence.id],
    );
  }

  Future<void> deleteGeofence(String id) async {
    await DatabaseService.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    _insideGeofences.remove(id);
  }

  Future<void> toggleGeofence(String id, bool isActive) async {
    await DatabaseService.rawUpdate(
      'UPDATE $_tableName SET isActive = ?, updatedAt = ? WHERE id = ?',
      [isActive ? 1 : 0, DateTime.now().toIso8601String(), id],
    );
  }

  void dispose() {
    stopMonitoring();
  }
}
