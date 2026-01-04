// lib/features/bills/presentation/pages/bills_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/enums/bill_status.dart';
import '../../../../core/enums/recurrence_type.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/bill_providers.dart';
import '../../data/models/bill_model.dart';

class BillsPage extends ConsumerStatefulWidget {
  const BillsPage({super.key});

  @override
  ConsumerState<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends ConsumerState<BillsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final billsState = ref.watch(billNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagihan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Belum Bayar'),
            Tab(text: 'Jatuh Tempo'),
            Tab(text: 'Sudah Bayar'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(billNotifierProvider.notifier).loadBills(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          _buildSummaryCard(isDark),
          // Bill Lists
          Expanded(
            child: billsState.when(
              data: (bills) {
                final pending = bills.where((b) => b.status == BillStatus.pending).toList();
                final overdue = bills.where((b) => b.status == BillStatus.overdue).toList();
                final paid = bills.where((b) => b.status == BillStatus.paid).toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBillList(pending, BillStatus.pending, isDark),
                    _buildBillList(overdue, BillStatus.overdue, isDark),
                    _buildBillList(paid, BillStatus.paid, isDark),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    const Gap(16),
                    ElevatedButton(
                      onPressed: () => ref.read(billNotifierProvider.notifier).loadBills(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBillDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Tagihan Baru'),
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    final pendingTotal = ref.watch(pendingBillsTotalProvider);
    final overdueCount = ref.watch(overdueBillsCountProvider);

    return Container(
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
              'Total Belum Bayar',
              pendingTotal.when(
                data: (amount) => CurrencyFormatter.format(amount),
                loading: () => '...',
                error: (_, __) => 'Rp 0',
              ),
              Icons.receipt_long,
              Colors.white,
            ),
          ),
          const Gap(16),
          Expanded(
            child: _buildSummaryItem(
              'Jatuh Tempo',
              overdueCount.when(
                data: (count) => '$count tagihan',
                loading: () => '...',
                error: (_, __) => '0',
              ),
              Icons.warning,
              Colors.red.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color iconColor) {
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
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillList(List<BillModel> bills, BillStatus status, bool isDark) {
    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(status),
              size: 64,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            const Gap(16),
            Text(
              _getEmptyMessage(status),
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return _buildBillCard(bill, isDark);
      },
    );
  }

  IconData _getEmptyIcon(BillStatus status) {
    switch (status) {
      case BillStatus.pending:
        return Icons.receipt_outlined;
      case BillStatus.overdue:
        return Icons.warning_outlined;
      case BillStatus.paid:
        return Icons.check_circle_outline;
      case BillStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _getEmptyMessage(BillStatus status) {
    switch (status) {
      case BillStatus.pending:
        return 'Tidak ada tagihan yang belum dibayar';
      case BillStatus.overdue:
        return 'Tidak ada tagihan jatuh tempo';
      case BillStatus.paid:
        return 'Belum ada tagihan yang dibayar';
      case BillStatus.cancelled:
        return 'Tidak ada tagihan dibatalkan';
    }
  }

  Widget _buildBillCard(BillModel bill, bool isDark) {
    final daysUntilDue = bill.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysUntilDue < 0;
    final isDueSoon = daysUntilDue >= 0 && daysUntilDue <= 3;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showBillDetails(bill),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bill.category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(bill.category.icon, color: bill.category.color, size: 24),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          bill.category.displayName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(bill.amount),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: bill.status.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          bill.status.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            color: bill.status.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(12),
              const Divider(height: 1),
              const Gap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isOverdue
                            ? AppColors.expense
                            : isDueSoon
                                ? AppColors.warning
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      ),
                      const Gap(4),
                      Text(
                        _getDueDateText(bill.dueDate, daysUntilDue),
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue
                              ? AppColors.expense
                              : isDueSoon
                                  ? AppColors.warning
                                  : null,
                          fontWeight: isOverdue || isDueSoon ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                  if (bill.status == BillStatus.pending || bill.status == BillStatus.overdue)
                    TextButton(
                      onPressed: () {
                        if (bill.id != null) {
                          ref.read(billNotifierProvider.notifier).markAsPaid(bill.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${bill.name} ditandai sudah dibayar')),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('Bayar'),
                    ),
                ],
              ),
              if (bill.isRecurring) ...[
                const Gap(8),
                Row(
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                    const Gap(4),
                    Text(
                      'Berulang ${bill.recurrence?.displayName ?? ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getDueDateText(DateTime dueDate, int daysUntilDue) {
    if (daysUntilDue < -1) {
      return 'Terlambat ${-daysUntilDue} hari';
    } else if (daysUntilDue == -1) {
      return 'Terlambat 1 hari';
    } else if (daysUntilDue == 0) {
      return 'Jatuh tempo hari ini';
    } else if (daysUntilDue == 1) {
      return 'Besok';
    } else if (daysUntilDue <= 7) {
      return '$daysUntilDue hari lagi';
    } else {
      return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    }
  }

  void _showBillDetails(BillModel bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _BillDetailsSheet(bill: bill),
    );
  }

  void _showAddBillDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddBillSheet(),
    );
  }
}

class _BillDetailsSheet extends ConsumerWidget {
  final BillModel bill;

  const _BillDetailsSheet({required this.bill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
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
              const Gap(24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bill.category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(bill.category.icon, color: bill.category.color, size: 32),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          bill.category.displayName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(24),
              _buildDetailRow('Jumlah', CurrencyFormatter.format(bill.amount)),
              _buildDetailRow('Status', bill.status.displayName),
              _buildDetailRow('Jatuh Tempo', '${bill.dueDate.day}/${bill.dueDate.month}/${bill.dueDate.year}'),
              _buildDetailRow('Berulang', bill.isRecurring ? (bill.recurrence?.displayName ?? 'Ya') : 'Tidak'),
              if (bill.note != null && bill.note!.isNotEmpty)
                _buildDetailRow('Catatan', bill.note!),
              const Gap(24),
              Row(
                children: [
                  if (bill.status != BillStatus.paid) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (bill.id != null) {
                            ref.read(billNotifierProvider.notifier).markAsPaid(bill.id!);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${bill.name} ditandai sudah dibayar')),
                            );
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Bayar'),
                      ),
                    ),
                    const Gap(12),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Tagihan?'),
                            content: Text('Hapus "${bill.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && bill.id != null) {
                          ref.read(billNotifierProvider.notifier).deleteBill(bill.id!);
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.expense,
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AddBillSheet extends ConsumerStatefulWidget {
  const _AddBillSheet();

  @override
  ConsumerState<_AddBillSheet> createState() => _AddBillSheetState();
}

class _AddBillSheetState extends ConsumerState<_AddBillSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  BillCategory _category = BillCategory.other;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isRecurring = false;
  RecurrenceType _recurrence = RecurrenceType.monthly;
  bool _enableReminder = true;
  int _reminderDays = 3;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                  'Tambah Tagihan',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Gap(24),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Tagihan',
                    hintText: 'Contoh: Listrik PLN, Internet, dll',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),
                const Gap(16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah',
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah wajib diisi';
                    }
                    return null;
                  },
                ),
                const Gap(16),

                // Category
                DropdownButtonFormField<BillCategory>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: BillCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(cat.icon, color: cat.color, size: 20),
                          const Gap(8),
                          Text(cat.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const Gap(16),

                // Due Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tanggal Jatuh Tempo'),
                  subtitle: Text('${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _dueDate = picked);
                    }
                  },
                ),
                const Gap(16),

                // Is Recurring
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tagihan Berulang'),
                  subtitle: const Text('Otomatis buat tagihan baru setelah pembayaran'),
                  value: _isRecurring,
                  onChanged: (value) => setState(() => _isRecurring = value),
                ),

                if (_isRecurring) ...[
                  const Gap(8),
                  DropdownButtonFormField<RecurrenceType>(
                    value: _recurrence,
                    decoration: const InputDecoration(labelText: 'Frekuensi'),
                    items: RecurrenceType.values.map((rec) {
                      return DropdownMenuItem(
                        value: rec,
                        child: Row(
                          children: [
                            Icon(rec.icon, size: 20),
                            const Gap(8),
                            Text(rec.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _recurrence = value);
                    },
                  ),
                ],
                const Gap(16),

                // Reminder
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Pengingat'),
                  subtitle: Text(_enableReminder
                      ? 'Ingatkan $_reminderDays hari sebelum jatuh tempo'
                      : 'Tidak ada pengingat'),
                  value: _enableReminder,
                  onChanged: (value) => setState(() => _enableReminder = value),
                ),

                if (_enableReminder) ...[
                  Slider(
                    value: _reminderDays.toDouble(),
                    min: 1,
                    max: 14,
                    divisions: 13,
                    label: '$_reminderDays hari',
                    onChanged: (value) => setState(() => _reminderDays = value.toInt()),
                  ),
                ],
                const Gap(16),

                // Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    hintText: 'Tambahkan catatan...',
                  ),
                  maxLines: 2,
                ),
                const Gap(24),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Simpan'),
                  ),
                ),
                const Gap(16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    final amount = double.parse(_amountController.text.replaceAll('.', '').replaceAll(',', ''));

    final bill = BillModel(
      name: _nameController.text,
      amount: amount,
      category: _category,
      dueDate: _dueDate,
      status: BillStatus.pending,
      isRecurring: _isRecurring,
      recurrence: _isRecurring ? _recurrence : null,
      reminderEnabled: _enableReminder,
      reminderDaysBefore: _enableReminder ? _reminderDays : 0,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      createdAt: DateTime.now(),
    );

    ref.read(billNotifierProvider.notifier).addBill(bill);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tagihan berhasil ditambahkan')),
    );
  }
}
