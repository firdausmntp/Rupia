// lib/features/bills/data/repositories/bill_repository.dart

import '../../../../core/services/database_service.dart';
import '../../../../core/enums/bill_status.dart';
import '../models/bill_model.dart';

class BillRepository {
  static const String _tableName = 'bills';

  /// Get all bills
  Future<List<BillModel>> getAll() async {
    final results = await DatabaseService.query(
      _tableName,
      orderBy: 'due_date ASC',
    );
    return results.map((map) => BillModel.fromMap(map)).toList();
  }

  /// Get bill by ID
  Future<BillModel?> getById(int id) async {
    final results = await DatabaseService.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return BillModel.fromMap(results.first);
  }

  /// Get pending bills (not paid or cancelled)
  Future<List<BillModel>> getPending() async {
    final results = await DatabaseService.query(
      _tableName,
      where: 'status IN (?, ?)',
      whereArgs: [BillStatus.pending.name, BillStatus.overdue.name],
      orderBy: 'due_date ASC',
    );
    return results.map((map) => BillModel.fromMap(map)).toList();
  }

  /// Get overdue bills
  Future<List<BillModel>> getOverdue() async {
    final now = DateTime.now().toIso8601String();
    final results = await DatabaseService.query(
      _tableName,
      where: 'due_date < ? AND status NOT IN (?, ?)',
      whereArgs: [now, BillStatus.paid.name, BillStatus.cancelled.name],
      orderBy: 'due_date ASC',
    );
    return results.map((map) => BillModel.fromMap(map)).toList();
  }

