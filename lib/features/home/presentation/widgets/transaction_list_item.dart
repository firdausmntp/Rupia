import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../transactions/data/models/transaction_model.dart';

class TransactionListItem extends ConsumerWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final isAmoled = ref.watch(isAmoledModeProvider);
    final cardColor = isAmoled 
        ? AppColors.cardBackgroundAmoled 
        : isDark 
            ? AppColors.cardBackgroundDark 
            : Colors.white;
    final borderColor = isAmoled 
        ? AppColors.borderAmoled 
        : isDark 
            ? AppColors.borderDark 
            : AppColors.border;
    final textSecondary = isAmoled 
        ? AppColors.textSecondaryAmoled 
        : isDark 
            ? AppColors.textSecondaryDark 
            : AppColors.textSecondary;
    final textTertiary = isAmoled 
        ? AppColors.textTertiaryAmoled 
        : isDark 
            ? AppColors.textTertiaryDark 
            : AppColors.textTertiary;
    final inputBgColor = isAmoled 
        ? AppColors.surfaceAmoled 
        : isDark 
            ? AppColors.surfaceDark 
            : AppColors.background;
    
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? AppColors.expense : AppColors.income;
    final sign = isExpense ? '-' : '+';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor.withValues(alpha: 0.6)),
            boxShadow: isDark ? null : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Category Icon - Enhanced
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      transaction.category.color.withValues(alpha: 0.15),
                      transaction.category.color.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  transaction.category.icon,
                  color: transaction.category.color,
                  size: 24,
                ),
              ),
              const Gap(14),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: inputBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            transaction.category.displayName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (transaction.mood != null) ...[
                          const Gap(6),
                          Text(
                            transaction.mood!.emoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Amount & Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$sign${CurrencyFormatter.formatCompact(transaction.amount)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Gap(6),
                  Text(
                    DateFormatter.formatRelative(transaction.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
