// lib/features/recurring/presentation/pages/recurring_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/enums/recurrence_type.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/enums/category_type.dart';
import '../providers/recurring_providers.dart';
import '../../data/models/recurring_transaction_model.dart';

class RecurringPage extends ConsumerStatefulWidget {
  const RecurringPage({super.key});

  @override
  ConsumerState<RecurringPage> createState() => _RecurringPageState();
}

class _RecurringPageState extends ConsumerState<RecurringPage> with SingleTickerProviderStateMixin {
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
    final recurringState = ref.watch(recurringNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Berulang'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pengeluaran'),
            Tab(text: 'Pemasukan'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(recurringNotifierProvider.notifier).loadRecurring(),
          ),
        ],
      ),
      body: recurringState.when(
        data: (recurring) {
          final expenses = recurring.where((r) => r.type == TransactionType.expense).toList();
          final incomes = recurring.where((r) => r.type == TransactionType.income).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRecurringList(expenses, TransactionType.expense, isDark),
              _buildRecurringList(incomes, TransactionType.income, isDark),
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
                onPressed: () => ref.read(recurringNotifierProvider.notifier).loadRecurring(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecurringDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildRecurringList(List<RecurringTransactionModel> items, TransactionType type, bool isDark) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.repeat,
              size: 64,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            const Gap(16),
            Text(
              type == TransactionType.expense
                  ? 'Belum ada pengeluaran berulang'
                  : 'Belum ada pemasukan berulang',
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
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildRecurringCard(item, isDark);
      },
    );
  }

  Widget _buildRecurringCard(RecurringTransactionModel recurring, bool isDark) {
    final isExpense = recurring.type == TransactionType.expense;
    final color = isExpense ? AppColors.expense : AppColors.income;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRecurringDetails(recurring),
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
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(recurring.category.icon, color: color, size: 24),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recurring.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          recurring.category.displayName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isExpense ? '-' : '+'} ${CurrencyFormatter.format(recurring.amount)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        recurring.recurrence.displayName,
                        style: Theme.of(context).textTheme.bodySmall,
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
                        Icons.schedule,
                        size: 16,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                      const Gap(4),
                      Text(
                        recurring.nextDueDate != null
                            ? 'Berikutnya: ${_formatDate(recurring.nextDueDate!)}'
                            : 'Tidak terjadwal',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (recurring.autoCreate) ...[
                        const Icon(Icons.auto_mode, size: 16, color: AppColors.success),
                        const Gap(4),
                        Text(
                          'Auto',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.success,
                              ),
                        ),
                      ],
                      const Gap(8),
                      Switch(
                        value: recurring.isActive,
                        onChanged: (value) {
                          if (recurring.id != null) {
                            ref.read(recurringNotifierProvider.notifier)
                                .toggleActive(recurring.id!, value);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showRecurringDetails(RecurringTransactionModel recurring) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _RecurringDetailsSheet(recurring: recurring),
    );
  }

  void _showAddRecurringDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddRecurringSheet(),
    );
  }
}

class _RecurringDetailsSheet extends ConsumerWidget {
  final RecurringTransactionModel recurring;

  const _RecurringDetailsSheet({required this.recurring});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense = recurring.type == TransactionType.expense;
    final color = isExpense ? AppColors.expense : AppColors.income;

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
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(recurring.category.icon, color: color, size: 32),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recurring.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          recurring.category.displayName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(24),
              _buildDetailRow('Jumlah', CurrencyFormatter.format(recurring.amount)),
              _buildDetailRow('Tipe', isExpense ? 'Pengeluaran' : 'Pemasukan'),
              _buildDetailRow('Frekuensi', recurring.recurrence.displayName),
              _buildDetailRow('Status', recurring.isActive ? 'Aktif' : 'Nonaktif'),
              _buildDetailRow('Auto-create', recurring.autoCreate ? 'Ya' : 'Tidak'),
              if (recurring.nextDueDate != null)
                _buildDetailRow('Berikutnya', _formatDate(recurring.nextDueDate!)),
              if (recurring.note != null && recurring.note!.isNotEmpty)
                _buildDetailRow('Catatan', recurring.note!),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Show edit dialog
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus?'),
                            content: Text('Hapus "${recurring.name}" dari transaksi berulang?'),
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
                        if (confirm == true && recurring.id != null) {
                          ref.read(recurringNotifierProvider.notifier).deleteRecurring(recurring.id!);
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.expense,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AddRecurringSheet extends ConsumerStatefulWidget {
  const _AddRecurringSheet();

  @override
  ConsumerState<_AddRecurringSheet> createState() => _AddRecurringSheetState();
}

class _AddRecurringSheetState extends ConsumerState<_AddRecurringSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  CategoryType _category = CategoryType.other;
  RecurrenceType _recurrence = RecurrenceType.monthly;
  DateTime _startDate = DateTime.now();
  bool _autoCreate = true;
  final int _reminderDays = 3;

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
                  'Tambah Transaksi Berulang',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Gap(24),
                
                // Transaction Type
                Text('Tipe', style: Theme.of(context).textTheme.titleSmall),
                const Gap(8),
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Pengeluaran'),
                      icon: Icon(Icons.remove_circle_outline),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Pemasukan'),
                      icon: Icon(Icons.add_circle_outline),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (Set<TransactionType> selected) {
                    setState(() => _type = selected.first);
                  },
                ),
                const Gap(16),
                
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    hintText: 'Contoh: Gaji Bulanan, Langganan Netflix',
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
                    if (double.tryParse(value.replaceAll('.', '')) == null) {
                      return 'Jumlah tidak valid';
                    }
                    return null;
                  },
                ),
                const Gap(16),
                
                // Category Dropdown
                DropdownButtonFormField<CategoryType>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: CategoryType.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(cat.icon, size: 20),
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
                
                // Recurrence Dropdown
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
                const Gap(16),
                
                // Start Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tanggal Mulai'),
                  subtitle: Text(_formatDate(_startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _startDate = picked);
                    }
                  },
                ),
                const Gap(16),
                
                // Auto Create Switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Buat Transaksi Otomatis'),
                  subtitle: const Text('Buat transaksi secara otomatis saat jatuh tempo'),
                  value: _autoCreate,
                  onChanged: (value) => setState(() => _autoCreate = value),
                ),
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
                
                // Submit Button
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    final amount = double.parse(_amountController.text.replaceAll('.', ''));
    
    final recurring = RecurringTransactionModel(
      name: _nameController.text,
      amount: amount,
      type: _type,
      category: _category,
      recurrence: _recurrence,
      startDate: _startDate,
      nextDueDate: _startDate,
      isActive: true,
      autoCreate: _autoCreate,
      reminderDaysBefore: _reminderDays,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      createdAt: DateTime.now(),
    );

    ref.read(recurringNotifierProvider.notifier).addRecurring(recurring);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berulang berhasil ditambahkan')),
    );
  }
}
