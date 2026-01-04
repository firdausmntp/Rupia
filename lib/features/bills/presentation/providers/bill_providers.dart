// lib/features/bills/presentation/providers/bill_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/bill_repository.dart';
import '../../data/models/bill_model.dart';
import '../../../../core/enums/bill_status.dart';

// Repository provider
final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository();
});

// All bills
final allBillsProvider = FutureProvider<List<BillModel>>((ref) async {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getAll();
});

// Pending bills
final pendingBillsProvider = FutureProvider<List<BillModel>>((ref) async {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getPending();
});

// Overdue bills
final overdueBillsProvider = FutureProvider<List<BillModel>>((ref) async {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getOverdue();
});

// Upcoming bills
final upcomingBillsProvider = FutureProvider.family<List<BillModel>, int>((ref, days) async {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getUpcoming(days: days);
});

// Bills due today
final billsDueTodayProvider = FutureProvider<List<BillModel>>((ref) async {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getDueToday();
});

// Bills by category
final billsByCategoryProvider = FutureProvider.family<List<BillModel>, BillCategory>((ref, category) async {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getByCategory(category);
});

// Bills by status
final billsByStatusProvider = FutureProvider.family<List<BillModel>, BillStatus>((ref, status) async {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getByStatus(status);
});

// Total pending amount
final totalPendingBillsProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getTotalPending();
});

// Alias for UI usage
final pendingBillsTotalProvider = totalPendingBillsProvider;

// Overdue bills count
final overdueBillsCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(billRepositoryProvider);
  final overdueBills = await repository.getOverdue();
  return overdueBills.length;
});

// Monthly summary
final billMonthlySummaryProvider = FutureProvider.family<Map<String, dynamic>, ({int month, int year})>((ref, params) async {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getMonthlySummary(params.month, params.year);
});

// Bills needing reminder
final billsNeedingReminderProvider = FutureProvider<List<BillModel>>((ref) async {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getBillsNeedingReminder();
});

// Totals by category
final billTotalsByCategoryProvider = FutureProvider<Map<BillCategory, double>>((ref) async {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getTotalsByCategory();
});

// State notifier for bill management
class BillNotifier extends StateNotifier<AsyncValue<List<BillModel>>> {
  final BillRepository _repository;

  BillNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadBills();
  }

  Future<void> loadBills() async {
    state = const AsyncValue.loading();
    try {
      // Update overdue status first
      await _repository.updateOverdueStatus();
      final bills = await _repository.getAll();
      state = AsyncValue.data(bills);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> addBill(BillModel bill) async {
    try {
      final id = await _repository.insert(bill);
      await loadBills();
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBill(BillModel bill) async {
    try {
      await _repository.update(bill);
      await loadBills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteBill(int id) async {
    try {
      await _repository.delete(id);
      await loadBills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsPaid(int id, {double? actualAmount, String? receiptPath}) async {
    try {
      await _repository.markAsPaid(id, actualAmount: actualAmount, receiptPath: receiptPath);
      await loadBills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsCancelled(int id) async {
    try {
      await _repository.markAsCancelled(id);
      await loadBills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<List<BillModel>> getBillsNeedingReminder() async {
    return _repository.getBillsNeedingReminder();
  }
}

final billNotifierProvider = StateNotifierProvider<BillNotifier, AsyncValue<List<BillModel>>>((ref) {
  final repository = ref.watch(billRepositoryProvider);
  return BillNotifier(repository);
});

// Bill count badge provider (for showing pending/overdue count)
final billBadgeCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(billRepositoryProvider);
  final pending = await repository.getPending();
  final overdue = await repository.getOverdue();
  return pending.length + overdue.length;
});
