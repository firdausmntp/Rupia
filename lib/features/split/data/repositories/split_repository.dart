// lib/features/split/data/repositories/split_repository.dart

import '../../../../core/services/database_service.dart';
import '../models/split_transaction_model.dart';

class SplitRepository {
  static const String _splitsTable = 'split_transactions';
  static const String _itemsTable = 'split_items';

  /// Get all split transactions
  Future<List<SplitTransactionModel>> getAll() async {
    final results = await DatabaseService.query(
      _splitsTable,
      orderBy: 'date DESC',
    );
    
    final splits = <SplitTransactionModel>[];
    for (final map in results) {
      final items = await getItemsBySplitId(map['id'] as int);
      splits.add(SplitTransactionModel.fromMap(map, items: items));
    }
    
    return splits;
  }

  /// Get split transaction by ID
  Future<SplitTransactionModel?> getById(int id) async {
    final results = await DatabaseService.query(
      _splitsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (results.isEmpty) return null;
    
    final items = await getItemsBySplitId(id);
    return SplitTransactionModel.fromMap(results.first, items: items);
  }

  /// Get items by split transaction ID
  Future<List<SplitItemModel>> getItemsBySplitId(int splitId) async {
    final results = await DatabaseService.query(
      _itemsTable,
      where: 'split_transaction_id = ?',
      whereArgs: [splitId],
      orderBy: 'id ASC',
    );
    return results.map((map) => SplitItemModel.fromMap(map)).toList();
  }

  /// Get pending split transactions (not fully paid)
  Future<List<SplitTransactionModel>> getPending() async {
    final all = await getAll();
    return all.where((split) => !split.isFullyPaid).toList();
  }

  /// Get recent split transactions
  Future<List<SplitTransactionModel>> getRecent({int limit = 10}) async {
    final results = await DatabaseService.query(
      _splitsTable,
      orderBy: 'date DESC',
      limit: limit,
    );
    
    final splits = <SplitTransactionModel>[];
    for (final map in results) {
      final items = await getItemsBySplitId(map['id'] as int);
      splits.add(SplitTransactionModel.fromMap(map, items: items));
    }
    
    return splits;
  }

  /// Insert split transaction with items
  Future<int> insert(SplitTransactionModel split) async {
    final splitMap = split.toMap();
    splitMap.remove('id');
    
    final splitId = await DatabaseService.insert(_splitsTable, splitMap);
    
    // Insert items
    for (final item in split.items) {
      final itemMap = item.copyWith(splitTransactionId: splitId).toMap();
      itemMap.remove('id');
      await DatabaseService.insert(_itemsTable, itemMap);
    }
    
    return splitId;
  }

  /// Update split transaction
  Future<int> update(SplitTransactionModel split) async {
    if (split.id == null) {
      throw Exception('Cannot update split transaction without ID');
    }
    
    final splitMap = split.toMap();
    splitMap['updated_at'] = DateTime.now().toIso8601String();
    
    return await DatabaseService.update(
      _splitsTable,
      splitMap,
      where: 'id = ?',
      whereArgs: [split.id],
    );
  }

  /// Delete split transaction and its items
  Future<int> delete(int id) async {
    // Delete items first
    await DatabaseService.delete(
      _itemsTable,
      where: 'split_transaction_id = ?',
      whereArgs: [id],
    );
    
    // Delete split
    return await DatabaseService.delete(
      _splitsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Insert split item
  Future<int> insertItem(SplitItemModel item) async {
    final map = item.toMap();
    map.remove('id');
    return await DatabaseService.insert(_itemsTable, map);
  }

  /// Update split item
  Future<int> updateItem(SplitItemModel item) async {
    if (item.id == null) {
      throw Exception('Cannot update split item without ID');
    }
    
    return await DatabaseService.update(
      _itemsTable,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Delete split item
  Future<int> deleteItem(int itemId) async {
    return await DatabaseService.delete(
      _itemsTable,
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  /// Mark item as paid
  Future<int> markItemAsPaid(int itemId) async {
    return await DatabaseService.update(
      _itemsTable,
      {
        'status': SplitPaymentStatus.paid.name,
        'paid_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  /// Mark item as pending
  Future<int> markItemAsPending(int itemId) async {
    return await DatabaseService.update(
      _itemsTable,
      {
        'status': SplitPaymentStatus.pending.name,
        'paid_at': null,
      },
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  /// Get total owed to user (from pending items)
  Future<double> getTotalOwed() async {
    final results = await DatabaseService.rawQuery('''
      SELECT SUM(si.amount) as total
      FROM $_itemsTable si
      WHERE si.status = ?
    ''', [SplitPaymentStatus.pending.name]);
    
    if (results.isEmpty || results.first['total'] == null) return 0;
    return (results.first['total'] as num).toDouble();
  }

  /// Get splits by participant name
  Future<List<SplitTransactionModel>> getByParticipant(String participantName) async {
    final itemResults = await DatabaseService.query(
      _itemsTable,
      where: 'participant_name LIKE ?',
      whereArgs: ['%$participantName%'],
    );
    
    final splitIds = itemResults
        .map((map) => map['split_transaction_id'] as int)
        .toSet()
        .toList();
    
    final splits = <SplitTransactionModel>[];
    for (final id in splitIds) {
      final split = await getById(id);
      if (split != null) {
        splits.add(split);
      }
    }
    
    return splits;
  }

  /// Get split statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final all = await getAll();
    
    double totalAmount = 0;
    double totalPaid = 0;
    double totalPending = 0;
    int totalSplits = all.length;
    int completedSplits = 0;
    
    for (final split in all) {
      totalAmount += split.totalAmount;
      totalPaid += split.totalPaid;
      totalPending += split.totalPending;
      if (split.isFullyPaid) completedSplits++;
    }
    
    return {
      'totalSplits': totalSplits,
      'completedSplits': completedSplits,
      'pendingSplits': totalSplits - completedSplits,
      'totalAmount': totalAmount,
      'totalPaid': totalPaid,
      'totalPending': totalPending,
      'completionRate': totalSplits > 0 ? (completedSplits / totalSplits * 100) : 0,
    };
  }
}
