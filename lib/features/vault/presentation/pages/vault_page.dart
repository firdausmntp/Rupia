// lib/features/vault/presentation/pages/vault_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/vault_model.dart';
import '../../data/services/vault_service.dart';
import '../providers/vault_providers.dart';

class VaultPage extends ConsumerWidget {
  const VaultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultsAsync = ref.watch(userVaultsProvider);
    final pendingAsync = ref.watch(pendingInvitationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showInvitations(context, ref, pendingAsync),
          ),
        ],
      ),
      body: vaultsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (vaults) => vaults.isEmpty
            ? _buildEmptyState(context)
            : _buildVaultList(context, ref, vaults),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Buat Vault'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: 80, color: Colors.grey.shade400),
            const Gap(16),
            Text(
              'Belum ada Shared Vault',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(8),
            Text(
              'Buat vault bersama untuk berbagi pengeluaran dengan pasangan atau keluarga',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultList(
    BuildContext context,
    WidgetRef ref,
    List<VaultModel> vaults,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vaults.length,
      itemBuilder: (context, index) {
        final vault = vaults[index];
        return _buildVaultCard(context, ref, vault);
      },
    );
  }

  Widget _buildVaultCard(
    BuildContext context,
    WidgetRef ref,
    VaultModel vault,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openVaultDetail(context, vault),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.group, color: AppColors.primary),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vault.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${vault.memberCount} anggota',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (vault.isOwner)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Owner',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const Gap(16),
              Consumer(
                builder: (context, ref, _) {
                  final summaryAsync = ref.watch(
                    vaultSummaryProvider(vault.id),
                  );
                  return summaryAsync.when(
                    loading: () => const SizedBox(height: 40),
                    error: (_, __) => const SizedBox(),
                    data: (summary) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat(
                          'Total Pengeluaran',
                          CurrencyFormatter.format(summary.totalExpense),
                        ),
                        _buildStat(
                          'Transaksi',
                          summary.transactionCount.toString(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Vault Baru'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nama Vault',
            hintText: 'cth: Keuangan Keluarga',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              ref.read(vaultNotifierProvider.notifier)
                  .createVault(nameController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }

  void _showInvitations(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<VaultModel>> pendingAsync,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Undangan Vault',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(16),
            pendingAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (invitations) {
                if (invitations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('Tidak ada undangan'),
                    ),
                  );
                }
                return Column(
                  children: invitations.map((vault) => ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.group),
                    ),
                    title: Text(vault.name),
                    subtitle: Text('Dari: ${vault.ownerEmail}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            ref.read(vaultNotifierProvider.notifier)
                                .leaveVault(vault.id);
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            ref.read(vaultNotifierProvider.notifier)
                                .acceptInvitation(vault.id);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openVaultDetail(BuildContext context, VaultModel vault) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaultDetailPage(vault: vault),
      ),
    );
  }
}

class VaultDetailPage extends ConsumerWidget {
  final VaultModel vault;

  const VaultDetailPage({super.key, required this.vault});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(vaultTransactionsProvider(vault.id));
    final summaryAsync = ref.watch(vaultSummaryProvider(vault.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(vault.name),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'invite',
                child: ListTile(
                  leading: Icon(Icons.person_add),
                  title: Text('Undang Anggota'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'members',
                child: ListTile(
                  leading: Icon(Icons.people),
                  title: Text('Lihat Anggota'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (vault.isOwner)
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Hapus Vault', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              else
                const PopupMenuItem(
                  value: 'leave',
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app, color: Colors.orange),
                    title: Text('Keluar Vault', style: TextStyle(color: Colors.orange)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'invite':
                  _showInviteDialog(context, ref);
                  break;
                case 'members':
                  _showMembersSheet(context);
                  break;
                case 'delete':
                  _confirmDelete(context, ref);
                  break;
                case 'leave':
                  _confirmLeave(context, ref);
                  break;
              }
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Summary
          SliverToBoxAdapter(
            child: summaryAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (summary) => _buildSummaryCard(context, summary),
            ),
          ),
          // Transactions
          transactionsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (transactions) {
              if (transactions.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Belum ada transaksi'),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = transactions[index];
                    return _buildTransactionItem(tx);
                  },
                  childCount: transactions.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, VaultSummary summary) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Pengeluaran',
            style: TextStyle(color: Colors.white70),
          ),
          const Gap(4),
          Text(
            CurrencyFormatter.format(summary.totalExpense),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          Row(
            children: [
              _buildSummaryItem(
                Icons.receipt,
                '${summary.transactionCount}',
                'Transaksi',
              ),
              const Gap(24),
              _buildSummaryItem(
                Icons.people,
                '${vault.memberCount}',
                'Anggota',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const Gap(8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionItem(VaultTransaction tx) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Text(
          tx.addedByEmail[0].toUpperCase(),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(tx.description),
      subtitle: Text(
        '${tx.addedByEmail} • ${tx.category}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        CurrencyFormatter.format(tx.amount),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.expense,
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Undang Anggota'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'email@example.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.trim().isEmpty) return;
              ref.read(vaultNotifierProvider.notifier)
                  .inviteMember(vault.id, emailController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Undang'),
          ),
        ],
      ),
    );
  }

  void _showMembersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anggota Vault',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(16),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.star)),
              title: Text(vault.ownerEmail),
              subtitle: const Text('Owner'),
            ),
            ...vault.members.map((m) => ListTile(
              leading: CircleAvatar(
                backgroundImage: m.photoUrl != null 
                    ? NetworkImage(m.photoUrl!)
                    : null,
                child: m.photoUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(m.displayName ?? m.email),
              subtitle: Text(m.isPending ? 'Menunggu konfirmasi' : 'Aktif'),
              trailing: m.isPending
                  ? const Icon(Icons.pending, color: Colors.orange)
                  : const Icon(Icons.check_circle, color: Colors.green),
            )),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    final descController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Transaksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            const Gap(16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add transaction logic
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Vault'),
        content: const Text(
          'Semua transaksi dalam vault ini akan dihapus. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(vaultNotifierProvider.notifier).deleteVault(vault.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Vault'),
        content: const Text(
          'Anda tidak akan bisa melihat transaksi vault ini lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(vaultNotifierProvider.notifier).leaveVault(vault.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
