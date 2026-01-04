// lib/features/debt/data/repositories/debt_repository.dart

import 'package:sqflite/sqflite.dart';
import '../../../../core/services/database_service.dart';
import '../models/debt_model.dart';

class DebtRepository {
  static const String tableName = 'debts';
  
  Future<Database> get _db async => DatabaseService.database;
  
  // Create table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type INTEGER NOT NULL,
        personName TEXT NOT NULL,
        amount REAL NOT NULL,
        paidAmount REAL DEFAULT 0,
        createdAt TEXT NOT NULL,
        dueDate TEXT,
        note TEXT,
        status INTEGER DEFAULT 0,
        personPhone TEXT
      )
    ''');
  }
  
  // Get all debts
  Future<List<DebtModel>> getAllDebts() async {
    final db = await _db;
    final maps = await db.query(tableName, orderBy: 'createdAt DESC');
    return maps.map((map) => DebtModel.fromMap(map)).toList();
  }
  
  // Get debts by type
  Future<List<DebtModel>> getDebtsByType(DebtType type) async {
    final db = await _db;
    final maps = await db.query(
      tableName,
      where: 'type = ?',
      whereArgs: [type.index],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => DebtModel.fromMap(map)).toList();
  }
  
  // Get pending debts
  Future<List<DebtModel>> getPendingDebts() async {
    final db = await _db;
    final maps = await db.query(
      tableName,
      where: 'status != ?',
      whereArgs: [DebtStatus.paid.index],
      orderBy: 'dueDate ASC',
    );
    return maps.map((map) => DebtModel.fromMap(map)).toList();
  }
  
  // Get overdue debts
  Future<List<DebtModel>> getOverdueDebts() async {
    final debts = await getPendingDebts();
    return debts.where((d) => d.isOverdue).toList();
  }
  
  // Get debt by ID
  Future<DebtModel?> getDebtById(int id) async {
    final db = await _db;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DebtModel.fromMap(maps.first);
  }
  
  // Insert debt
  Future<int> insertDebt(DebtModel debt) async {
    final db = await _db;
    return await db.insert(tableName, debt.toMap()..remove('id'));
  }
  
  // Update debt
  Future<int> updateDebt(DebtModel debt) async {
    final db = await _db;
    return await db.update(
      tableName,
      debt.toMap(),
      where: 'id = ?',
      whereArgs: [debt.id],
    );
  }
  
  // Delete debt
  Future<int> deleteDebt(int id) async {
    final db = await _db;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Add payment to debt
  Future<void> addPayment(int debtId, double paymentAmount) async {
    final debt = await getDebtById(debtId);
    if (debt == null) return;
    
    final newPaidAmount = debt.paidAmount + paymentAmount;
    DebtStatus newStatus;
    
    if (newPaidAmount >= debt.amount) {
      newStatus = DebtStatus.paid;
    } else if (newPaidAmount > 0) {
      newStatus = DebtStatus.partial;
    } else {
      newStatus = DebtStatus.pending;
    }
    
    await updateDebt(debt.copyWith(
      paidAmount: newPaidAmount,
      status: newStatus,
    ));
  }
  
  // Mark debt as paid
  Future<void> markAsPaid(int debtId) async {
    final debt = await getDebtById(debtId);
    if (debt == null) return;
    
    await updateDebt(debt.copyWith(
      paidAmount: debt.amount,
      status: DebtStatus.paid,
    ));
  }
  
  // Get total debt (I owe)
  Future<double> getTotalDebt() async {
    final debts = await getDebtsByType(DebtType.iOwe);
    double total = 0;
    for (var debt in debts) {
      if (debt.status != DebtStatus.paid) {
        total += debt.remainingAmount;
      }
    }
    return total;
  }
  
  // Get total receivable (owed to me)
  Future<double> getTotalReceivable() async {
    final debts = await getDebtsByType(DebtType.owedToMe);
    double total = 0;
    for (var debt in debts) {
      if (debt.status != DebtStatus.paid) {
        total += debt.remainingAmount;
      }
    }
    return total;
  }
  
  // Get debts due soon (within 7 days)
  Future<List<DebtModel>> getDebtsDueSoon() async {
    final debts = await getPendingDebts();
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    
    return debts.where((d) {
      if (d.dueDate == null) return false;
      return d.dueDate!.isAfter(now) && d.dueDate!.isBefore(weekFromNow);
    }).toList();
  }
}
