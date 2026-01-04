// lib/features/debt/presentation/providers/debt_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/debt_model.dart';
import '../../data/repositories/debt_repository.dart';

// Repository Provider
final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepository();
});

// All Debts Provider
final allDebtsProvider = FutureProvider<List<DebtModel>>((ref) async {
  final repo = ref.watch(debtRepositoryProvider);
  return await repo.getAllDebts();
});

// My Debts (I Owe) Provider
final myDebtsProvider = FutureProvider<List<DebtModel>>((ref) async {
  final repo = ref.watch(debtRepositoryProvider);
  return await repo.getDebtsByType(DebtType.iOwe);
});

// Receivables (Owed to Me) Provider
final receivablesProvider = FutureProvider<List<DebtModel>>((ref) async {
  final repo = ref.watch(debtRepositoryProvider);
  return await repo.getDebtsByType(DebtType.owedToMe);
});

// Pending Debts Provider
final pendingDebtsProvider = FutureProvider<List<DebtModel>>((ref) async {
  final repo = ref.watch(debtRepositoryProvider);
  return await repo.getPendingDebts();
});

// Overdue Debts Provider
final overdueDebtsProvider = FutureProvider<List<DebtModel>>((ref) async {
  final repo = ref.watch(debtRepositoryProvider);
  return await repo.getOverdueDebts();
});

// Total Debt Provider
final totalDebtProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(debtRepositoryProvider);
  return await repo.getTotalDebt();
});

// Total Receivable Provider
final totalReceivableProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(debtRepositoryProvider);
  return await repo.getTotalReceivable();
});

// Debts Due Soon Provider
final debtsDueSoonProvider = FutureProvider<List<DebtModel>>((ref) async {
  final repo = ref.watch(debtRepositoryProvider);
  return await repo.getDebtsDueSoon();
});

// Debt Notifier for mutations
class DebtNotifier extends StateNotifier<AsyncValue<void>> {
  final DebtRepository _repository;
  final Ref _ref;
  
  DebtNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));
  
  Future<void> addDebt(DebtModel debt) async {
    state = const AsyncValue.loading();
    try {
      await _repository.insertDebt(debt);
      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> updateDebt(DebtModel debt) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateDebt(debt);
      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> deleteDebt(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteDebt(id);
      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> addPayment(int debtId, double amount) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addPayment(debtId, amount);
      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> markAsPaid(int debtId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markAsPaid(debtId);
      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  void _invalidateProviders() {
    _ref.invalidate(allDebtsProvider);
    _ref.invalidate(myDebtsProvider);
    _ref.invalidate(receivablesProvider);
    _ref.invalidate(pendingDebtsProvider);
    _ref.invalidate(overdueDebtsProvider);
    _ref.invalidate(totalDebtProvider);
    _ref.invalidate(totalReceivableProvider);
    _ref.invalidate(debtsDueSoonProvider);
  }
}

final debtNotifierProvider = StateNotifierProvider<DebtNotifier, AsyncValue<void>>((ref) {
  return DebtNotifier(ref.watch(debtRepositoryProvider), ref);
});
