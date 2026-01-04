// lib/features/currency/presentation/pages/currency_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/enums/currency_code.dart';
import '../providers/currency_providers.dart';
import '../../data/models/currency_model.dart';

class CurrencyPage extends ConsumerStatefulWidget {
  const CurrencyPage({super.key});

  @override
  ConsumerState<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends ConsumerState<CurrencyPage> {
  final _amountController = TextEditingController();
  CurrencyCode _fromCurrency = CurrencyCode.idr;
  CurrencyCode _toCurrency = CurrencyCode.usd;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final preferenceState = ref.watch(currencyPreferenceNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Currency'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showCurrencySettings(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Currency Converter Card
            _buildConverterCard(isDark),
            const Gap(24),

            // Primary Currency Display
            preferenceState.when(
              data: (preference) => _buildPrimaryCurrencyCard(preference, isDark),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
            const Gap(24),

            // Exchange Rates List
            Text(
              'Kurs Terkini',
              style: theme.textTheme.titleLarge,
            ),
            const Gap(12),
            _buildExchangeRatesList(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildConverterCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konversi Mata Uang',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(16),

            // From Currency
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Jumlah',
                      prefixText: _fromCurrency.symbol,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: DropdownButtonFormField<CurrencyCode>(
                    value: _fromCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Dari',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: CurrencyCode.values.map((code) {
                      return DropdownMenuItem(
                        value: code,
                        child: Text('${code.flag} ${code.code}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _fromCurrency = value);
                    },
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Swap Button
            Center(
              child: IconButton.filled(
                onPressed: () {
                  setState(() {
                    final temp = _fromCurrency;
                    _fromCurrency = _toCurrency;
                    _toCurrency = temp;
                  });
                },
                icon: const Icon(Icons.swap_vert),
              ),
            ),
            const Gap(16),

            // To Currency
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hasil',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Gap(4),
                        Text(
                          _calculateConversion(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: DropdownButtonFormField<CurrencyCode>(
                    value: _toCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Ke',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: CurrencyCode.values.map((code) {
                      return DropdownMenuItem(
                        value: code,
                        child: Text('${code.flag} ${code.code}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _toCurrency = value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateConversion() {
    final amountText = _amountController.text.replaceAll('.', '').replaceAll(',', '');
    if (amountText.isEmpty) return '0';

    final amount = double.tryParse(amountText) ?? 0;
    if (amount == 0) return '0';

    // Convert to IDR first, then to target currency
    final amountInIDR = amount * _fromCurrency.defaultRateToIDR;
    final result = amountInIDR / _toCurrency.defaultRateToIDR;

    return '${_toCurrency.symbol} ${_formatNumber(result)}';
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    } else if (number < 1) {
      return number.toStringAsFixed(4);
    } else {
      return number.toStringAsFixed(2);
    }
  }

  String _formatAmount(double number) {
    // Format untuk exchange rate dengan pemisah ribuan
    if (number >= 1000) {
      return number.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    }
    return number.toStringAsFixed(2);
  }

  Widget _buildPrimaryCurrencyCard(UserCurrencyPreference? preference, bool isDark) {
    final primaryCurrency = preference?.primaryCurrency ?? CurrencyCode.idr;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                primaryCurrency.flag,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mata Uang Utama',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    primaryCurrency.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${primaryCurrency.code} (${primaryCurrency.symbol})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showChangePrimaryCurrencyDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeRatesList(bool isDark) {
    final baseCurrency = CurrencyCode.idr;

    return Card(
      child: Column(
        children: CurrencyCode.values.where((c) => c != baseCurrency).map((currency) {
          return ListTile(
            leading: Text(
              currency.flag,
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(currency.displayName),
            subtitle: Text(currency.code),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '1 ${currency.code} =',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Rp ${_formatAmount(currency.defaultRateToIDR)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showCurrencySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _CurrencySettingsSheet(),
    );
  }

  void _showChangePrimaryCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Mata Uang Utama'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: CurrencyCode.values.length,
            itemBuilder: (context, index) {
              final currency = CurrencyCode.values[index];
              return ListTile(
                leading: Text(currency.flag, style: const TextStyle(fontSize: 24)),
                title: Text(currency.displayName),
                subtitle: Text('${currency.code} (${currency.symbol})'),
                onTap: () {
                  ref.read(currencyPreferenceNotifierProvider.notifier).setPrimaryCurrency(currency);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mata uang utama diubah ke ${currency.displayName}')),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CurrencySettingsSheet extends ConsumerWidget {
  const _CurrencySettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferenceState = ref.watch(currencyPreferenceNotifierProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(16),
              Text(
                'Pengaturan Mata Uang',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Gap(24),

              preferenceState.when(
                data: (preference) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Auto Convert
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Konversi Otomatis'),
                        subtitle: const Text('Konversi nilai secara otomatis'),
                        value: preference?.autoConvert ?? true,
                        onChanged: (value) {
                          ref.read(currencyPreferenceNotifierProvider.notifier)
                              .setAutoConvert(value);
                        },
                      ),
                      const Divider(),

                      // Show Original Amount
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Tampilkan Nilai Asli'),
                        subtitle: const Text('Tampilkan nilai dalam mata uang asli'),
                        value: preference?.showOriginalAmount ?? true,
                        onChanged: (value) {
                          ref.read(currencyPreferenceNotifierProvider.notifier)
                              .setShowOriginalAmount(value);
                        },
                      ),
                      const Divider(),

                      // Enabled Currencies
                      const Gap(16),
                      Text(
                        'Mata Uang Aktif',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Gap(8),
                      Text(
                        'Pilih mata uang yang ingin diaktifkan',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Gap(16),
                      ...CurrencyCode.values.where((c) => c != preference?.primaryCurrency).map((currency) {
                        final isSelected = preference?.enabledCurrencies.contains(currency) ?? false;
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              Text(currency.flag, style: const TextStyle(fontSize: 20)),
                              const Gap(12),
                              Text(currency.displayName),
                            ],
                          ),
                          subtitle: Text('${currency.code} (${currency.symbol})'),
                          value: isSelected,
                          onChanged: (value) {
                            if (value == true) {
                              ref.read(currencyPreferenceNotifierProvider.notifier)
                                  .addEnabledCurrency(currency);
                            } else {
                              ref.read(currencyPreferenceNotifierProvider.notifier)
                                  .removeEnabledCurrency(currency);
                            }
                          },
                        );
                      }),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          ),
        );
      },
    );
  }
}
