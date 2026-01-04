import 'dart:async';
import '../models/budget_model.dart';
import '../../../../core/services/database_service.dart';

class BudgetRepository {
  static const String _tableName = 'budgets';

  // Create
  Future<int> addBudget(BudgetModel budget) async {
    final map = budget.toMap();
    map.remove('id');
    return await DatabaseService.insert(_tableName, map);
  }

  // Read all
  Future<List<BudgetModel>> getAllBudgets() async {
    final maps = await DatabaseService.query(
      _tableName,
      orderBy: 'year DESC, month DESC',
    );
    return maps.map((map) => BudgetModel.fromMap(map)).toList();
  }

  // Read by ID
  Future<BudgetModel?> getBudgetById(int id) async {
    final maps = await DatabaseService.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return BudgetModel.fromMap(maps.first);
  }

  // Get budgets for specific month/year
  Future<List<BudgetModel>> getBudgetsByMonth(int month, int year) async {
    final maps = await DatabaseService.query(
      _tableName,
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
    return maps.map((map) => BudgetModel.fromMap(map)).toList();
  }

  // Get budget for category in specific month
  Future<BudgetModel?> getBudgetByCategory(
      String categoryName, int month, int year) async {
    final maps = await DatabaseService.query(
      _tableName,
      where: 'categoryName = ? AND month = ? AND year = ?',
      whereArgs: [categoryName, month, year],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return BudgetModel.fromMap(maps.first);
  }

  // Update
  Future<int> updateBudget(BudgetModel budget) async {
    final updatedBudget = budget.copyWith();  // This auto-sets updatedAt
    return await DatabaseService.update(
      _tableName,
      updatedBudget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  // Update spent amount
  Future<void> updateSpentAmount(int id, double spent) async {
    await DatabaseService.rawUpdate(
      'UPDATE $_tableName SET spent = ?, updatedAt = ? WHERE id = ?',
      [spent, DateTime.now().millisecondsSinceEpoch, id],
    );
  }

  // Delete
  Future<bool> deleteBudget(int id) async {
    final count = await DatabaseService.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // Get total budget for month
  Future<double> getTotalBudget(int month, int year) async {
    final result = await DatabaseService.rawQuery(
      'SELECT SUM(amount) as total FROM $_tableName WHERE month = ? AND year = ?',
      [month, year],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get total spent for month
  Future<double> getTotalSpent(int month, int year) async {
    final result = await DatabaseService.rawQuery(
      'SELECT SUM(spent) as total FROM $_tableName WHERE month = ? AND year = ?',
      [month, year],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Copy budgets from previous month
  Future<void> copyBudgetsFromPreviousMonth(int toMonth, int toYear) async {
    int fromMonth = toMonth - 1;
    int fromYear = toYear;
    if (fromMonth == 0) {
      fromMonth = 12;
      fromYear--;
    }

    final previousBudgets = await getBudgetsByMonth(fromMonth, fromYear);

    for (final budget in previousBudgets) {
      await addBudget(BudgetModel(
        name: budget.name,
        amount: budget.amount,
        spent: 0,
        month: toMonth,
        year: toYear,
        categoryName: budget.categoryName,
        userId: budget.userId,
      ));
    }
  }

  // Stream-like fetch (polling)
  Stream<List<BudgetModel>> watchBudgets(int month, int year) async* {
    while (true) {
      yield await getBudgetsByMonth(month, year);
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}
