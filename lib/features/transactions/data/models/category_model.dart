class CategoryModel {
  final int? id;
  final String name;
  final String icon;
  final int colorValue;
  final bool isIncome;
  final bool isCustom;
  final bool isActive;
  final String? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.isIncome,
    this.isCustom = false,
    this.isActive = true,
    this.userId,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'colorValue': colorValue,
      'isIncome': isIncome ? 1 : 0,
      'isCustom': isCustom ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      'userId': userId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      colorValue: map['colorValue'] as int,
      isIncome: (map['isIncome'] as int) == 1,
      isCustom: (map['isCustom'] as int) == 1,
      isActive: (map['isActive'] as int) == 1,
      userId: map['userId'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
    );
  }
}