  /// Get upcoming bills (due within specified days)
  Future<List<BillModel>> getUpcoming({int days = 7}) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days)).toIso8601String();
    
    final results = await DatabaseService.query(
      _tableName,
      where: 'due_date <= ? AND due_date >= ? AND status NOT IN (?, ?)',
      whereArgs: [
        futureDate,
        now.toIso8601String(),
        BillStatus.paid.name,
        BillStatus.cancelled.name,
      ],
      orderBy: 'due_date ASC',
    );
    return results.map((map) => BillModel.fromMap(map)).toList();
  }

  /// Get bills due today
  Future<List<BillModel>> getDueToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    
    final results = await DatabaseService.query(
      _tableName,
      where: 'due_date >= ? AND due_date <= ? AND status NOT IN (?, ?)',
      whereArgs: [
        startOfDay,
        endOfDay,
        BillStatus.paid.name,
        BillStatus.cancelled.name,
      ],
      orderBy: 'due_date ASC',
    );
    return results.map((map) => BillModel.fromMap(map)).toList();
  }

  /// Get bills by category
  Future<List<BillModel>> getByCategory(BillCategory category) async {
    final results = await DatabaseService.query(
      _tableName,
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'due_date ASC',
    );
    return results.map((map) => BillModel.fromMap(map)).toList();
  }

  /// Get bills by status
  Future<List<BillModel>> getByStatus(BillStatus status) async {
    final results = await DatabaseService.query(
      _tableName,
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'due_date DESC',
    );
    return results.map((map) => BillModel.fromMap(map)).toList();
  }

  /// Get paid bills in date range
  Future<List<BillModel>> getPaidInRange(DateTime start, DateTime end) async {
    final results = await DatabaseService.query(
      _tableName,
      where: 'status = ? AND paid_date >= ? AND paid_date <= ?',
      whereArgs: [
        BillStatus.paid.name,
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: 'paid_date DESC',
    );
    return results.map((map) => BillModel.fromMap(map)).toList();
  }

  /// Insert bill
  Future<int> insert(BillModel bill) async {
    final map = bill.toMap();
    map.remove('id');
    return await DatabaseService.insert(_tableName, map);
  }

  /// Update bill
  Future<int> update(BillModel bill) async {
    if (bill.id == null) {
      throw Exception('Cannot update bill without ID');
    }
    
    final map = bill.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    
    return await DatabaseService.update(
      _tableName,
      map,
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  /// Delete bill
  Future<int> delete(int id) async {
    return await DatabaseService.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark bill as paid
  Future<int> markAsPaid(int id, {double? actualAmount, String? receiptPath}) async {
    final bill = await getById(id);
    if (bill == null) {
      throw Exception('Bill not found');
    }
    
    final updatedBill = bill.markAsPaid(
      actualAmount: actualAmount,
      receiptPath: receiptPath,
    );
    
    // If recurring, create next occurrence
    if (bill.isRecurring) {
      final nextBill = bill.createNextRecurrence();
      if (nextBill != null) {
        await insert(nextBill);
      }
    }
    
    return await update(updatedBill);
  }

  /// Mark bill as cancelled
  Future<int> markAsCancelled(int id) async {
    return await DatabaseService.update(
      _tableName,
      {
        'status': BillStatus.cancelled.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update overdue status for all pending bills
  Future<int> updateOverdueStatus() async {
    final now = DateTime.now().toIso8601String();
    
    return await DatabaseService.rawUpdate('''
      UPDATE $_tableName 
      SET status = ?, updated_at = ?
      WHERE due_date < ? AND status = ?
    ''', [
      BillStatus.overdue.name,
      DateTime.now().toIso8601String(),
      now,
      BillStatus.pending.name,
    ]);
  }

  /// Get bills needing reminder (due soon)
  Future<List<BillModel>> getBillsNeedingReminder() async {
    final now = DateTime.now();
    final results = await DatabaseService.query(
      _tableName,
      where: 'reminder_enabled = ? AND status NOT IN (?, ?)',
      whereArgs: [1, BillStatus.paid.name, BillStatus.cancelled.name],
      orderBy: 'due_date ASC',
    );
    
    final bills = results.map((map) => BillModel.fromMap(map)).toList();
    
    // Filter bills that are within their reminder period
    return bills.where((bill) {
      final reminderDate = bill.dueDate.subtract(Duration(days: bill.reminderDaysBefore));
      return now.isAfter(reminderDate) || now.isAtSameMomentAs(reminderDate);
    }).toList();
  }

  /// Get total pending amount
  Future<double> getTotalPending() async {
    final results = await DatabaseService.rawQuery('''
      SELECT SUM(amount) as total
      FROM $_tableName
      WHERE status IN (?, ?)
    ''', [BillStatus.pending.name, BillStatus.overdue.name]);
    
    if (results.isEmpty || results.first['total'] == null) return 0;
    return (results.first['total'] as num).toDouble();
  }

  /// Get monthly bill summary
  Future<Map<String, dynamic>> getMonthlySummary(int month, int year) async {
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();
    
    final results = await DatabaseService.rawQuery('''
      SELECT 
        COUNT(*) as total_bills,
        SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) as paid_count,
        SUM(CASE WHEN status IN (?, ?) THEN 1 ELSE 0 END) as pending_count,
        SUM(CASE WHEN status = ? THEN paid_amount ELSE 0 END) as total_paid,
        SUM(CASE WHEN status IN (?, ?) THEN amount ELSE 0 END) as total_pending
      FROM $_tableName
      WHERE due_date >= ? AND due_date <= ?
    ''', [
      BillStatus.paid.name,
      BillStatus.pending.name,
      BillStatus.overdue.name,
      BillStatus.paid.name,
      BillStatus.pending.name,
      BillStatus.overdue.name,
      startDate,
      endDate,
    ]);
    
    if (results.isEmpty) {
      return {
        'totalBills': 0,
        'paidCount': 0,
        'pendingCount': 0,
        'totalPaid': 0.0,
        'totalPending': 0.0,
      };
    }
    
    final row = results.first;
    return {
      'totalBills': row['total_bills'] ?? 0,
      'paidCount': row['paid_count'] ?? 0,
      'pendingCount': row['pending_count'] ?? 0,
      'totalPaid': (row['total_paid'] as num?)?.toDouble() ?? 0.0,
      'totalPending': (row['total_pending'] as num?)?.toDouble() ?? 0.0,
    };
  }

  /// Get bills grouped by category with totals
  Future<Map<BillCategory, double>> getTotalsByCategory() async {
    final results = await DatabaseService.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM $_tableName
      WHERE status IN (?, ?)
      GROUP BY category
    ''', [BillStatus.pending.name, BillStatus.overdue.name]);
    
    final totals = <BillCategory, double>{};
    for (final row in results) {
      final category = BillCategory.values.firstWhere(
        (c) => c.name == row['category'],
        orElse: () => BillCategory.other,
      );
      totals[category] = (row['total'] as num).toDouble();
    }
    
    return totals;
  }
}
