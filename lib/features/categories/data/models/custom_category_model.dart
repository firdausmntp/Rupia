import 'package:sqflite/sqflite.dart';

/// Model untuk kategori custom
class CustomCategoryModel {
  final int? id;
  final String name;
  final String iconName; // Material icon name
  final String colorHex; // Hex color code
  final CategoryType type; // income atau expense
  final bool isDefault; // apakah kategori default sistem
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CustomCategoryModel({
    this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.type,
    this.isDefault = false,
    this.sortOrder = 0,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CustomCategoryModel.fromMap(Map<String, dynamic> map) {
    return CustomCategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconName: map['icon_name'] as String,
      colorHex: map['color_hex'] as String,
      type: CategoryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CategoryType.expense,
      ),
      isDefault: (map['is_default'] as int) == 1,
      sortOrder: map['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'icon_name': iconName,
      'color_hex': colorHex,
      'type': type.name,
      'is_default': isDefault ? 1 : 0,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CustomCategoryModel copyWith({
    int? id,
    String? name,
    String? iconName,
    String? colorHex,
    CategoryType? type,
    bool? isDefault,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE custom_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        type TEXT NOT NULL,
        is_default INTEGER DEFAULT 0,
        sort_order INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  static Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      // Expense categories
      {'name': 'Makanan & Minuman', 'icon_name': 'restaurant', 'color_hex': 'FF9800', 'type': 'expense', 'is_default': 1, 'sort_order': 1},
      {'name': 'Transport', 'icon_name': 'directions_car', 'color_hex': '2196F3', 'type': 'expense', 'is_default': 1, 'sort_order': 2},
      {'name': 'Belanja', 'icon_name': 'shopping_cart', 'color_hex': '9C27B0', 'type': 'expense', 'is_default': 1, 'sort_order': 3},
      {'name': 'Hiburan', 'icon_name': 'movie', 'color_hex': 'E91E63', 'type': 'expense', 'is_default': 1, 'sort_order': 4},
      {'name': 'Tagihan', 'icon_name': 'receipt', 'color_hex': 'F44336', 'type': 'expense', 'is_default': 1, 'sort_order': 5},
      {'name': 'Kesehatan', 'icon_name': 'medical_services', 'color_hex': '4CAF50', 'type': 'expense', 'is_default': 1, 'sort_order': 6},
      {'name': 'Pendidikan', 'icon_name': 'school', 'color_hex': '3F51B5', 'type': 'expense', 'is_default': 1, 'sort_order': 7},
      {'name': 'Lainnya', 'icon_name': 'more_horiz', 'color_hex': '607D8B', 'type': 'expense', 'is_default': 1, 'sort_order': 99},
      
      // Income categories
      {'name': 'Gaji', 'icon_name': 'account_balance', 'color_hex': '4CAF50', 'type': 'income', 'is_default': 1, 'sort_order': 1},
      {'name': 'Bisnis', 'icon_name': 'business_center', 'color_hex': '2196F3', 'type': 'income', 'is_default': 1, 'sort_order': 2},
      {'name': 'Investasi', 'icon_name': 'trending_up', 'color_hex': 'FF5722', 'type': 'income', 'is_default': 1, 'sort_order': 3},
      {'name': 'Hadiah', 'icon_name': 'card_giftcard', 'color_hex': 'E91E63', 'type': 'income', 'is_default': 1, 'sort_order': 4},
      {'name': 'Lainnya', 'icon_name': 'more_horiz', 'color_hex': '607D8B', 'type': 'income', 'is_default': 1, 'sort_order': 99},
    ];

    for (var category in defaultCategories) {
      await db.insert('custom_categories', {
        ...category,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}

enum CategoryType {
  income,
  expense,
}
