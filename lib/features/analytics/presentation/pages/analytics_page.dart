import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/enums/mood_type.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/data/models/transaction_model.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(currentMonthTransactionsProvider);
    final categoryExpenseAsync = ref.watch(categoryExpenseProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final isAmoled = ref.watch(isAmoledModeProvider);
    
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
        title: const Text('Analitik'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(8), // Top spacing for visual appeal
            
            // Category Breakdown
            Text(
              'Pengeluaran per Kategori',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(16),
            categoryExpenseAsync.when(
              data: (categoryExpense) {
                if (categoryExpense.isEmpty) {
                  return _buildEmptyChart(context, cardColor, isDark, textSecondary);
                }
                return _buildCategoryChart(context, categoryExpense);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
            const Gap(32),

            // Mood Analytics
            Text(
              'Mood & Pengeluaran',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(16),
            transactionsAsync.when(
              data: (transactions) {
                final moodData = _calculateMoodSpending(transactions);
                if (moodData.isEmpty) {
                  return _buildEmptyMoodChart(context, cardColor, isDark, textSecondary);
                }
                return _buildMoodChart(context, moodData);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
            const Gap(32),

            // Insights
            Text(
              'Insight',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(16),
            transactionsAsync.when(
              data: (transactions) => _buildInsights(context, transactions),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
            
            const Gap(100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Map<MoodType, double> _calculateMoodSpending(List<TransactionModel> transactions) {
    final Map<MoodType, double> moodSpending = {};
    
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense && transaction.mood != null) {
        moodSpending[transaction.mood!] = 
            (moodSpending[transaction.mood!] ?? 0) + transaction.amount;
      }
    }
    
    return moodSpending;
  }

  Widget _buildCategoryChart(BuildContext context, Map<String, double> data) {
    final total = data.values.fold(0.0, (sum, value) => sum + value);
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.warning,
      AppColors.info,
      AppColors.expense,
      AppColors.moodTired,
      AppColors.moodBored,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: sortedEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final percentage = (item.value / total) * 100;
                  
                  return PieChartSectionData(
                    value: item.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    color: colors[index % colors.length],
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Gap(16),
          ...sortedEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      item.key,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatCompact(item.value),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMoodChart(BuildContext context, Map<MoodType, double> data) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: sortedEntries.map((entry) {
          final mood = entry.key;
          final amount = entry.value;
          final maxAmount = sortedEntries.first.value;
          final percentage = (amount / maxAmount);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(mood.emoji, style: const TextStyle(fontSize: 24)),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        mood.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatCompact(amount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: mood.color,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(mood.color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsights(BuildContext context, List<TransactionModel> transactions) {
    final insights = <Widget>[];
    
    // Calculate mood-based insight
    final moodSpending = _calculateMoodSpending(transactions);
    if (moodSpending.isNotEmpty) {
      final highestMood = moodSpending.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      insights.add(_buildInsightCard(
        context,
        emoji: highestMood.key.emoji,
        title: 'Pengeluaran Terbesar',
        description: 'Kamu paling banyak berbelanja saat ${highestMood.key.displayName.toLowerCase()} '
            '(${CurrencyFormatter.formatCompact(highestMood.value)})',
        color: highestMood.key.color,
      ));
    }

    // Count transactions
    final expenseCount = transactions
        .where((t) => t.type == TransactionType.expense)
        .length;
    
    if (expenseCount > 0) {
      final avgExpense = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount) / expenseCount;
      
      insights.add(_buildInsightCard(
        context,
        emoji: '📊',
        title: 'Rata-rata Pengeluaran',
        description: 'Rata-rata transaksi pengeluaranmu adalah ${CurrencyFormatter.formatCompact(avgExpense)}',
        color: AppColors.info,
      ));
    }

    if (insights.isEmpty) {
      return _buildEmptyInsights(context);
    }

    return Column(children: insights);
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                  ),
                ),
                const Gap(4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context, Color cardColor, bool isDark, Color textSecondary) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: textSecondary.withValues(alpha:0.5),
          ),
          const Gap(8),
          Text(
            'Belum ada data pengeluaran',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMoodChart(BuildContext context, Color cardColor, bool isDark, Color textSecondary) {
    return Container(
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mood_outlined,
            size: 48,
            color: textSecondary.withValues(alpha:0.5),
          ),
          const Gap(8),
          Text(
            'Tambahkan mood di transaksi untuk analitik',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInsights(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha:0.5),
          ),
          const Gap(8),
          Text(
            'Insight akan muncul setelah ada lebih banyak transaksi',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
