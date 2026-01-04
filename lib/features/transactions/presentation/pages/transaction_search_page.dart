import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transaction_providers.dart';

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered transactions provider
final filteredTransactionsProvider = Provider<AsyncValue<List<TransactionModel>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  
  return transactionsAsync.when(
    data: (transactions) {
      if (query.isEmpty) {
        return AsyncData(transactions);
      }
      
      final filtered = transactions.where((tx) {
        return tx.description.toLowerCase().contains(query) ||
               tx.category.displayName.toLowerCase().contains(query) ||
               CurrencyFormatter.format(tx.amount).contains(query);
      }).toList();
      
      return AsyncData(filtered);
    },
    loading: () => const AsyncLoading(),
    error: (e, s) => AsyncError(e, s),
  );
});

class TransactionSearchPage extends ConsumerStatefulWidget {
  const TransactionSearchPage({super.key});

  @override
  ConsumerState<TransactionSearchPage> createState() => _TransactionSearchPageState();
}

class _TransactionSearchPageState extends ConsumerState<TransactionSearchPage> {
  final _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final isAmoled = ref.watch(isAmoledModeProvider);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);
    
    final backgroundColor = isAmoled 
        ? AppColors.backgroundAmoled 
        : isDark 
            ? AppColors.backgroundDark 
            : AppColors.background;
    final cardColor = isAmoled 
        ? AppColors.cardBackgroundAmoled 
        : isDark 
            ? AppColors.cardBackgroundDark 
            : Colors.white;
    final textSecondary = isAmoled 
        ? AppColors.textSecondaryAmoled 
        : isDark 
            ? AppColors.textSecondaryDark 
            : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Cari Transaksi'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Cari transaksi...',
                hintStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.search, color: textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          
          // Results
          Expanded(
            child: filteredTransactions.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: textSecondary.withValues(alpha: 0.5),
                        ),
                        const Gap(16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Ketik untuk mencari'
                              : 'Tidak ada hasil',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => const Gap(14),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return _buildTransactionItem(context, tx, cardColor, textSecondary);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionModel tx,
    Color cardColor,
    Color textSecondary,
  ) {
    final isExpense = tx.type.name == 'expense';
    
    return InkWell(
      onTap: () => context.push('/transaction/${tx.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isExpense ? AppColors.expense : AppColors.income).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                tx.category.icon,
                color: isExpense ? AppColors.expense : AppColors.income,
                size: 24,
              ),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '${tx.category.displayName} • ${DateFormatter.formatShort(tx.date)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isExpense ? '-' : '+'}${CurrencyFormatter.format(tx.amount)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isExpense ? AppColors.expense : AppColors.income,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
