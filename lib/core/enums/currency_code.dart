// lib/core/enums/currency_code.dart



/// Enum untuk kode mata uang yang didukung
enum CurrencyCode {
  idr,
  usd,
  eur,
  gbp,
  jpy,
  sgd,
  myr,
  aud,
  cny,
  krw,
  thb,
  php,
  vnd,
  inr,
  aed,
  sar;

  String get code {
    return name.toUpperCase();
  }

  String get displayName {
    switch (this) {
      case CurrencyCode.idr:
        return 'Rupiah Indonesia';
      case CurrencyCode.usd:
        return 'US Dollar';
      case CurrencyCode.eur:
        return 'Euro';
      case CurrencyCode.gbp:
        return 'British Pound';
      case CurrencyCode.jpy:
        return 'Japanese Yen';
      case CurrencyCode.sgd:
        return 'Singapore Dollar';
      case CurrencyCode.myr:
        return 'Malaysian Ringgit';
      case CurrencyCode.aud:
        return 'Australian Dollar';
      case CurrencyCode.cny:
        return 'Chinese Yuan';
      case CurrencyCode.krw:
        return 'Korean Won';
      case CurrencyCode.thb:
        return 'Thai Baht';
      case CurrencyCode.php:
        return 'Philippine Peso';
      case CurrencyCode.vnd:
        return 'Vietnamese Dong';
      case CurrencyCode.inr:
        return 'Indian Rupee';
      case CurrencyCode.aed:
        return 'UAE Dirham';
      case CurrencyCode.sar:
        return 'Saudi Riyal';
    }
  }

  String get symbol {
    switch (this) {
      case CurrencyCode.idr:
        return 'Rp';
      case CurrencyCode.usd:
        return '\$';
      case CurrencyCode.eur:
        return '€';
      case CurrencyCode.gbp:
        return '£';
      case CurrencyCode.jpy:
        return '¥';
      case CurrencyCode.sgd:
        return 'S\$';
      case CurrencyCode.myr:
        return 'RM';
      case CurrencyCode.aud:
        return 'A\$';
      case CurrencyCode.cny:
        return '¥';
      case CurrencyCode.krw:
        return '₩';
      case CurrencyCode.thb:
        return '฿';
      case CurrencyCode.php:
        return '₱';
      case CurrencyCode.vnd:
        return '₫';
      case CurrencyCode.inr:
        return '₹';
      case CurrencyCode.aed:
        return 'د.إ';
      case CurrencyCode.sar:
        return '﷼';
    }
  }

  String get flag {
    switch (this) {
      case CurrencyCode.idr:
        return '🇮🇩';
      case CurrencyCode.usd:
        return '🇺🇸';
      case CurrencyCode.eur:
        return '🇪🇺';
      case CurrencyCode.gbp:
        return '🇬🇧';
      case CurrencyCode.jpy:
        return '🇯🇵';
      case CurrencyCode.sgd:
        return '🇸🇬';
      case CurrencyCode.myr:
        return '🇲🇾';
      case CurrencyCode.aud:
        return '🇦🇺';
      case CurrencyCode.cny:
        return '🇨🇳';
      case CurrencyCode.krw:
        return '🇰🇷';
      case CurrencyCode.thb:
        return '🇹🇭';
      case CurrencyCode.php:
        return '🇵🇭';
      case CurrencyCode.vnd:
        return '🇻🇳';
      case CurrencyCode.inr:
        return '🇮🇳';
      case CurrencyCode.aed:
        return '🇦🇪';
      case CurrencyCode.sar:
        return '🇸🇦';
    }
  }

  int get decimalPlaces {
    switch (this) {
      case CurrencyCode.idr:
      case CurrencyCode.jpy:
      case CurrencyCode.krw:
      case CurrencyCode.vnd:
        return 0;
      default:
        return 2;
    }
  }

  /// Default exchange rate to IDR (approximate)
  double get defaultRateToIDR {
    switch (this) {
      case CurrencyCode.idr:
        return 1.0;
      case CurrencyCode.usd:
        return 15500.0;
      case CurrencyCode.eur:
        return 16800.0;
      case CurrencyCode.gbp:
        return 19500.0;
      case CurrencyCode.jpy:
        return 103.0;
      case CurrencyCode.sgd:
        return 11500.0;
      case CurrencyCode.myr:
        return 3300.0;
      case CurrencyCode.aud:
        return 10000.0;
      case CurrencyCode.cny:
        return 2150.0;
      case CurrencyCode.krw:
        return 10.8;
      case CurrencyCode.thb:
        return 435.0;
      case CurrencyCode.php:
        return 275.0;
      case CurrencyCode.vnd:
        return 0.62;
      case CurrencyCode.inr:
        return 185.0;
      case CurrencyCode.aed:
        return 4220.0;
      case CurrencyCode.sar:
        return 4130.0;
    }
  }

  static CurrencyCode fromCode(String code) {
    return CurrencyCode.values.firstWhere(
      (c) => c.code == code.toUpperCase(),
      orElse: () => CurrencyCode.idr,
    );
  }
}
