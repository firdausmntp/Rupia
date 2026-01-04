import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/models/budget_model.dart';

// Repository provider
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

// Selected month for budget view
final budgetSelectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Budgets for selected month
final budgetsForMonthProvider = StreamProvider<List<BudgetModel>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  final selectedMonth = ref.watch(budgetSelectedMonthProvider);
  return repository.watchBudgets(selectedMonth.month, selectedMonth.year);
});

// Current month budgets
final currentMonthBudgetsProvider = StreamProvider<List<BudgetModel>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  final now = DateTime.now();
  return repository.watchBudgets(now.month, now.year);
});

// Budget summary
class BudgetSummary {
  final double totalBudget;
  final double totalSpent;
  final double remaining;
  final double percentUsed;
  final int budgetCount;
  final int overBudgetCount;

  BudgetSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
    required this.percentUsed,
    required this.budgetCount,
    required this.overBudgetCount,
  });
}

final budgetSummaryProvider = FutureProvider<BudgetSummary>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  final now = DateTime.now();

  final totalBudget = await repository.getTotalBudget(now.month, now.year);
  final totalSpent = await repository.getTotalSpent(now.month, now.year);
  final budgets = await repository.getBudgetsByMonth(now.month, now.year);

  return BudgetSummary(
    totalBudget: totalBudget,
    totalSpent: totalSpent,
    remaining: totalBudget - totalSpent,
    percentUsed: totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0,
    budgetCount: budgets.length,
    overBudgetCount: budgets.where((b) => b.isOverBudget).length,
  );
});

// Budget actions notifier
class BudgetActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final BudgetRepository _repository;

  BudgetActionsNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<int?> addBudget(BudgetModel budget) async {
    state = const AsyncValue.loading();
    try {
      final id = await _repository.addBudget(budget);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> updateBudget(BudgetModel budget) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateBudget(budget);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteBudget(int id) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.deleteBudget(id);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> updateSpent(int id, double spent) async {
    try {
      await _repository.updateSpentAmount(id, spent);
    } catch (e) {
      // Silent fail for spent updates
    }
  }

  Future<void> copyFromPreviousMonth() async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      await _repository.copyBudgetsFromPreviousMonth(now.month, now.year);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final budgetActionsProvider =
    StateNotifierProvider<BudgetActionsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return BudgetActionsNotifier(repository);
});

// Single budget by ID
final budgetByIdProvider =
    FutureProvider.family<BudgetModel?, int>((ref, id) async {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.getBudgetById(id);
});
