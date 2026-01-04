// lib/features/analytics/presentation/pages/mood_analytics_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/enums/mood_type.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

class MoodAnalyticsPage extends ConsumerWidget {
  const MoodAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(currentMonthTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Analytics'),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return _buildEmptyState(context);
          }

          // Calculate mood statistics
          final moodData = _calculateMoodData(transactions);
          final insights = _generateInsights(moodData);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, transactions.length, moodData),
                const Gap(24),

                // Mood Pie Chart
                _buildMoodChart(context, moodData),
                const Gap(24),

                // Insights
                _buildInsights(context, insights),
                const Gap(24),

                // Mood Breakdown
                _buildMoodBreakdown(context, moodData),
                const Gap(24),

                // Spending Patterns
                _buildSpendingPatterns(context, moodData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mood, size: 80, color: Colors.grey.shade400),
          const Gap(16),
          Text(
            'Belum ada data',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(8),
          Text(
            'Mulai catat transaksi dengan mood\nuntuk melihat analisis',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int totalTransactions,
    Map<MoodType, MoodStats> moodData,
  ) {
    final withMood = moodData.values.fold<int>(
      0,
      (sum, stats) => sum + stats.count,
    );
    final percentage = totalTransactions > 0
        ? (withMood / totalTransactions * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade400,
            Colors.purple.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mood Tracking',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const Gap(8),
                Text(
                  '$withMood dari $totalTransactions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'transaksi dengan mood ($percentage%)',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChart(
    BuildContext context,
    Map<MoodType, MoodStats> moodData,
  ) {
    if (moodData.isEmpty) {
      return const SizedBox();
    }

    final sections = moodData.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value.totalAmount,
        title: entry.value.count.toString(),
        color: entry.key.color,
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengeluaran per Mood',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Gap(16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const Gap(16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: moodData.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: entry.key.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '${entry.key.emoji} ${entry.key.displayName}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(BuildContext context, List<String> insights) {
    if (insights.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber.shade700),
              const Gap(8),
              Text(
                'Insights',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
          const Gap(12),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💡 ', style: TextStyle(color: Colors.amber.shade700)),
                Expanded(
                  child: Text(
                    insight,
                    style: TextStyle(color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMoodBreakdown(
    BuildContext context,
    Map<MoodType, MoodStats> moodData,
  ) {
    final sortedData = moodData.entries.toList()
      ..sort((a, b) => b.value.totalAmount.compareTo(a.value.totalAmount));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail per Mood',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Gap(16),
          ...sortedData.map((entry) {
            final mood = entry.key;
            final stats = entry.value;
            final maxAmount = sortedData.first.value.totalAmount;
            final percentage = maxAmount > 0 
                ? stats.totalAmount / maxAmount 
                : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        mood.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mood.displayName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${stats.count} transaksi',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(stats.totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'avg: ${CurrencyFormatter.formatCompact(stats.avgAmount)}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(8),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(mood.color),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSpendingPatterns(
    BuildContext context,
    Map<MoodType, MoodStats> moodData,
  ) {
    if (moodData.length < 2) {
      return const SizedBox();
    }

    final sortedByAvg = moodData.entries.toList()
      ..sort((a, b) => b.value.avgAmount.compareTo(a.value.avgAmount));

    final highest = sortedByAvg.first;
    final lowest = sortedByAvg.last;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pola Pengeluaran',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Gap(16),
          _buildPatternItem(
            '🔥 Paling Boros',
            highest.key,
            highest.value,
            Colors.red.shade50,
            Colors.red.shade700,
          ),
          const Gap(12),
          _buildPatternItem(
            '💪 Paling Hemat',
            lowest.key,
            lowest.value,
            Colors.green.shade50,
            Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildPatternItem(
    String label,
    MoodType mood,
    MoodStats stats,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(mood.emoji, style: const TextStyle(fontSize: 28)),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Saat ${mood.displayName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatCompact(stats.avgAmount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                'rata-rata',
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<MoodType, MoodStats> _calculateMoodData(List<dynamic> transactions) {
    final Map<MoodType, MoodStats> result = {};

    for (final tx in transactions) {
      if (tx.mood == null) continue;

      final mood = tx.mood as MoodType;
      final amount = (tx.amount as num).toDouble();

      if (result.containsKey(mood)) {
        final existing = result[mood]!;
        result[mood] = MoodStats(
          count: existing.count + 1,
          totalAmount: existing.totalAmount + amount,
        );
      } else {
        result[mood] = MoodStats(count: 1, totalAmount: amount);
      }
    }

    return result;
  }

  List<String> _generateInsights(Map<MoodType, MoodStats> moodData) {
    final insights = <String>[];

    if (moodData.length < 3) {
      insights.add('Tambahkan mood ke lebih banyak transaksi untuk insight yang lebih akurat.');
      return insights;
    }

    // Find highest spending mood
    final sortedByTotal = moodData.entries.toList()
      ..sort((a, b) => b.value.totalAmount.compareTo(a.value.totalAmount));
    
    final highest = sortedByTotal.first;
    insights.add(
      'Kamu paling banyak belanja saat ${highest.key.displayName} '
      '(${CurrencyFormatter.format(highest.value.totalAmount)})',
    );

    // Find most frequent mood
    final sortedByCount = moodData.entries.toList()
      ..sort((a, b) => b.value.count.compareTo(a.value.count));
    
    final mostFrequent = sortedByCount.first;
    if (mostFrequent.key != highest.key) {
      insights.add(
        'Mood ${mostFrequent.key.displayName} paling sering muncul '
        '(${mostFrequent.value.count}x)',
      );
    }

    // Compare stress vs happy spending
    final stress = moodData[MoodType.stress];
    final happy = moodData[MoodType.happy];
    
    if (stress != null && happy != null) {
      if (stress.avgAmount > happy.avgAmount * 1.2) {
        insights.add(
          '⚠️ Pengeluaran saat stress ${((stress.avgAmount / happy.avgAmount - 1) * 100).round()}% '
          'lebih tinggi dari saat senang',
        );
      }
    }

    return insights;
  }
}

class MoodStats {
  final int count;
  final double totalAmount;

  MoodStats({required this.count, required this.totalAmount});

  double get avgAmount => count > 0 ? totalAmount / count : 0;
}
