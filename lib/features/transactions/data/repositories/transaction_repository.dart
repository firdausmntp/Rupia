import 'dart:async';
import '../models/transaction_model.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/enums/transaction_type.dart';

class TransactionRepository {
  static const String _tableName = 'transactions';

  // Create
  Future<int> addTransaction(TransactionModel transaction) async {
    final map = transaction.toMap();
    map.remove('id'); // Let SQLite auto-generate the ID
    return await DatabaseService.instance.insert(_tableName, map);
  }

  // Read all
  Future<List<TransactionModel>> getAllTransactions() async {
    final maps = await DatabaseService.instance.query(
      _tableName,
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  // Read by ID
  Future<TransactionModel?> getTransactionById(int id) async {
    final maps = await DatabaseService.instance.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TransactionModel.fromMap(maps.first);
  }

  // Read by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final maps = await DatabaseService.instance.query(
      _tableName,
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  // Read by month
  Future<List<TransactionModel>> getTransactionsByMonth(
      int month, int year) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    return getTransactionsByDateRange(start, end);
  }

  // Read by type
  Future<List<TransactionModel>> getTransactionsByType(
    TransactionType type, {
    DateTime? start,
    DateTime? end,
  }) async {
    String where = 'type = ?';
    List<dynamic> whereArgs = [type.name];

    if (start != null && end != null) {
      where += ' AND date >= ? AND date <= ?';
      whereArgs.addAll(
          [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
    }

    final maps = await DatabaseService.instance.query(
      _tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  // Update
  Future<int> updateTransaction(TransactionModel transaction) async {
    final map = transaction.copyWith(updatedAt: DateTime.now()).toMap();
    return await DatabaseService.instance.update(
      _tableName,
      map,
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Delete
  Future<bool> deleteTransaction(int id) async {
    final count = await DatabaseService.instance.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // Delete multiple
  Future<int> deleteTransactions(List<int> ids) async {
    if (ids.isEmpty) return 0;
    final placeholders = List.filled(ids.length, '?').join(',');
    return await DatabaseService.instance.delete(
      _tableName,
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  // Get total income for period
  Future<double> getTotalIncome({DateTime? start, DateTime? end}) async {
    String where = 'type = ?';
    List<dynamic> whereArgs = [TransactionType.income.name];

    if (start != null && end != null) {
      where += ' AND date >= ? AND date <= ?';
      whereArgs.addAll(
          [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
    }

    final result = await DatabaseService.instance.rawQuery(
      'SELECT SUM(amount) as total FROM $_tableName WHERE $where',
      whereArgs,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get total expense for period
  Future<double> getTotalExpense({DateTime? start, DateTime? end}) async {
    String where = 'type = ?';
    List<dynamic> whereArgs = [TransactionType.expense.name];

    if (start != null && end != null) {
      where += ' AND date >= ? AND date <= ?';
      whereArgs.addAll(
          [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
    }

    final result = await DatabaseService.instance.rawQuery(
      'SELECT SUM(amount) as total FROM $_tableName WHERE $where',
      whereArgs,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get transactions count
  Future<int> getTransactionsCount() async {
    final result = await DatabaseService.instance.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  // Get unsynced transactions (for Google Sheets sync)
  Future<List<TransactionModel>> getUnsyncedTransactions() async {
    final maps = await DatabaseService.instance.query(
      _tableName,
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  // Mark as synced
  Future<void> markAsSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    final placeholders = List.filled(ids.length, '?').join(',');
    await DatabaseService.instance.rawUpdate(
      'UPDATE $_tableName SET isSynced = 1, syncedAt = ? WHERE id IN ($placeholders)',
      [DateTime.now().millisecondsSinceEpoch, ...ids],
    );
  }

  // Stream-like fetch for current month (polling-based for SQLite)
  Stream<List<TransactionModel>> watchTransactions() async* {
    while (true) {
      yield await getAllTransactions();
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Stream<List<TransactionModel>> watchTransactionsForMonth(
      int month, int year) async* {
    while (true) {
      yield await getTransactionsByMonth(month, year);
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}
