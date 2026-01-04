import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/enums/category_type.dart';
import '../providers/budget_providers.dart';
import '../../data/models/budget_model.dart';

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(currentMonthBudgetsProvider);
    final summaryAsync = ref.watch(budgetSummaryProvider);
    final now = DateTime.now();
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
            : Colors.grey.shade600;
    final progressBg = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Budget ${_getMonthName(now.month)} ${now.year}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentMonthBudgetsProvider);
          ref.invalidate(budgetSummaryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(8), // Top spacing for visual appeal
              
              // Summary Card
              summaryAsync.when(
                data: (summary) => _buildSummaryCard(summary, isDark, isAmoled, textSecondary, progressBg),
                loading: () => const _LoadingSummaryCard(),
                error: (e, _) => Text('Error: $e'),
              ),

              const Gap(24),

              // Budgets List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget Kategori',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyFromPreviousMonth(),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Salin Bulan Lalu'),
                  ),
                ],
              ),

              const Gap(12),

              budgetsAsync.when(
                data: (budgets) {
                  if (budgets.isEmpty) {
                    return _buildEmptyState(textSecondary);
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: budgets.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (context, index) {
                      return _BudgetCard(
                        budget: budgets[index],
                        onEdit: () => _showEditBudgetDialog(budgets[index]),
                        onDelete: () => _deleteBudget(budgets[index]),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),

              const Gap(100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BudgetSummary summary, bool isDark, bool isAmoled, Color textSecondary, Color progressBg) {
    final cardColor = isAmoled 
        ? AppColors.cardBackgroundAmoled 
        : isDark 
            ? AppColors.cardBackgroundDark 
            : Colors.white;
    
    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Budget',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const Gap(4),
                    Text(
                      CurrencyFormatter.format(summary.totalBudget),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getProgressColor(summary.percentUsed)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${summary.percentUsed.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getProgressColor(summary.percentUsed),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (summary.percentUsed / 100).clamp(0.0, 1.0),
                backgroundColor: progressBg,
                valueColor: AlwaysStoppedAnimation(
                  _getProgressColor(summary.percentUsed),
                ),
                minHeight: 8,
              ),
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniStat(
                  'Terpakai',
                  CurrencyFormatter.formatCompact(summary.totalSpent),
                  AppColors.expense,
                  textSecondary,
                ),
                _buildMiniStat(
                  'Sisa',
                  CurrencyFormatter.formatCompact(summary.remaining),
                  AppColors.income,
                  textSecondary,
                ),
                _buildMiniStat(
                  'Melebihi',
                  '${summary.overBudgetCount}',
                  Colors.red,
                  textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color, Color labelColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
          ),
        ),
        const Gap(4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color textSecondary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: textSecondary.withValues(alpha: 0.6),
          ),
          const Gap(16),
          Text(
            'Belum ada budget',
            style: TextStyle(
              fontSize: 18,
              color: textSecondary,
            ),
          ),
          const Gap(8),
          Text(
            'Tap + untuk menambahkan budget',
            style: TextStyle(
              color: textSecondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percent) {
    if (percent >= 100) return Colors.red;
    if (percent >= 80) return Colors.orange;
    return AppColors.income;
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  void _showAddBudgetDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _BudgetFormSheet(
        onSave: (budget) async {
          final actions = ref.read(budgetActionsProvider.notifier);
          await actions.addBudget(budget);
          ref.invalidate(currentMonthBudgetsProvider);
          ref.invalidate(budgetSummaryProvider);
        },
      ),
    );
  }

  void _showEditBudgetDialog(BudgetModel budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _BudgetFormSheet(
        budget: budget,
        onSave: (updatedBudget) async {
          final actions = ref.read(budgetActionsProvider.notifier);
          await actions.updateBudget(updatedBudget);
          ref.invalidate(currentMonthBudgetsProvider);
          ref.invalidate(budgetSummaryProvider);
        },
      ),
    );
  }

  void _deleteBudget(BudgetModel budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Budget'),
        content: Text('Yakin ingin menghapus budget "${budget.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && budget.id != null) {
      final actions = ref.read(budgetActionsProvider.notifier);
      await actions.deleteBudget(budget.id!);
      ref.invalidate(currentMonthBudgetsProvider);
      ref.invalidate(budgetSummaryProvider);
    }
  }

  void _copyFromPreviousMonth() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salin Budget'),
        content: const Text(
          'Ini akan menyalin semua budget dari bulan lalu. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salin'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final actions = ref.read(budgetActionsProvider.notifier);
      await actions.copyFromPreviousMonth();
      ref.invalidate(currentMonthBudgetsProvider);
      ref.invalidate(budgetSummaryProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget berhasil disalin')),
        );
      }
    }
  }
}

// Loading placeholder
class _LoadingSummaryCard extends ConsumerWidget {
  const _LoadingSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final isAmoled = ref.watch(isAmoledModeProvider);
    
    final cardColor = isAmoled 
        ? AppColors.cardBackgroundAmoled 
        : isDark 
            ? AppColors.cardBackgroundDark 
            : Colors.white;
    final shimmerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    
    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Gap(8),
                    Container(
                      width: 120,
                      height: 24,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(16),
            LinearProgressIndicator(
              backgroundColor: shimmerColor,
            ),
          ],
        ),
      ),
    );
  }
}

