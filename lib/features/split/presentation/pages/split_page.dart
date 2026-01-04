// lib/features/split/presentation/pages/split_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/enums/category_type.dart';
import '../providers/split_providers.dart';
import '../../data/models/split_transaction_model.dart';

class SplitPage extends ConsumerStatefulWidget {
  const SplitPage({super.key});

  @override
  ConsumerState<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends ConsumerState<SplitPage> with SingleTickerProviderStateMixin {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final splitState = ref.watch(splitNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Bill'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Selesai'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(splitNotifierProvider.notifier).loadSplits(),
          ),
        ],
      ),
      body: splitState.when(
        data: (splits) {
          final activeSplits = splits.where((s) => !s.isFullyPaid).toList();
          final completedSplits = splits.where((s) => s.isFullyPaid).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSplitList(activeSplits, false, isDark),
              _buildSplitList(completedSplits, true, isDark),
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
                onPressed: () => ref.read(splitNotifierProvider.notifier).loadSplits(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSplitDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Split Baru'),
      ),
    );
  }

  Widget _buildSplitList(List<SplitTransactionModel> splits, bool isCompleted, bool isDark) {
    if (splits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle_outline : Icons.group_outlined,
              size: 64,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            const Gap(16),
            Text(
              isCompleted
                  ? 'Belum ada split yang selesai'
                  : 'Belum ada split aktif',
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
      itemCount: splits.length,
      itemBuilder: (context, index) {
        final split = splits[index];
        return _buildSplitCard(split, isDark);
      },
    );
  }

  Widget _buildSplitCard(SplitTransactionModel split, bool isDark) {
    final paidAmount = split.items.where((i) => i.status == SplitPaymentStatus.paid)
        .fold(0.0, (sum, item) => sum + item.amount);
    final progress = split.totalAmount > 0 ? paidAmount / split.totalAmount : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showSplitDetails(split),
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 24),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          split.description,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${split.items.length} orang',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(split.totalAmount),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: split.isFullyPaid
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          split.isFullyPaid ? 'Lunas' : 'Belum Lunas',
                          style: TextStyle(
                            fontSize: 10,
                            color: split.isFullyPaid ? AppColors.success : AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(16),

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Terkumpul: ${CurrencyFormatter.format(paidAmount)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Gap(12),

              // Participants Preview
              Wrap(
                spacing: 8,
                children: split.items.take(5).map((item) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: item.status == SplitPaymentStatus.paid
                          ? AppColors.success
                          : AppColors.warning,
                      radius: 12,
                      child: Icon(
                        item.status == SplitPaymentStatus.paid
                            ? Icons.check
                            : Icons.schedule,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    label: Text(
                      item.participantName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSplitDetails(SplitTransactionModel split) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SplitDetailsSheet(split: split),
    );
  }

  void _showAddSplitDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddSplitSheet(),
    );
  }
}

class _SplitDetailsSheet extends ConsumerWidget {
  final SplitTransactionModel split;

  const _SplitDetailsSheet({required this.split});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 32),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          split.description,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          split.splitType.displayName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(24),

              // Total Amount
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total'),
                    Text(
                      CurrencyFormatter.format(split.totalAmount),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
              ),
              const Gap(24),

              // Participants List
              Text(
                'Peserta (${split.items.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(12),
              ...split.items.map((item) => _buildParticipantTile(context, ref, item)),
              const Gap(24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Share functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur share akan segera hadir')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Bagikan'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Split?'),
                            content: Text('Hapus "${split.description}"?'),
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
                        if (confirm == true && split.id != null) {
                          ref.read(splitNotifierProvider.notifier).deleteSplit(split.id!);
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

  Widget _buildParticipantTile(BuildContext context, WidgetRef ref, SplitItemModel item) {
    final isPaid = item.status == SplitPaymentStatus.paid;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPaid ? AppColors.success : AppColors.warning,
          child: Icon(
            isPaid ? Icons.check : Icons.schedule,
            color: Colors.white,
          ),
        ),
        title: Text(item.participantName),
        subtitle: Text(
          isPaid ? 'Sudah bayar' : 'Belum bayar',
          style: TextStyle(
            color: isPaid ? AppColors.success : AppColors.warning,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(item.amount),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (!isPaid)
              TextButton(
                onPressed: () {
                  if (item.id != null) {
                    ref.read(splitNotifierProvider.notifier).markItemAsPaid(item.id!);
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Tandai Lunas', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddSplitSheet extends ConsumerStatefulWidget {
  const _AddSplitSheet();

  @override
  ConsumerState<_AddSplitSheet> createState() => _AddSplitSheetState();
}

class _AddSplitSheetState extends ConsumerState<_AddSplitSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _totalController = TextEditingController();
  final _noteController = TextEditingController();

  SplitType _splitType = SplitType.equal;
  CategoryType _category = CategoryType.food;
  final List<_ParticipantEntry> _participants = [
    _ParticipantEntry(),
    _ParticipantEntry(),
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _totalController.dispose();
    _noteController.dispose();
    for (var p in _participants) {
      p.dispose();
    }
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
                  'Split Bill Baru',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Gap(24),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Contoh: Makan malam bersama',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi wajib diisi';
                    }
                    return null;
                  },
                ),
                const Gap(16),

                // Category
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

                // Total Amount
                TextFormField(
                  controller: _totalController,
                  decoration: const InputDecoration(
                    labelText: 'Total Tagihan',
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _updateSplitAmounts(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Total wajib diisi';
                    }
                    return null;
                  },
                ),
                const Gap(16),

                // Split Type
                Text('Tipe Split', style: Theme.of(context).textTheme.titleSmall),
                const Gap(8),
                SegmentedButton<SplitType>(
                  segments: const [
                    ButtonSegment(
                      value: SplitType.equal,
                      label: Text('Sama Rata'),
                      icon: Icon(Icons.balance),
                    ),
                    ButtonSegment(
                      value: SplitType.custom,
                      label: Text('Kustom'),
                      icon: Icon(Icons.tune),
                    ),
                  ],
                  selected: {_splitType},
                  onSelectionChanged: (Set<SplitType> selected) {
                    setState(() => _splitType = selected.first);
                    _updateSplitAmounts();
                  },
                ),
                const Gap(24),

                // Participants
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Peserta', style: Theme.of(context).textTheme.titleSmall),
                    TextButton.icon(
                      onPressed: _addParticipant,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah'),
                    ),
                  ],
                ),
                const Gap(8),
                ..._participants.asMap().entries.map((entry) {
                  final index = entry.key;
                  final participant = entry.value;
                  return _buildParticipantField(index, participant);
                }),
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
                    child: const Text('Buat Split Bill'),
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

  Widget _buildParticipantField(int index, _ParticipantEntry participant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: participant.nameController,
                decoration: InputDecoration(
                  labelText: 'Nama ${index + 1}',
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Wajib';
                  }
                  return null;
                },
              ),
            ),
            const Gap(12),
            Expanded(
              child: TextFormField(
                controller: participant.amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  prefixText: 'Rp ',
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                enabled: _splitType == SplitType.custom,
              ),
            ),
            if (_participants.length > 2)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.expense),
                onPressed: () => _removeParticipant(index),
              ),
          ],
        ),
      ),
    );
  }

  void _addParticipant() {
    setState(() {
      _participants.add(_ParticipantEntry());
    });
    _updateSplitAmounts();
  }

  void _removeParticipant(int index) {
    setState(() {
      _participants[index].dispose();
      _participants.removeAt(index);
    });
    _updateSplitAmounts();
  }

  void _updateSplitAmounts() {
    if (_splitType != SplitType.equal) return;

    final totalText = _totalController.text.replaceAll('.', '').replaceAll(',', '');
    final total = double.tryParse(totalText) ?? 0;
    final perPerson = _participants.isNotEmpty ? total / _participants.length : 0;

    for (var p in _participants) {
      p.amountController.text = perPerson.toStringAsFixed(0);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    final totalAmount = double.parse(_totalController.text.replaceAll('.', '').replaceAll(',', ''));

    final items = _participants.map((p) {
      final amount = _splitType == SplitType.equal
          ? totalAmount / _participants.length
          : double.parse(p.amountController.text.replaceAll('.', '').replaceAll(',', ''));
      return SplitItemModel(
        splitTransactionId: 0, // Will be set after insert
        participantName: p.nameController.text,
        amount: amount,
        status: SplitPaymentStatus.pending,
      );
    }).toList();

    final split = SplitTransactionModel(
      description: _descriptionController.text,
      totalAmount: totalAmount,
      category: _category,
      date: DateTime.now(),
      splitType: _splitType,
      items: items,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      createdAt: DateTime.now(),
    );

    ref.read(splitNotifierProvider.notifier).addSplit(split);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Split bill berhasil dibuat')),
    );
  }
}

class _ParticipantEntry {
  final nameController = TextEditingController();
  final amountController = TextEditingController();

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}
