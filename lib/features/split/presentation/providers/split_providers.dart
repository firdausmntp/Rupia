// lib/features/split/presentation/providers/split_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/split_repository.dart';
import '../../data/models/split_transaction_model.dart';

// Repository provider
final splitRepositoryProvider = Provider<SplitRepository>((ref) {
  return SplitRepository();
});

// All split transactions
final allSplitsProvider = FutureProvider<List<SplitTransactionModel>>((ref) async {
  final repository = ref.watch(splitRepositoryProvider);
  return repository.getAll();
});

// Pending splits
final pendingSplitsProvider = FutureProvider<List<SplitTransactionModel>>((ref) async {
  final repository = ref.watch(splitRepositoryProvider);
  return repository.getPending();
});

// Recent splits
final recentSplitsProvider = FutureProvider.family<List<SplitTransactionModel>, int>((ref, limit) async {
  final repository = ref.watch(splitRepositoryProvider);
  return repository.getRecent(limit: limit);
});

// Split by ID
final splitByIdProvider = FutureProvider.family<SplitTransactionModel?, int>((ref, id) async {
  final repository = ref.watch(splitRepositoryProvider);
  return repository.getById(id);
});

// Total owed
final totalOwedProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(splitRepositoryProvider);
  return repository.getTotalOwed();
});

// Split statistics
final splitStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(splitRepositoryProvider);
  return repository.getStatistics();
});

// State notifier for split management
class SplitNotifier extends StateNotifier<AsyncValue<List<SplitTransactionModel>>> {
  final SplitRepository _repository;

  SplitNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSplits();
  }

  Future<void> loadSplits() async {
    state = const AsyncValue.loading();
    try {
      final splits = await _repository.getAll();
      state = AsyncValue.data(splits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> addSplit(SplitTransactionModel split) async {
    try {
      final id = await _repository.insert(split);
      await loadSplits();
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSplit(SplitTransactionModel split) async {
    try {
      await _repository.update(split);
      await loadSplits();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSplit(int id) async {
    try {
      await _repository.delete(id);
      await loadSplits();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markItemAsPaid(int itemId) async {
    try {
      await _repository.markItemAsPaid(itemId);
      await loadSplits();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markItemAsPending(int itemId) async {
    try {
      await _repository.markItemAsPending(itemId);
      await loadSplits();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem(SplitItemModel item) async {
    try {
      await _repository.insertItem(item);
      await loadSplits();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteItem(int itemId) async {
    try {
      await _repository.deleteItem(itemId);
      await loadSplits();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final splitNotifierProvider = StateNotifierProvider<SplitNotifier, AsyncValue<List<SplitTransactionModel>>>((ref) {
  final repository = ref.watch(splitRepositoryProvider);
  return SplitNotifier(repository);
});
