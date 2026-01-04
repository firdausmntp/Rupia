import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/backup_providers.dart';
import 'dart:io';

class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupsAsync = ref.watch(backupsProvider);
    final backupState = ref.watch(backupNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('backup_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: backupsAsync.when(
        data: (backups) {
          if (backups.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(backupsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: backups.length,
              itemBuilder: (context, index) {
                final backup = backups[index];
                return _BackupCard(
                  backup: backup,
                  onRestore: () => _confirmRestore(context, ref, backup.id),
                  onDelete: () => _confirmDelete(context, ref, backup.id),
                  onExport: () => _exportBackup(context, ref, backup.id),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const Gap(16),
              Text(error.toString()),
              const Gap(16),
              ElevatedButton(
                onPressed: () => ref.refresh(backupsProvider),
                child: Text(context.tr('retry')),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'import',
            onPressed: () => _importBackup(context, ref),
            icon: const Icon(Icons.upload_file),
            label: Text(context.tr('backup_import')),
          ),
          const Gap(8),
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: backupState.isLoading
                ? null
                : () => _createBackup(context, ref),
            icon: backupState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.backup),
            label: Text(context.tr('backup_create')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const Gap(16),
          Text(
            context.tr('backup_empty_title'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(8),
          Text(
            context.tr('backup_empty_subtitle'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('backup_info_title')),
        content: Text(context.tr('backup_info_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('ok')),
          ),
        ],
      ),
    );
  }

  void _createBackup(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    
    final notes = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('backup_add_notes')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: context.tr('backup_notes_hint'),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(context.tr('backup_create')),
          ),
        ],
      ),
    );

    if (notes == null) return;

    await ref.read(backupNotifierProvider.notifier).createBackup(notes: notes);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('backup_created_success'))),
      );
    }
  }

  void _confirmRestore(BuildContext context, WidgetRef ref, String backupId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('backup_restore_confirm_title')),
        content: Text(context.tr('backup_restore_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(backupNotifierProvider.notifier).restoreBackup(backupId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('backup_restored_success'))),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(context.tr('backup_restore')),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String backupId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('backup_delete_confirm_title')),
        content: Text(context.tr('backup_delete_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(backupNotifierProvider.notifier).deleteBackup(backupId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('backup_deleted_success'))),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }

  void _exportBackup(BuildContext context, WidgetRef ref, String backupId) async {
    final repository = ref.read(backupRepositoryProvider);
    
    try {
      final file = await repository.exportBackupToLocal(backupId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr('backup_exported_success')}: ${file.path}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr('backup_export_failed')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _importBackup(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gz'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final repository = ref.read(backupRepositoryProvider);

    try {
      await repository.importBackupFromLocal(file);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('backup_imported_success'))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr('backup_import_failed')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _BackupCard extends StatelessWidget {
  final dynamic backup;
  final VoidCallback onRestore;
  final VoidCallback onDelete;
  final VoidCallback onExport;

  const _BackupCard({
    required this.backup,
    required this.onRestore,
    required this.onDelete,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_done,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Gap(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(backup.createdAt),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (backup.notes != null && backup.notes!.isNotEmpty)
                        Text(
                          backup.notes!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Text(
                  '${backup.fileSize.toStringAsFixed(2)} MB',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const Gap(12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.receipt_long,
                  label: '${backup.transactionCount}',
                ),
                const Gap(8),
                _InfoChip(
                  icon: Icons.account_balance_wallet,
                  label: '${backup.budgetCount}',
                ),
                const Gap(8),
                _InfoChip(
                  icon: Icons.payments,
                  label: '${backup.debtCount}',
                ),
              ],
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRestore,
                    icon: const Icon(Icons.restore, size: 18),
                    label: Text(context.tr('backup_restore')),
                  ),
                ),
                const Gap(8),
                IconButton(
                  onPressed: onExport,
                  icon: const Icon(Icons.download),
                  tooltip: context.tr('backup_export'),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: context.tr('delete'),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const Gap(4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
