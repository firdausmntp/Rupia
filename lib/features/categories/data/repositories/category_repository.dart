import '../../../../core/services/database_service.dart';
import '../models/custom_category_model.dart';

class CategoryRepository {
  /// Get all categories
  Future<List<CustomCategoryModel>> getAllCategories() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'custom_categories',
      orderBy: 'sort_order ASC, name ASC',
    );
    return maps.map((map) => CustomCategoryModel.fromMap(map)).toList();
  }

  /// Get categories by type
  Future<List<CustomCategoryModel>> getCategoriesByType(CategoryType type) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'custom_categories',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'sort_order ASC, name ASC',
    );
    return maps.map((map) => CustomCategoryModel.fromMap(map)).toList();
  }

  /// Get category by ID
  Future<CustomCategoryModel?> getCategoryById(int id) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'custom_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CustomCategoryModel.fromMap(maps.first);
  }

  /// Add new category
  Future<int> addCategory(CustomCategoryModel category) async {
    final db = await DatabaseService.database;
    return await db.insert('custom_categories', category.toMap());
  }

  /// Update category
  Future<int> updateCategory(CustomCategoryModel category) async {
    if (category.id == null) throw Exception('Category ID is required');
    
    final db = await DatabaseService.database;
    return await db.update(
      'custom_categories',
      category.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Delete category
  Future<int> deleteCategory(int id) async {
    final db = await DatabaseService.database;
    
    // Check if default category
    final category = await getCategoryById(id);
    if (category?.isDefault == true) {
      throw Exception('Cannot delete default category');
    }
    
    // TODO: Handle transactions with this category
    // Either delete them or move to "Lainnya"
    
    return await db.delete(
      'custom_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Reorder categories
  Future<void> reorderCategories(List<int> categoryIds) async {
    final db = await DatabaseService.database;
    for (int i = 0; i < categoryIds.length; i++) {
      await db.update(
        'custom_categories',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [categoryIds[i]],
      );
    }
  }

  /// Search categories
  Future<List<CustomCategoryModel>> searchCategories(String query) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'custom_categories',
      where: 'LOWER(name) LIKE ?',
      whereArgs: ['%${query.toLowerCase()}%'],
      orderBy: 'sort_order ASC, name ASC',
    );
    return maps.map((map) => CustomCategoryModel.fromMap(map)).toList();
  }
}
