// lib/features/currency/data/models/currency_model.dart

import 'package:equatable/equatable.dart';
import '../../../../core/enums/currency_code.dart';

/// Model untuk mata uang dengan exchange rate
class CurrencyModel extends Equatable {
  final int? id;
  final CurrencyCode code;
  final double rateToIDR;
  final DateTime lastUpdated;
  final bool isBaseCurrency;
  final bool isEnabled;

  const CurrencyModel({
    this.id,
    required this.code,
    required this.rateToIDR,
    required this.lastUpdated,
    this.isBaseCurrency = false,
    this.isEnabled = true,
  });

  /// Convert amount from this currency to IDR
  double toIDR(double amount) {
    return amount * rateToIDR;
  }

  /// Convert amount from IDR to this currency
  double fromIDR(double amountInIDR) {
    if (rateToIDR == 0) return 0;
    return amountInIDR / rateToIDR;
  }

  /// Convert amount to another currency
  double convertTo(double amount, CurrencyModel targetCurrency) {
    final amountInIDR = toIDR(amount);
    return targetCurrency.fromIDR(amountInIDR);
  }

  /// Format amount with currency symbol
  String format(double amount) {
    final symbol = code.symbol;
    final decimals = code.decimalPlaces;
    
    if (decimals == 0) {
      return '$symbol ${amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';
    } else {
      return '$symbol ${amount.toStringAsFixed(decimals).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
    }
  }

  CurrencyModel copyWith({
    int? id,
    CurrencyCode? code,
    double? rateToIDR,
    DateTime? lastUpdated,
    bool? isBaseCurrency,
    bool? isEnabled,
  }) {
    return CurrencyModel(
      id: id ?? this.id,
      code: code ?? this.code,
      rateToIDR: rateToIDR ?? this.rateToIDR,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isBaseCurrency: isBaseCurrency ?? this.isBaseCurrency,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code.code,
      'rate_to_idr': rateToIDR,
      'last_updated': lastUpdated.toIso8601String(),
      'is_base_currency': isBaseCurrency ? 1 : 0,
      'is_enabled': isEnabled ? 1 : 0,
    };
  }

  factory CurrencyModel.fromMap(Map<String, dynamic> map) {
    return CurrencyModel(
      id: map['id'] as int?,
      code: CurrencyCode.fromCode(map['code'] as String),
      rateToIDR: (map['rate_to_idr'] as num).toDouble(),
      lastUpdated: DateTime.parse(map['last_updated'] as String),
      isBaseCurrency: (map['is_base_currency'] as int?) == 1,
      isEnabled: (map['is_enabled'] as int?) == 1,
    );
  }

  /// Create default currency model with default rates
  factory CurrencyModel.defaultCurrency(CurrencyCode code) {
    return CurrencyModel(
      code: code,
      rateToIDR: code.defaultRateToIDR,
      lastUpdated: DateTime.now(),
      isBaseCurrency: code == CurrencyCode.idr,
      isEnabled: true,
    );
  }

  @override
  List<Object?> get props => [id, code, rateToIDR, lastUpdated, isBaseCurrency, isEnabled];
}

/// Model untuk menyimpan preferensi mata uang user
class UserCurrencyPreference extends Equatable {
  final int? id;
  final CurrencyCode primaryCurrency;
  final List<CurrencyCode> enabledCurrencies;
  final bool autoConvert;
  final bool showOriginalAmount;
  final DateTime? lastUpdated;

  const UserCurrencyPreference({
    this.id,
    this.primaryCurrency = CurrencyCode.idr,
    this.enabledCurrencies = const [CurrencyCode.idr, CurrencyCode.usd],
    this.autoConvert = true,
    this.showOriginalAmount = true,
    this.lastUpdated,
  });

  UserCurrencyPreference copyWith({
    int? id,
    CurrencyCode? primaryCurrency,
    List<CurrencyCode>? enabledCurrencies,
    bool? autoConvert,
    bool? showOriginalAmount,
    DateTime? lastUpdated,
  }) {
    return UserCurrencyPreference(
      id: id ?? this.id,
      primaryCurrency: primaryCurrency ?? this.primaryCurrency,
      enabledCurrencies: enabledCurrencies ?? this.enabledCurrencies,
      autoConvert: autoConvert ?? this.autoConvert,
      showOriginalAmount: showOriginalAmount ?? this.showOriginalAmount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'primary_currency': primaryCurrency.code,
      'enabled_currencies': enabledCurrencies.map((c) => c.code).join(','),
      'auto_convert': autoConvert ? 1 : 0,
      'show_original_amount': showOriginalAmount ? 1 : 0,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  factory UserCurrencyPreference.fromMap(Map<String, dynamic> map) {
    final enabledCurrenciesStr = map['enabled_currencies'] as String? ?? 'IDR,USD';
    final enabledCurrencies = enabledCurrenciesStr
        .split(',')
        .map((code) => CurrencyCode.fromCode(code.trim()))
        .toList();

    return UserCurrencyPreference(
      id: map['id'] as int?,
      primaryCurrency: CurrencyCode.fromCode(map['primary_currency'] as String? ?? 'IDR'),
      enabledCurrencies: enabledCurrencies,
      autoConvert: (map['auto_convert'] as int?) == 1,
      showOriginalAmount: (map['show_original_amount'] as int?) == 1,
      lastUpdated: map['last_updated'] != null 
          ? DateTime.parse(map['last_updated'] as String) 
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        primaryCurrency,
        enabledCurrencies,
        autoConvert,
        showOriginalAmount,
        lastUpdated,
      ];
}
