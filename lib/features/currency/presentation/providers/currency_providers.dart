// lib/features/currency/presentation/providers/currency_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/currency_repository.dart';
import '../../data/models/currency_model.dart';
import '../../../../core/enums/currency_code.dart';

// Repository provider
final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  return CurrencyRepository();
});

// All currencies
final allCurrenciesProvider = FutureProvider<List<CurrencyModel>>((ref) async {
  final repository = ref.watch(currencyRepositoryProvider);
  return repository.getAllCurrencies();
});

// Enabled currencies
final enabledCurrenciesProvider = FutureProvider<List<CurrencyModel>>((ref) async {
  final repository = ref.watch(currencyRepositoryProvider);
  return repository.getEnabledCurrencies();
});

// Base currency
final baseCurrencyProvider = FutureProvider<CurrencyModel>((ref) async {
  final repository = ref.watch(currencyRepositoryProvider);
  return repository.getBaseCurrency();
});

// User preferences
final currencyPreferencesProvider = FutureProvider<UserCurrencyPreference?>((ref) async {
  final repository = ref.watch(currencyRepositoryProvider);
  return repository.getPreferences();
});

// Currency by code
final currencyByCodeProvider = FutureProvider.family<CurrencyModel?, CurrencyCode>((ref, code) async {
  final repository = ref.watch(currencyRepositoryProvider);
  return repository.getCurrencyByCode(code);
});

// Exchange rate between two currencies
final exchangeRateProvider = FutureProvider.family<double, ({CurrencyCode from, CurrencyCode to})>((ref, params) async {
  final repository = ref.watch(currencyRepositoryProvider);
  return repository.getExchangeRate(params.from, params.to);
});

// State notifier for currency management
class CurrencyNotifier extends StateNotifier<AsyncValue<List<CurrencyModel>>> {
  final CurrencyRepository _repository;

  CurrencyNotifier(this._repository) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = const AsyncValue.loading();
    try {
      await _repository.initializeDefaultCurrencies();
      await loadCurrencies();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadCurrencies() async {
    state = const AsyncValue.loading();
    try {
      final currencies = await _repository.getAllCurrencies();
      state = AsyncValue.data(currencies);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateExchangeRate(CurrencyCode code, double newRate) async {
    try {
      await _repository.updateExchangeRate(code, newRate);
      await loadCurrencies();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleCurrencyEnabled(CurrencyCode code, bool isEnabled) async {
    try {
      await _repository.toggleCurrencyEnabled(code, isEnabled);
      await loadCurrencies();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<double> convertAmount(double amount, CurrencyCode from, CurrencyCode to) async {
    return _repository.convertAmount(amount, from, to);
  }
}

final currencyNotifierProvider = StateNotifierProvider<CurrencyNotifier, AsyncValue<List<CurrencyModel>>>((ref) {
  final repository = ref.watch(currencyRepositoryProvider);
  return CurrencyNotifier(repository);
});

// Primary currency preference provider
class PrimaryCurrencyNotifier extends StateNotifier<CurrencyCode> {
  final CurrencyRepository _repository;

  PrimaryCurrencyNotifier(this._repository) : super(CurrencyCode.idr) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await _repository.getPreferences();
    if (prefs != null) {
      state = prefs.primaryCurrency;
    }
  }

  Future<void> setPrimaryCurrency(CurrencyCode currency) async {
    final currentPrefs = await _repository.getPreferences();
    final newPrefs = (currentPrefs ?? const UserCurrencyPreference()).copyWith(
      primaryCurrency: currency,
    );
    await _repository.savePreferences(newPrefs);
    state = currency;
  }
}

final primaryCurrencyProvider = StateNotifierProvider<PrimaryCurrencyNotifier, CurrencyCode>((ref) {
  final repository = ref.watch(currencyRepositoryProvider);
  return PrimaryCurrencyNotifier(repository);
});

// Currency preference state notifier for UI settings
class CurrencyPreferenceNotifier extends StateNotifier<AsyncValue<UserCurrencyPreference?>> {
  final CurrencyRepository _repository;

  CurrencyPreferenceNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await _repository.getPreferences();
      state = AsyncValue.data(prefs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setPrimaryCurrency(CurrencyCode currency) async {
    try {
      final currentPrefs = await _repository.getPreferences();
      final newPrefs = (currentPrefs ?? const UserCurrencyPreference()).copyWith(
        primaryCurrency: currency,
      );
      await _repository.savePreferences(newPrefs);
      state = AsyncValue.data(newPrefs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setAutoConvert(bool value) async {
    try {
      final currentPrefs = await _repository.getPreferences();
      final newPrefs = (currentPrefs ?? const UserCurrencyPreference()).copyWith(
        autoConvert: value,
      );
      await _repository.savePreferences(newPrefs);
      state = AsyncValue.data(newPrefs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setShowOriginalAmount(bool value) async {
    try {
      final currentPrefs = await _repository.getPreferences();
      final newPrefs = (currentPrefs ?? const UserCurrencyPreference()).copyWith(
        showOriginalAmount: value,
      );
      await _repository.savePreferences(newPrefs);
      state = AsyncValue.data(newPrefs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addEnabledCurrency(CurrencyCode currency) async {
    try {
      final currentPrefs = await _repository.getPreferences();
      final prefs = currentPrefs ?? const UserCurrencyPreference();
      if (!prefs.enabledCurrencies.contains(currency)) {
        final newList = [...prefs.enabledCurrencies, currency];
        final newPrefs = prefs.copyWith(enabledCurrencies: newList);
        await _repository.savePreferences(newPrefs);
        state = AsyncValue.data(newPrefs);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeEnabledCurrency(CurrencyCode currency) async {
    try {
      final currentPrefs = await _repository.getPreferences();
      final prefs = currentPrefs ?? const UserCurrencyPreference();
      if (prefs.enabledCurrencies.contains(currency)) {
        final newList = prefs.enabledCurrencies.where((c) => c != currency).toList();
        final newPrefs = prefs.copyWith(enabledCurrencies: newList);
        await _repository.savePreferences(newPrefs);
        state = AsyncValue.data(newPrefs);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final currencyPreferenceNotifierProvider = StateNotifierProvider<CurrencyPreferenceNotifier, AsyncValue<UserCurrencyPreference?>>((ref) {
  final repository = ref.watch(currencyRepositoryProvider);
  return CurrencyPreferenceNotifier(repository);
});
