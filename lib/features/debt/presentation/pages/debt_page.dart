// lib/features/debt/presentation/pages/debt_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/debt_model.dart';
import '../providers/debt_providers.dart';
import '../widgets/debt_card.dart';

class DebtPage extends ConsumerStatefulWidget {
  const DebtPage({super.key});

  @override
  ConsumerState<DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends ConsumerState<DebtPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final totalDebt = ref.watch(totalDebtProvider);
    final totalReceivable = ref.watch(totalReceivableProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('debt_title')),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.tr('debt_i_owe')),
            Tab(text: l10n.tr('debt_owed_to_me')),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    l10n.tr('debt_total_owed'),
                    totalDebt.when(
                      data: (amount) => CurrencyFormatter.format(amount),
                      loading: () => '...',
                      error: (_, __) => 'Rp 0',
                    ),
                    Icons.trending_down,
                    Colors.red.shade300,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    l10n.tr('debt_total_receivable'),
                    totalReceivable.when(
                      data: (amount) => CurrencyFormatter.format(amount),
                      loading: () => '...',
                      error: (_, __) => 'Rp 0',
                    ),
                    Icons.trending_up,
                    Colors.green.shade300,
                  ),
                ),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDebtList(DebtType.iOwe),
                _buildDebtList(DebtType.owedToMe),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-debt'),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.tr('debt_add')),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const Gap(8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtList(DebtType type) {
    final provider = type == DebtType.iOwe ? myDebtsProvider : receivablesProvider;
    final debtsAsync = ref.watch(provider);

    return debtsAsync.when(
      data: (debts) {
        if (debts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == DebtType.iOwe ? Icons.money_off : Icons.attach_money,
                  size: 64,
                  color: Colors.grey,
                ),
                const Gap(16),
                Text(
                  type == DebtType.iOwe
                      ? 'Tidak ada hutang'
                      : 'Tidak ada piutang',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: debts.length,
          itemBuilder: (context, index) {
            final debt = debts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DebtCard(
                debt: debt,
                onTap: () => _showDebtDetails(debt),
                onMarkPaid: () => _markAsPaid(debt),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  void _showDebtDetails(DebtModel debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => _buildDebtDetailsSheet(debt, controller),
      ),
    );
  }

  Widget _buildDebtDetailsSheet(DebtModel debt, ScrollController controller) {
    final l10n = context.l10n;
    
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(24),
      children: [
        // Handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        
        // Person Name
        Text(
          debt.personName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(8),
        
        // Amount
        Text(
          CurrencyFormatter.format(debt.amount),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: debt.type == DebtType.iOwe ? Colors.red : Colors.green,
          ),
        ),
        const Gap(24),
        
        // Details
        _buildDetailRow(l10n.tr('debt_status'), _getStatusText(debt.status, l10n)),
        if (debt.paidAmount > 0) ...[
          const Gap(12),
          _buildDetailRow(
            l10n.tr('debt_status_paid'),
            CurrencyFormatter.format(debt.paidAmount),
          ),
          _buildDetailRow(
            l10n.tr('debt_remaining'),
            CurrencyFormatter.format(debt.remainingAmount),
          ),
        ],
        const Gap(12),
        _buildDetailRow(
          l10n.tr('transaction_date'),
          DateFormat('dd MMM yyyy').format(debt.createdAt),
        ),
        if (debt.dueDate != null) ...[
          const Gap(12),
          _buildDetailRow(
            l10n.tr('debt_due_date'),
            DateFormat('dd MMM yyyy').format(debt.dueDate!),
            isOverdue: debt.isOverdue,
          ),
        ],
        if (debt.note != null && debt.note!.isNotEmpty) ...[
          const Gap(12),
          _buildDetailRow(l10n.tr('transaction_note'), debt.note!),
        ],
        const Gap(32),
        
        // Actions
        if (debt.status != DebtStatus.paid) ...[
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _markAsPaid(debt);
            },
            icon: const Icon(Icons.check_circle),
            label: Text(l10n.tr('debt_mark_paid')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const Gap(12),
        ],
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            _deleteDebt(debt);
          },
          icon: const Icon(Icons.delete),
          label: Text(l10n.tr('delete')),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isOverdue = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isOverdue ? Colors.red : null,
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText(DebtStatus status, AppLocalizations l10n) {
    switch (status) {
      case DebtStatus.pending:
        return l10n.tr('debt_status_pending');
      case DebtStatus.partial:
        return l10n.tr('debt_status_partial');
      case DebtStatus.paid:
        return l10n.tr('debt_status_paid');
    }
  }

  void _markAsPaid(DebtModel debt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.tr('confirm')),
        content: Text('Tandai hutang ke ${debt.personName} sebagai lunas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.tr('yes')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(debtNotifierProvider.notifier).markAsPaid(debt.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.tr('success'))),
        );
      }
    }
  }

  void _deleteDebt(DebtModel debt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.tr('confirm')),
        content: Text('Hapus hutang ke ${debt.personName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.l10n.tr('delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(debtNotifierProvider.notifier).deleteDebt(debt.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.tr('transaction_deleted'))),
        );
      }
    }
  }
}
