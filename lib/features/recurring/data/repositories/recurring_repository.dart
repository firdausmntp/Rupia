// lib/features/recurring/data/repositories/recurring_repository.dart

import '../../../../core/services/database_service.dart';
import '../models/recurring_transaction_model.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../../core/enums/transaction_type.dart';

class RecurringRepository {
  static const String _tableName = 'recurring_transactions';

  /// Get all recurring transactions
  Future<List<RecurringTransactionModel>> getAll() async {
    final results = await DatabaseService.query(
      _tableName,
      orderBy: 'next_due_date ASC',
    );
    return results.map((map) => RecurringTransactionModel.fromMap(map)).toList();
  }

  /// Get all active recurring transactions
  Future<List<RecurringTransactionModel>> getActive() async {
    final results = await DatabaseService.query(
      _tableName,
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'next_due_date ASC',
    );
    return results.map((map) => RecurringTransactionModel.fromMap(map)).toList();
  }

  /// Get recurring transaction by ID
  Future<RecurringTransactionModel?> getById(int id) async {
    final results = await DatabaseService.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return RecurringTransactionModel.fromMap(results.first);
  }

  /// Get due recurring transactions (need to be processed)
  Future<List<RecurringTransactionModel>> getDue() async {
    final now = DateTime.now().toIso8601String();
    final results = await DatabaseService.query(
      _tableName,
      where: 'is_active = ? AND next_due_date <= ? AND (end_date IS NULL OR end_date >= ?)',
      whereArgs: [1, now, now],
      orderBy: 'next_due_date ASC',
    );
    return results.map((map) => RecurringTransactionModel.fromMap(map)).toList();
  }

  /// Get upcoming recurring transactions
  Future<List<RecurringTransactionModel>> getUpcoming({int days = 7}) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days)).toIso8601String();
    
    final results = await DatabaseService.query(
      _tableName,
      where: 'is_active = ? AND next_due_date <= ? AND next_due_date >= ?',
      whereArgs: [1, futureDate, now.toIso8601String()],
      orderBy: 'next_due_date ASC',
    );
    return results.map((map) => RecurringTransactionModel.fromMap(map)).toList();
  }

  /// Insert new recurring transaction
  Future<int> insert(RecurringTransactionModel recurring) async {
    final map = recurring.toMap();
    map.remove('id');
    
    // Calculate initial next due date
    if (map['next_due_date'] == null) {
      map['next_due_date'] = recurring.startDate.toIso8601String();
    }
    
    return await DatabaseService.insert(_tableName, map);
  }

  /// Update recurring transaction
  Future<int> update(RecurringTransactionModel recurring) async {
    if (recurring.id == null) {
      throw Exception('Cannot update recurring transaction without ID');
    }
    
    final map = recurring.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    
    return await DatabaseService.update(
      _tableName,
      map,
      where: 'id = ?',
      whereArgs: [recurring.id],
    );
  }

  /// Delete recurring transaction
  Future<int> delete(int id) async {
    return await DatabaseService.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Toggle active status
  Future<int> toggleActive(int id, bool isActive) async {
    return await DatabaseService.update(
      _tableName,
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Process due recurring transaction and create actual transaction
  Future<void> processRecurring(RecurringTransactionModel recurring) async {
    if (recurring.id == null) return;

    // Create the actual transaction
    final transaction = TransactionModel(
      amount: recurring.amount,
      description: recurring.name,
      date: recurring.nextDueDate ?? DateTime.now(),
      type: recurring.type,
      category: recurring.category,
      note: '${recurring.note ?? ''}\n[Auto-generated from recurring: ${recurring.name}]'.trim(),
      createdAt: DateTime.now(),
    );

    // Insert transaction
    final transactionMap = transaction.toMap();
    transactionMap.remove('id');
    await DatabaseService.insert('transactions', transactionMap);

    // Update recurring: set last processed and calculate next due
    final nextDueDate = recurring.recurrence.getNextDate(recurring.nextDueDate ?? DateTime.now());
    
    await DatabaseService.update(
      _tableName,
      {
        'last_processed_date': DateTime.now().toIso8601String(),
        'next_due_date': nextDueDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [recurring.id],
    );
  }

  /// Process all due recurring transactions
  Future<int> processAllDue() async {
    final dueRecurrings = await getDue();
    int processed = 0;
    
    for (final recurring in dueRecurrings) {
      if (recurring.autoCreate) {
        await processRecurring(recurring);
        processed++;
      }
    }
    
    return processed;
  }

  /// Get recurring by type (income/expense)
  Future<List<RecurringTransactionModel>> getByType(TransactionType type) async {
    final results = await DatabaseService.query(
      _tableName,
      where: 'type = ? AND is_active = ?',
      whereArgs: [type.name, 1],
      orderBy: 'next_due_date ASC',
    );
    return results.map((map) => RecurringTransactionModel.fromMap(map)).toList();
  }

  /// Get total recurring amount by type per month
  Future<double> getMonthlyTotal(TransactionType type) async {
    final activeRecurrings = await getByType(type);
    double total = 0;

    for (final recurring in activeRecurrings) {
      // Normalize to monthly amount
      final monthlyAmount = recurring.amount * (30 / recurring.recurrence.intervalDays);
      total += monthlyAmount;
    }

    return total;
  }
}