// Budget Card Widget
class _BudgetCard extends ConsumerWidget {
  final BudgetModel budget;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.budget,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = budget.percentUsed;
    final isDark = ref.watch(isDarkModeProvider);
    final isAmoled = ref.watch(isAmoledModeProvider);
    
    final cardColor = isAmoled 
        ? AppColors.cardBackgroundAmoled 
        : isDark 
            ? AppColors.cardBackgroundDark 
            : Colors.white;
    final textSecondary = isAmoled 
        ? AppColors.textSecondaryAmoled 
        : isDark 
            ? AppColors.textSecondaryDark 
            : Colors.grey.shade600;
    final progressBg = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Card(
      color: cardColor,
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
                    color: _getCategoryColor(budget.categoryName)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(budget.categoryName),
                    color: _getCategoryColor(budget.categoryName),
                    size: 20,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${CurrencyFormatter.format(budget.spent)} / ${CurrencyFormatter.format(budget.amount)}',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          Gap(8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          Gap(8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                ),
              ],
            ),
            const Gap(12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (progress / 100).clamp(0.0, 1.0),
                backgroundColor: progressBg,
                valueColor: AlwaysStoppedAnimation(_getProgressColor(progress)),
                minHeight: 6,
              ),
            ),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sisa: ${CurrencyFormatter.format(budget.remaining)}',
                  style: TextStyle(
                    color: budget.remaining >= 0
                        ? AppColors.income
                        : Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                if (budget.isOverBudget)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Melebihi',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (budget.isWarning)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Hampir habis',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double percent) {
    if (percent >= 100) return Colors.red;
    if (percent >= 80) return Colors.orange;
    return AppColors.income;
  }

  Color _getCategoryColor(String? categoryName) {
    if (categoryName == null) return AppColors.primary;
    try {
      final category =
          CategoryType.values.firstWhere((e) => e.name == categoryName);
      return category.color;
    } catch (_) {
      return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String? categoryName) {
    if (categoryName == null) return Icons.category;
    try {
      final category =
          CategoryType.values.firstWhere((e) => e.name == categoryName);
      return category.icon;
    } catch (_) {
      return Icons.category;
    }
  }
}

// Budget Form Sheet
class _BudgetFormSheet extends StatefulWidget {
  final BudgetModel? budget;
  final Function(BudgetModel) onSave;

  const _BudgetFormSheet({
    this.budget,
    required this.onSave,
  });

  @override
  State<_BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<_BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  String? _selectedCategory;

  bool get _isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.budget?.name);
    _amountController = TextEditingController(
      text: widget.budget?.amount.toStringAsFixed(0),
    );
    _selectedCategory = widget.budget?.categoryName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Edit Budget' : 'Tambah Budget',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Gap(24),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Budget',
                  hintText: 'Contoh: Makan Bulan Ini',
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
                  labelText: 'Jumlah Budget',
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah wajib diisi';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Jumlah tidak valid';
                  }
                  return null;
                },
              ),

              const Gap(16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori (Opsional)',
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Umum'),
                  ),
                  ...CategoryType.values
                      .where((c) => !c.isIncome)
                      .map((category) => DropdownMenuItem(
                            value: category.name,
                            child: Row(
                              children: [
                                Icon(category.icon,
                                    size: 20, color: category.color),
                                const Gap(8),
                                Text(category.displayName),
                              ],
                            ),
                          )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),

              const Gap(24),

              // Save button
              FilledButton(
                onPressed: _save,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(_isEditing ? 'Simpan' : 'Tambah'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final budget = _isEditing
        ? widget.budget!.copyWith(
            name: _nameController.text,
            amount: double.parse(_amountController.text),
            categoryName: _selectedCategory,
          )
        : BudgetModel(
            name: _nameController.text,
            amount: double.parse(_amountController.text),
            month: now.month,
            year: now.year,
            categoryName: _selectedCategory,
          );

    widget.onSave(budget);
    Navigator.pop(context);
  }
}
