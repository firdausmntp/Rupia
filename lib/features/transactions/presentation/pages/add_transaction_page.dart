import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/enums/category_type.dart';
import '../../../../core/enums/mood_type.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/mood_suggestion_service.dart';
import '../providers/transaction_providers.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  final int? transactionId;
  final Map<String, dynamic>? prefilledData;

  const AddTransactionPage({super.key, this.transactionId, this.prefilledData});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  CategoryType _category = CategoryType.food;
  MoodType? _mood;
  MoodType? _suggestedMood; // For auto-suggestion
  DateTime _date = DateTime.now();
  bool _isLoading = false;
  bool _isEditing = false;
  TransactionModel? _existingTransaction;

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      _isEditing = true;
      _loadTransaction();
    } else if (widget.prefilledData != null) {
      _prefillFromOcr();
    }
    _updateSuggestedMood();
  }

  void _updateSuggestedMood() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    _suggestedMood = MoodSuggestionService.suggestMood(
      category: _category,
      type: _type,
      transactionTime: _date,
      amount: amount,
    );
    // Auto-set mood if not editing and mood not manually changed
    if (!_isEditing && _mood == null) {
      _mood = _suggestedMood;
    }
  }

  void _prefillFromOcr() {
    final data = widget.prefilledData!;
    if (data['amount'] != null) {
      _amountController.text = data['amount'].toString();
    }
    if (data['description'] != null) {
      _descriptionController.text = data['description'];
    }
    if (data['date'] != null) {
      _date = data['date'];
    }
    if (data['category'] != null) {
      _category = data['category'];
    }
  }

  Future<void> _loadTransaction() async {
    final transaction = await ref
        .read(transactionRepositoryProvider)
        .getTransactionById(widget.transactionId!);
    
    if (transaction != null) {
      setState(() {
        _existingTransaction = transaction;
        _amountController.text = transaction.amount.toStringAsFixed(0);
        _descriptionController.text = transaction.description;
        _noteController.text = transaction.note ?? '';
        _type = transaction.type;
        _category = transaction.category;
        _mood = transaction.mood;
        _date = transaction.date;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final isAmoled = ref.watch(isAmoledModeProvider);
    
    final backgroundColor = isAmoled 
        ? AppColors.backgroundAmoled 
        : isDark 
            ? AppColors.backgroundDark 
            : AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaksi' : 'Tambah Transaksi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type Toggle
              _buildTypeToggle(),
              const Gap(24),

              // Amount Input
              _buildAmountInput(),
              const Gap(20),

              // Description Input
              _buildDescriptionInput(),
              const Gap(20),

              // Category Selection
              _buildCategorySelection(),
              const Gap(20),

              // Date Selection
              _buildDateSelection(),
              const Gap(20),

              // Mood Selection (Optional)
              _buildMoodSelection(),
              const Gap(20),

              // Note Input (Optional)
              _buildNoteInput(),
              const Gap(32),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    final isDark = ref.watch(isDarkModeProvider);
    final isAmoled = ref.watch(isAmoledModeProvider);
    final inputBgColor = isAmoled 
        ? AppColors.surfaceAmoled 
        : isDark 
            ? AppColors.surfaceDark 
            : AppColors.background;
    final borderColor = isAmoled 
        ? AppColors.borderAmoled 
        : isDark 
            ? AppColors.borderDark 
            : AppColors.border;
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: inputBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              title: 'Pengeluaran',
              icon: Icons.arrow_upward_rounded,
              isSelected: _type == TransactionType.expense,
              color: AppColors.expense,
              onTap: () => setState(() {
                _type = TransactionType.expense;
                _updateCategoryForType();
                _updateSuggestedMood();
              }),
            ),
          ),
          const Gap(4),
          Expanded(
            child: _TypeButton(
              title: 'Pemasukan',
              icon: Icons.arrow_downward_rounded,
              isSelected: _type == TransactionType.income,
              color: AppColors.income,
              onTap: () => setState(() {
                _type = TransactionType.income;
                _updateCategoryForType();
                _updateSuggestedMood();
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _updateCategoryForType() {
    if (_type == TransactionType.income && !_category.isIncomeCategory) {
      _category = CategoryType.salary;
    } else if (_type == TransactionType.expense && _category.isIncomeCategory) {
      _category = CategoryType.food;
    }
  }

  Widget _buildAmountInput() {
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jumlah',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Gap(14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor.withValues(alpha: 0.5)),
            boxShadow: isDark ? null : [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                'Rp',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
              const Gap(8),
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _type == TransactionType.expense 
                        ? AppColors.expense 
                        : AppColors.income,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah harus diisi';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Jumlah harus lebih dari 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Gap(8),
        TextFormField(
          controller: _descriptionController,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Contoh: Makan siang di warteg',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Deskripsi harus diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategorySelection() {
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
    final inputBgColor = isAmoled 
        ? AppColors.surfaceAmoled 
        : isDark 
            ? AppColors.surfaceDark 
            : AppColors.background;

    final categories = _type == TransactionType.income
        ? CategoryType.values.where((c) => c.isIncomeCategory).toList()
        : CategoryType.values.where((c) => !c.isIncomeCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Gap(12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor.withValues(alpha: 0.5)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final isSelected = _category == category;
              return GestureDetector(
                onTap: () => setState(() {
                  _category = category;
                  _updateSuggestedMood();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? category.color.withValues(alpha: 0.15) 
                        : inputBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? category.color.withValues(alpha: 0.5) 
                          : borderColor.withValues(alpha: 0.3),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon, 
                        size: 18, 
                        color: isSelected ? category.color : textSecondary,
                      ),
                      const Gap(6),
                      Text(
                        category.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? category.color : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelection() {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Gap(14),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border.all(color: borderColor.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                  ),
                  const Gap(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(_date),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Gap(2),
                        Text(
                          _getRelativeDate(_date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: textSecondary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;
    
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    if (diff == -1) return 'Besok';
    if (diff > 0 && diff <= 7) return '$diff hari yang lalu';
    return '';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _updateSuggestedMood();
      });
    }
  }

  Widget _buildMoodSelection() {
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
    final inputBgColor = isAmoled 
        ? AppColors.surfaceAmoled 
        : isDark 
            ? AppColors.surfaceDark 
            : AppColors.background;
    
    final moodExplanation = _mood != null 
        ? MoodSuggestionService.getMoodExplanation(_mood!, _category, _type)
        : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Mood',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(8),
            if (_suggestedMood != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _suggestedMood!.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 12, color: _suggestedMood!.color),
                    const Gap(4),
                    Text(
                      'saran: ${_suggestedMood!.emoji}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _suggestedMood!.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: inputBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'opsional',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
        const Gap(12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor.withValues(alpha: 0.5)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // None option
              GestureDetector(
                onTap: () => setState(() => _mood = null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _mood == null 
                        ? AppColors.primary.withValues(alpha: 0.1) 
                        : inputBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _mood == null 
                          ? AppColors.primary.withValues(alpha: 0.5) 
                          : borderColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Tidak dipilih',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: _mood == null ? FontWeight.w600 : FontWeight.normal,
                      color: _mood == null ? AppColors.primary : textSecondary,
                    ),
                  ),
                ),
              ),
              ...MoodType.values.map((mood) {
                final isSelected = _mood == mood;
                final isSuggested = _suggestedMood == mood;
                return GestureDetector(
                  onTap: () => setState(() => _mood = mood),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? mood.color.withValues(alpha: 0.15) 
                          : isSuggested
                              ? mood.color.withValues(alpha: 0.08)
                              : inputBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? mood.color.withValues(alpha: 0.5) 
                            : isSuggested
                                ? mood.color.withValues(alpha: 0.3)
                                : borderColor.withValues(alpha: 0.3),
                        width: isSuggested && !isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 16)),
                        const Gap(6),
                        Text(
                          mood.displayName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? mood.color : null,
                          ),
                        ),
                        if (isSuggested && !isSelected) ...[
                          const Gap(4),
                          Icon(Icons.auto_awesome, size: 12, color: mood.color.withValues(alpha: 0.6)),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        // Show mood explanation
        if (moodExplanation != null && _mood != null) ...[
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _mood!.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: _mood!.color),
                const Gap(8),
                Expanded(
                  child: Text(
                    moodExplanation,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _mood!.color,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNoteInput() {
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
            : AppColors.textSecondary;
    final inputBgColor = isAmoled 
        ? AppColors.surfaceAmoled 
        : isDark 
            ? AppColors.surfaceDark 
            : AppColors.background;
    final textTertiary = isAmoled 
        ? AppColors.textTertiaryAmoled 
        : isDark 
            ? AppColors.textTertiaryDark 
            : AppColors.textTertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Catatan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: inputBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'opsional',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textTertiary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const Gap(14),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Tambahkan catatan...',
            filled: true,
            fillColor: cardColor,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 8, bottom: 48),
              child: Icon(Icons.note_outlined, color: textSecondary, size: 22),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final isExpense = _type == TransactionType.expense;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitTransaction,
          style: ElevatedButton.styleFrom(
            backgroundColor: isExpense ? AppColors.expense : AppColors.income,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isEditing ? Icons.check_rounded : Icons.add_rounded, size: 22),
                    const Gap(8),
                    Text(
                      _isEditing ? 'Simpan Perubahan' : 'Tambah Transaksi',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final transaction = _isEditing && _existingTransaction != null
          ? _existingTransaction!.copyWith(
              amount: amount,
              description: _descriptionController.text,
              date: _date,
              type: _type,
              category: _category,
              mood: _mood,
              note: _noteController.text.isEmpty ? null : _noteController.text,
            )
          : TransactionModel(
              amount: amount,
              description: _descriptionController.text,
              date: _date,
              type: _type,
              category: _category,
              mood: _mood,
              note: _noteController.text.isEmpty ? null : _noteController.text,
            );

      final actions = ref.read(transactionActionsProvider.notifier);
      
      bool success;
      if (_isEditing) {
        success = await actions.updateTransaction(transaction);
      } else {
        final id = await actions.addTransaction(transaction);
        success = id != null;
      }

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (success) {
          // Invalidate providers to trigger immediate refresh
          ref.invalidate(currentMonthTransactionsProvider);
          ref.invalidate(dashboardSummaryProvider);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing
                  ? 'Transaksi berhasil diperbarui'
                  : 'Transaksi berhasil ditambahkan'),
              backgroundColor: AppColors.income,
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan transaksi'),
              backgroundColor: AppColors.expense,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }
}

class _TypeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? color : AppColors.textSecondary,
              ),
              const Gap(8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
