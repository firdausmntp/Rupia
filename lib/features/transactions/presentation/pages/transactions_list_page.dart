import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/transaction_providers.dart';
import '../../../home/presentation/widgets/transaction_list_item.dart';

class TransactionsListPage extends ConsumerWidget {
  const TransactionsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final isAmoled = ref.watch(isAmoledModeProvider);
    
    final backgroundColor = isAmoled 
        ? AppColors.backgroundAmoled 
        : isDark 
            ? AppColors.backgroundDark 
            : AppColors.background;
    final textSecondary = isAmoled 
        ? AppColors.textSecondaryAmoled 
        : isDark 
            ? AppColors.textSecondaryDark 
            : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Semua Transaksi'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: textSecondary.withValues(alpha: 0.5),
                  ),
                  const Gap(16),
                  Text(
                    'Belum ada transaksi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textSecondary,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Tap tombol + untuk menambah transaksi',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Gap(14),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return TransactionListItem(
                transaction: transaction,
                onTap: () {
                  context.push('/transaction/${transaction.id}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
