import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/transaction_providers.dart';

class TransactionDetailPage extends ConsumerWidget {
  final int transactionId;

  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(transactionByIdProvider(transactionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/edit-transaction/$transactionId');
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _showDeleteDialog(context, ref),
            icon: const Icon(Icons.delete_outline, color: AppColors.expense),
          ),
        ],
      ),
      body: transactionAsync.when(
        data: (transaction) {
          if (transaction == null) {
            return const Center(child: Text('Transaksi tidak ditemukan'));
          }

          final isExpense = transaction.type == TransactionType.expense;
          final color = isExpense ? AppColors.expense : AppColors.income;
          final sign = isExpense ? '-' : '+';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        transaction.category.icon,
                        size: 48,
                        color: transaction.category.color,
                      ),
                      const Gap(12),
                      Text(
                        '$sign${CurrencyFormatter.format(transaction.amount)}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        transaction.description,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Gap(24),

                // Details
                _buildDetailItem(
                  context,
                  icon: Icons.category_outlined,
                  label: 'Kategori',
                  value: transaction.category.displayName,
                ),
                _buildDetailItem(
                  context,
                  icon: Icons.calendar_today_outlined,
                  label: 'Tanggal',
                  value: DateFormatter.formatFull(transaction.date),
                ),
                _buildDetailItem(
                  context,
                  icon: isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                  label: 'Tipe',
                  value: transaction.type.displayName,
                  valueColor: color,
                ),
                if (transaction.mood != null)
                  _buildDetailItem(
                    context,
                    icon: Icons.mood,
                    label: 'Mood',
                    value: '${transaction.mood!.emoji} ${transaction.mood!.displayName}',
                  ),
                if (transaction.note != null && transaction.note!.isNotEmpty)
                  _buildDetailItem(
                    context,
                    icon: Icons.notes_outlined,
                    label: 'Catatan',
                    value: transaction.note!,
                  ),
                const Divider(height: 32),
                _buildDetailItem(
                  context,
                  icon: Icons.access_time,
                  label: 'Dibuat',
                  value: DateFormatter.formatFull(transaction.createdAt),
                  isSmall: true,
                ),
                if (transaction.updatedAt != null)
                  _buildDetailItem(
                    context,
                    icon: Icons.update,
                    label: 'Terakhir diubah',
                    value: DateFormatter.formatFull(transaction.updatedAt!),
                    isSmall: true,
                  ),
                _buildDetailItem(
                  context,
                  icon: transaction.isSynced ? Icons.cloud_done : Icons.cloud_off,
                  label: 'Status Sync',
                  value: transaction.isSynced ? 'Tersinkronisasi' : 'Belum disinkronisasi',
                  valueColor: transaction.isSynced ? AppColors.income : AppColors.textSecondary,
                  isSmall: true,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isSmall = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: isSmall ? 18 : 22,
            color: AppColors.textSecondary,
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Gap(2),
                Text(
                  value,
                  style: isSmall
                      ? Theme.of(context).textTheme.bodyMedium?.copyWith(color: valueColor)
                      : Theme.of(context).textTheme.titleMedium?.copyWith(color: valueColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text('Transaksi yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(transactionActionsProvider.notifier)
                  .deleteTransaction(transactionId);
              
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaksi berhasil dihapus'),
                      backgroundColor: AppColors.income,
                    ),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus transaksi'),
                      backgroundColor: AppColors.expense,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
  }
}
