import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/custom_category_model.dart';
import '../../data/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final allCategoriesProvider = StreamProvider<List<CustomCategoryModel>>((ref) async* {
  final repository = ref.watch(categoryRepositoryProvider);
  
  // Initial load
  yield await repository.getAllCategories();
  
  // Listen to changes
  while (true) {
    await Future.delayed(const Duration(seconds: 2));
    yield await repository.getAllCategories();
  }
});

final expenseCategoriesProvider = FutureProvider<List<CustomCategoryModel>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getCategoriesByType(CategoryType.expense);
});

final incomeCategoriesProvider = FutureProvider<List<CustomCategoryModel>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getCategoriesByType(CategoryType.income);
});

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoryNotifier(repository, ref);
});

class CategoryNotifier extends StateNotifier<AsyncValue<void>> {
  final CategoryRepository _repository;
  final Ref _ref;

  CategoryNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> addCategory(CustomCategoryModel category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addCategory(category);
      _ref.invalidate(allCategoriesProvider);
      _ref.invalidate(expenseCategoriesProvider);
      _ref.invalidate(incomeCategoriesProvider);
    });
  }

  Future<void> updateCategory(CustomCategoryModel category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateCategory(category);
      _ref.invalidate(allCategoriesProvider);
      _ref.invalidate(expenseCategoriesProvider);
      _ref.invalidate(incomeCategoriesProvider);
    });
  }

  Future<void> deleteCategory(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteCategory(id);
      _ref.invalidate(allCategoriesProvider);
      _ref.invalidate(expenseCategoriesProvider);
      _ref.invalidate(incomeCategoriesProvider);
    });
  }

  Future<void> reorderCategories(List<int> categoryIds) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.reorderCategories(categoryIds);
      _ref.invalidate(allCategoriesProvider);
    });
  }
}
