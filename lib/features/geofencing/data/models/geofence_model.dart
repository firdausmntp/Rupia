// lib/features/geofencing/data/models/geofence_model.dart

class GeofenceModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius; // in meters
  final String? budgetCategory;
  final double? budgetAmount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GeofenceModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radius = 200, // default 200 meters
    this.budgetCategory,
    this.budgetAmount,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'budgetCategory': budgetCategory,
      'budgetAmount': budgetAmount,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory GeofenceModel.fromMap(Map<String, dynamic> map) {
    return GeofenceModel(
      id: map['id'] as String,
      name: map['name'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      radius: (map['radius'] as num?)?.toDouble() ?? 200,
      budgetCategory: map['budgetCategory'] as String?,
      budgetAmount: (map['budgetAmount'] as num?)?.toDouble(),
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  GeofenceModel copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? radius,
    String? budgetCategory,
    double? budgetAmount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GeofenceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      budgetCategory: budgetCategory ?? this.budgetCategory,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
