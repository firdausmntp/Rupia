// lib/features/currency/data/repositories/currency_repository.dart

import '../../../../core/services/database_service.dart';
import '../../../../core/enums/currency_code.dart';
import '../models/currency_model.dart';

class CurrencyRepository {
  static const String _currenciesTable = 'currencies';
  static const String _preferencesTable = 'currency_preferences';

  /// Get all currencies
  Future<List<CurrencyModel>> getAllCurrencies() async {
    final results = await DatabaseService.query(
      _currenciesTable,
      orderBy: 'code ASC',
    );
    return results.map((map) => CurrencyModel.fromMap(map)).toList();
  }

  /// Get enabled currencies only
  Future<List<CurrencyModel>> getEnabledCurrencies() async {
    final results = await DatabaseService.query(
      _currenciesTable,
      where: 'is_enabled = ?',
      whereArgs: [1],
      orderBy: 'code ASC',
    );
    return results.map((map) => CurrencyModel.fromMap(map)).toList();
  }

  /// Get currency by code
  Future<CurrencyModel?> getCurrencyByCode(CurrencyCode code) async {
    final results = await DatabaseService.query(
      _currenciesTable,
      where: 'code = ?',
      whereArgs: [code.code],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return CurrencyModel.fromMap(results.first);
  }

  /// Get base currency (IDR)
  Future<CurrencyModel> getBaseCurrency() async {
    final results = await DatabaseService.query(
      _currenciesTable,
      where: 'is_base_currency = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (results.isEmpty) {
      // Return default IDR
      return CurrencyModel.defaultCurrency(CurrencyCode.idr);
    }
    return CurrencyModel.fromMap(results.first);
  }

  /// Insert or update currency
  Future<int> upsertCurrency(CurrencyModel currency) async {
    final existing = await getCurrencyByCode(currency.code);
    
    if (existing != null) {
      return await DatabaseService.update(
        _currenciesTable,
        currency.toMap(),
        where: 'code = ?',
        whereArgs: [currency.code.code],
      );
    } else {
      final map = currency.toMap();
      map.remove('id');
      return await DatabaseService.insert(_currenciesTable, map);
    }
  }

  /// Update exchange rate
  Future<int> updateExchangeRate(CurrencyCode code, double newRate) async {
    return await DatabaseService.update(
      _currenciesTable,
      {
        'rate_to_idr': newRate,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'code = ?',
      whereArgs: [code.code],
    );
  }

  /// Toggle currency enabled status
  Future<int> toggleCurrencyEnabled(CurrencyCode code, bool isEnabled) async {
    return await DatabaseService.update(
      _currenciesTable,
      {'is_enabled': isEnabled ? 1 : 0},
      where: 'code = ?',
      whereArgs: [code.code],
    );
  }

  /// Initialize default currencies
  Future<void> initializeDefaultCurrencies() async {
    final existing = await getAllCurrencies();
    if (existing.isNotEmpty) return;

    // Insert default currencies with default rates
    final defaultCurrencies = [
      CurrencyCode.idr,
      CurrencyCode.usd,
      CurrencyCode.eur,
      CurrencyCode.sgd,
      CurrencyCode.myr,
      CurrencyCode.jpy,
      CurrencyCode.gbp,
      CurrencyCode.aud,
    ];

    for (final code in defaultCurrencies) {
      final currency = CurrencyModel.defaultCurrency(code);
      await upsertCurrency(currency);
    }
  }

  /// Get user currency preferences
  Future<UserCurrencyPreference?> getPreferences() async {
    final results = await DatabaseService.query(
      _preferencesTable,
      limit: 1,
    );
    if (results.isEmpty) return null;
    return UserCurrencyPreference.fromMap(results.first);
  }

  /// Save user currency preferences
  Future<int> savePreferences(UserCurrencyPreference preferences) async {
    final existing = await getPreferences();
    
    final map = preferences.toMap();
    map['last_updated'] = DateTime.now().toIso8601String();
    
    if (existing != null && existing.id != null) {
      return await DatabaseService.update(
        _preferencesTable,
        map,
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      map.remove('id');
      return await DatabaseService.insert(_preferencesTable, map);
    }
  }

  /// Convert amount between currencies
  Future<double> convertAmount(
    double amount,
    CurrencyCode fromCurrency,
    CurrencyCode toCurrency,
  ) async {
    if (fromCurrency == toCurrency) return amount;

    final from = await getCurrencyByCode(fromCurrency);
    final to = await getCurrencyByCode(toCurrency);

    if (from == null || to == null) {
      // Use default rates if currencies not found
      final fromRate = fromCurrency.defaultRateToIDR;
      final toRate = toCurrency.defaultRateToIDR;
      final amountInIDR = amount * fromRate;
      return amountInIDR / toRate;
    }

    // Convert: from -> IDR -> to
    final amountInIDR = from.toIDR(amount);
    return to.fromIDR(amountInIDR);
  }

  /// Get exchange rate between two currencies
  Future<double> getExchangeRate(
    CurrencyCode fromCurrency,
    CurrencyCode toCurrency,
  ) async {
    return await convertAmount(1.0, fromCurrency, toCurrency);
  }

  /// Delete currency (only custom ones, not base)
  Future<int> deleteCurrency(CurrencyCode code) async {
    if (code == CurrencyCode.idr) {
      throw Exception('Cannot delete base currency (IDR)');
    }
    
    return await DatabaseService.delete(
      _currenciesTable,
      where: 'code = ? AND is_base_currency = ?',
      whereArgs: [code.code, 0],
    );
  }
}
