import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_list_item.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(currentMonthTransactionsProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final isAmoled = ref.watch(isAmoledModeProvider);
    final accentColor = ref.watch(accentColorProvider);
    
    // Theme-aware colors
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
    final textPrimary = isAmoled 
        ? AppColors.textPrimaryAmoled 
        : isDark 
            ? AppColors.textPrimaryDark 
            : AppColors.textPrimary;
    final textSecondary = isAmoled 
        ? AppColors.textSecondaryAmoled 
        : isDark 
            ? AppColors.textSecondaryDark 
            : AppColors.textSecondary;
    final primaryColor = accentColor.color;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, HSLColor.fromColor(primaryColor).withLightness(0.4).toColor()],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
            ),
            const Gap(12),
            Text(
              'Rupia',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/transactions/search');
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(Icons.search, color: textSecondary, size: 22),
            ),
          ),
          IconButton(
            onPressed: () {
              context.push('/notifications');
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(Icons.notifications_outlined, color: textSecondary, size: 22),
            ),
          ),
          const Gap(8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(currentMonthTransactionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isDark ? null : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat ${_getGreeting()}! 👋',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            DateFormatter.formatFull(DateTime.now()),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.calendar_today, color: primaryColor, size: 24),
                    ),
                  ],
                ),
              ),
              const Gap(20),
              
              // Summary Cards
              summaryAsync.when(
                data: (summary) => Column(
                  children: [
                    // Balance Card - Enhanced
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.wallet, color: Colors.white, size: 16),
                                    Gap(6),
                                    Text(
                                      'Saldo Bulan Ini',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              CurrencyFormatter.format(summary.balance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${summary.transactionCount} transaksi',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),
                    
                    // Income & Expense Row
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: 'Pemasukan',
                            amount: summary.totalIncome,
                            icon: Icons.arrow_downward,
                            color: AppColors.income,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: SummaryCard(
                            title: 'Pengeluaran',
                            amount: summary.totalExpense,
                            icon: Icons.arrow_upward,
                            color: AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.expense.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('Error: $error', style: TextStyle(color: AppColors.expense)),
                ),
              ),
              
              const Gap(24),
              
              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaksi Terbaru',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context.push('/transactions');
                    },
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Lihat Semua'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Gap(14),
              
              // Transaction List
              transactionsAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return _buildEmptyState(
                      context,
                      cardColor: cardColor,
                      borderColor: isAmoled 
                          ? AppColors.borderAmoled 
                          : isDark 
                              ? AppColors.borderDark 
                              : AppColors.border,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    );
                  }
                  
                  final recentTransactions = transactions.take(10).toList();
                  
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentTransactions.length,
                    separatorBuilder: (context, index) => const Gap(14),
                    itemBuilder: (context, index) {
                      final transaction = recentTransactions[index];
                      return TransactionListItem(
                        transaction: transaction,
                        onTap: () {
                          context.push('/transaction/${transaction.id}');
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Text('Error: $error'),
              ),
              
              const Gap(100), // Space for bottom nav + FAB
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Pagi';
    if (hour < 15) return 'Siang';
    if (hour < 18) return 'Sore';
    return 'Malam';
  }

  Widget _buildEmptyState(BuildContext context, {
    required Color cardColor,
    required Color borderColor,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          const Gap(20),
          Text(
            'Belum ada transaksi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            'Tap tombol + untuk menambah\ntransaksi pertama',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
