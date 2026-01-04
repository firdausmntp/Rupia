import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction_model.dart';
import '../../../../core/enums/transaction_type.dart';

// Repository provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// All transactions stream
final transactionsStreamProvider = StreamProvider<List<TransactionModel>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchTransactions();
});

// Current month transactions stream
final currentMonthTransactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  final now = DateTime.now();
  return repository.watchTransactionsForMonth(now.month, now.year);
});

// Selected month state
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Selected month transactions
final selectedMonthTransactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  return repository.watchTransactionsForMonth(selectedMonth.month, selectedMonth.year);
});

// Dashboard summary
class DashboardSummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionCount;
  
  DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
  });
}

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  
  final income = await repository.getTotalIncome(start: start, end: end);
  final expense = await repository.getTotalExpense(start: start, end: end);
  final transactions = await repository.getTransactionsByMonth(now.month, now.year);
  
  return DashboardSummary(
    totalIncome: income,
    totalExpense: expense,
    balance: income - expense,
    transactionCount: transactions.length,
  );
});

// Category-wise expense
final categoryExpenseProvider = FutureProvider<Map<String, double>>((ref) async {
  final transactions = await ref.watch(currentMonthTransactionsProvider.future);
  
  final Map<String, double> categoryExpense = {};
  
  for (final transaction in transactions) {
    if (transaction.type == TransactionType.expense) {
      final category = transaction.category.displayName;
      categoryExpense[category] = (categoryExpense[category] ?? 0) + transaction.amount;
    }
  }
  
  return categoryExpense;
});

// Transaction actions notifier
class TransactionActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final TransactionRepository _repository;
  
  TransactionActionsNotifier(this._repository) : super(const AsyncValue.data(null));
  
  Future<int?> addTransaction(TransactionModel transaction) async {
    state = const AsyncValue.loading();
    try {
      final id = await _repository.addTransaction(transaction);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
  
  Future<bool> updateTransaction(TransactionModel transaction) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateTransaction(transaction);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
  
  Future<bool> deleteTransaction(int id) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.deleteTransaction(id);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final transactionActionsProvider = StateNotifierProvider<TransactionActionsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionActionsNotifier(repository);
});

// Single transaction provider
final transactionByIdProvider = FutureProvider.family<TransactionModel?, int>((ref, id) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getTransactionById(id);
});
