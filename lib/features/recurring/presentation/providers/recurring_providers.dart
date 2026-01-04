// lib/features/recurring/presentation/providers/recurring_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/recurring_repository.dart';
import '../../data/models/recurring_transaction_model.dart';
import '../../../../core/enums/transaction_type.dart';

// Repository provider
final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  return RecurringRepository();
});

// All recurring transactions
final allRecurringProvider = FutureProvider<List<RecurringTransactionModel>>((ref) async {
  final repository = ref.watch(recurringRepositoryProvider);
  return repository.getAll();
});

// Active recurring transactions
final activeRecurringProvider = FutureProvider<List<RecurringTransactionModel>>((ref) async {
  final repository = ref.watch(recurringRepositoryProvider);
  return repository.getActive();
});

// Due recurring transactions
final dueRecurringProvider = FutureProvider<List<RecurringTransactionModel>>((ref) async {
  final repository = ref.watch(recurringRepositoryProvider);
  return repository.getDue();
});

// Upcoming recurring transactions
final upcomingRecurringProvider = FutureProvider.family<List<RecurringTransactionModel>, int>((ref, days) async {
  final repository = ref.watch(recurringRepositoryProvider);
  return repository.getUpcoming(days: days);
});

// Recurring by type
final recurringByTypeProvider = FutureProvider.family<List<RecurringTransactionModel>, TransactionType>((ref, type) async {
  final repository = ref.watch(recurringRepositoryProvider);
  return repository.getByType(type);
});

// Monthly income from recurring
final monthlyRecurringIncomeProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(recurringRepositoryProvider);
  return repository.getMonthlyTotal(TransactionType.income);
});

// Monthly expense from recurring
final monthlyRecurringExpenseProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(recurringRepositoryProvider);
  return repository.getMonthlyTotal(TransactionType.expense);
});

// State notifier for recurring management
class RecurringNotifier extends StateNotifier<AsyncValue<List<RecurringTransactionModel>>> {
  final RecurringRepository _repository;

  RecurringNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadRecurring();
  }

  Future<void> loadRecurring() async {
    state = const AsyncValue.loading();
    try {
      final recurring = await _repository.getAll();
      state = AsyncValue.data(recurring);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRecurring(RecurringTransactionModel recurring) async {
    try {
      await _repository.insert(recurring);
      await loadRecurring();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateRecurring(RecurringTransactionModel recurring) async {
    try {
      await _repository.update(recurring);
      await loadRecurring();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteRecurring(int id) async {
    try {
      await _repository.delete(id);
      await loadRecurring();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleActive(int id, bool isActive) async {
    try {
      await _repository.toggleActive(id, isActive);
      await loadRecurring();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> processAllDue() async {
    try {
      final count = await _repository.processAllDue();
      await loadRecurring();
      return count;
    } catch (e) {
      rethrow;
    }
  }
}

final recurringNotifierProvider = StateNotifierProvider<RecurringNotifier, AsyncValue<List<RecurringTransactionModel>>>((ref) {
  final repository = ref.watch(recurringRepositoryProvider);
  return RecurringNotifier(repository);
});
