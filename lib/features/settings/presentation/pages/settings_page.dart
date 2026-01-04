// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/export_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final authState = ref.watch(authStateProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final isAmoled = ref.watch(isAmoledModeProvider);
    final textSecondary = isAmoled 
        ? AppColors.textSecondaryAmoled 
        : isDark 
            ? AppColors.textSecondaryDark 
            : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSectionTitle(context, 'Akun', textSecondary),
            const Gap(8),
            authState.when(
              data: (user) => _buildSettingItem(
                context,
                icon: Icons.person_outline,
                title: 'Profil',
                subtitle: user?.displayName ?? 'Belum login',
                onTap: () {
                  if (user != null) {
                    context.push('/profile');
                  } else {
                    context.push('/login');
                  }
                },
              ),
              loading: () => _buildSettingItem(
                context,
                icon: Icons.person_outline,
                title: 'Profil',
                subtitle: 'Memuat...',
                onTap: () {},
              ),
              error: (_, __) => _buildSettingItem(
                context,
                icon: Icons.person_outline,
                title: 'Profil',
                subtitle: 'Belum login',
                onTap: () => context.push('/login'),
              ),
            ),
            const Gap(24),

            // Quick Features Section
            _buildSectionTitle(context, 'Fitur', textSecondary),
            const Gap(8),
            _buildSettingItem(
              context,
              icon: Icons.camera_alt_outlined,
              title: 'Scan Struk',
              subtitle: 'Catat transaksi dari foto struk',
              onTap: () => context.push('/scan-receipt'),
            ),
            _buildSettingItem(
              context,
              icon: Icons.location_on_outlined,
              title: 'Zona Pengeluaran',
              subtitle: 'Atur area dengan budget khusus',
              onTap: () => context.push('/geofence'),
            ),
            _buildSettingItem(
              context,
              icon: Icons.people_outline,
              title: 'Vault Bersama',
              subtitle: 'Kelola uang bareng keluarga/teman',
              onTap: () => context.push('/vault'),
            ),
            _buildSettingItem(
              context,
              icon: Icons.mood_outlined,
              title: 'Analisis Mood',
              subtitle: 'Lihat pola pengeluaran berdasarkan mood',
              onTap: () => context.push('/mood-analytics'),
            ),
            const Gap(24),

            // Sync Section
            _buildSectionTitle(context, 'Sinkronisasi', textSecondary),
            const Gap(8),
            _buildSyncCard(context, ref, syncState),
            const Gap(24),

            // Data Section
            _buildSectionTitle(context, 'Data', textSecondary),
            const Gap(8),
            _buildSettingItem(
              context,
              icon: Icons.account_balance_wallet_outlined,
              title: 'Budget',
              subtitle: 'Atur budget bulanan',
              onTap: () {
                context.go('/budget');
              },
            ),
            _buildSettingItem(
              context,
              icon: Icons.download_outlined,
              title: 'Export Data',
              subtitle: 'Export ke CSV/Excel',
              onTap: () => _showExportDialog(context, ref),
            ),
            const Gap(24),

            // Appearance Section
            _buildSectionTitle(context, 'Tampilan', textSecondary),
            const Gap(8),
            _buildThemeSelector(context, ref),
            const Gap(24),

            // About Section
            _buildSectionTitle(context, 'Tentang', textSecondary),
            const Gap(8),
            _buildSettingItem(
              context,
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              subtitle: 'Versi ${AppConstants.appVersion}',
              onTap: () => context.push('/about'),
            ),
            const Gap(32),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    '${AppConstants.appName} v${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Gap(4),
                  Text(
                    'Made with ❤️ for better financial habits',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildSyncCard(BuildContext context, WidgetRef ref, SyncState syncState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: syncState.isConnected
                        ? AppColors.income.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.table_chart,
                    color: syncState.isConnected ? AppColors.income : Colors.grey,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Google Sheets',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        syncState.isConnected ? 'Terhubung' : 'Belum terhubung',
                        style: TextStyle(
                          color: syncState.isConnected
                              ? AppColors.income
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (syncState.isSyncing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (syncState.lastSync != null) ...[
              const Gap(12),
              Text(
                'Terakhir sync: ${DateFormatter.formatRelative(syncState.lastSync!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (syncState.errorMessage != null) ...[
              const Gap(8),
              Text(
                syncState.errorMessage!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            ],
            const Gap(16),
            Row(
              children: [
                if (syncState.isConnected) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: syncState.isSyncing
                          ? null
                          : () async {
                              final result =
                                  await ref.read(syncProvider.notifier).sync();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result.message),
                                    backgroundColor: result.success
                                        ? AppColors.income
                                        : Colors.red,
                                  ),
                                );
                              }
                            },
                      icon: const Icon(Icons.sync, size: 18),
                      label: const Text('Sync Sekarang'),
                    ),
                  ),
                  const Gap(8),
                  IconButton(
                    onPressed: () => context.push('/sync'),
                    icon: const Icon(Icons.settings),
                    tooltip: 'Pengaturan Sync',
                  ),
                ] else
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/sync'),
                      icon: const Icon(Icons.link, size: 18),
                      label: const Text('Hubungkan'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TODO: Use this method when Google Sheets connection feature is enabled
  void _showConnectDialog(BuildContext context, WidgetRef ref) {
    final clientIdController = TextEditingController();
    final clientSecretController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hubungkan Google Sheets'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Untuk menghubungkan ke Google Sheets, Anda perlu membuat '
                'OAuth credentials di Google Cloud Console.',
                style: TextStyle(fontSize: 12),
              ),
              const Gap(16),
              TextField(
                controller: clientIdController,
                decoration: const InputDecoration(
                  labelText: 'Client ID',
                  hintText: 'xxx.apps.googleusercontent.com',
                ),
              ),
              const Gap(12),
              TextField(
                controller: clientSecretController,
                decoration: const InputDecoration(
                  labelText: 'Client Secret',
                ),
                obscureText: true,
              ),
              const Gap(12),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Authorization Code',
                  hintText: 'Dapatkan dari URL auth',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (clientIdController.text.isEmpty ||
                  clientSecretController.text.isEmpty) {
                return;
              }

              await ref.read(syncProvider.notifier).configureService(
                    clientIdController.text,
                    clientSecretController.text,
                  );

              if (codeController.text.isEmpty) {
                final authUrl = ref.read(syncProvider.notifier).getAuthUrl();
                if (context.mounted) {
                  Navigator.pop(context);
                  _showAuthUrlDialog(context, authUrl);
                }
              } else {
                final success = await ref
                    .read(syncProvider.notifier)
                    .authenticate(codeController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Berhasil terhubung!'
                          : 'Gagal menghubungkan'),
                      backgroundColor:
                          success ? AppColors.income : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Hubungkan'),
          ),
        ],
      ),
    );
  }

  void _showAuthUrlDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salin URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Buka URL berikut di browser untuk mendapatkan authorization code:'),
            const Gap(12),
            SelectableText(
              url,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // TODO: Use this method when Google Sheets connection feature is enabled
  void _showDisconnectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Putuskan Koneksi'),
        content: const Text(
          'Yakin ingin memutuskan koneksi dengan Google Sheets?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(syncProvider.notifier).disconnect();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Putuskan'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool? isDark,
  }) {
    final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: dark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark 
            ? AppColors.borderDark.withValues(alpha: 0.5)
            : AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primaryDark.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: AppColors.primary, size: 22),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: dark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.backgroundDark : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: dark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? AppColors.borderDark.withValues(alpha: 0.5) 
              : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primaryDark.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    currentTheme == ThemeMode.dark 
                        ? Icons.dark_mode 
                        : currentTheme == ThemeMode.light 
                            ? Icons.light_mode 
                            : Icons.brightness_auto,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tema',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        _getThemeLabel(currentTheme),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildThemeOption(
                    context,
                    ref,
                    icon: Icons.light_mode_rounded,
                    label: 'Terang',
                    mode: ThemeMode.light,
                    isSelected: currentTheme == ThemeMode.light,
                    isDark: isDark,
                  ),
                  _buildThemeOption(
                    context,
                    ref,
                    icon: Icons.dark_mode_rounded,
                    label: 'Gelap',
                    mode: ThemeMode.dark,
                    isSelected: currentTheme == ThemeMode.dark,
                    isDark: isDark,
                  ),
                  _buildThemeOption(
                    context,
                    ref,
                    icon: Icons.brightness_auto_rounded,
                    label: 'Sistem',
                    mode: ThemeMode.system,
                    isSelected: currentTheme == ThemeMode.system,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required ThemeMode mode,
    required bool isSelected,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(themeProvider.notifier).setTheme(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected 
                    ? Colors.white 
                    : isDark 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondary,
              ),
              const Gap(6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? Colors.white 
                      : isDark 
                          ? AppColors.textSecondaryDark 
                          : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Mode terang aktif';
      case ThemeMode.dark:
        return 'Mode gelap aktif';
      case ThemeMode.system:
        return 'Mengikuti pengaturan sistem';
    }
  }
  
  void _showExportDialog(BuildContext context, WidgetRef ref) {
    final isDark = ref.read(isDarkModeProvider);
    final isAmoled = ref.read(isAmoledModeProvider);
    final backgroundColor = isAmoled 
        ? AppColors.backgroundAmoled 
        : isDark 
            ? AppColors.backgroundDark 
            : AppColors.background;
    final cardColor = isAmoled 
        ? AppColors.cardBackgroundAmoled 
        : isDark 
            ? AppColors.cardBackgroundDark 
            : AppColors.cardBackground;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final exportState = ref.watch(exportNotifierProvider);
          final exportNotifier = ref.read(exportNotifierProvider.notifier);
          
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Gap(16),
                Text(
                  'Export Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(8),
                Text(
                  'Pilih format export data transaksi Anda',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const Gap(20),
                
                // Export options
                _buildExportOption(
                  context,
                  icon: Icons.table_chart_outlined,
                  title: 'Export ke CSV',
                  subtitle: 'Format spreadsheet untuk Excel/Google Sheets',
                  isLoading: exportState.isLoading,
                  cardColor: cardColor,
                  onTap: () async {
                    await exportNotifier.exportToCSV();
                    if (context.mounted) {
                      final state = ref.read(exportNotifierProvider);
                      if (state.filePath != null) {
                        Navigator.pop(context);
                        _showExportSuccessDialog(context, ref, state.filePath!);
                      } else if (state.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error!)),
                        );
                      }
                    }
                  },
                ),
                const Gap(12),
                _buildExportOption(
                  context,
                  icon: Icons.summarize_outlined,
                  title: 'Export Laporan',
                  subtitle: 'Ringkasan keuangan dalam format teks',
                  isLoading: exportState.isLoading,
                  cardColor: cardColor,
                  onTap: () async {
                    await exportNotifier.exportSummary();
                    if (context.mounted) {
                      final state = ref.read(exportNotifierProvider);
                      if (state.filePath != null) {
                        Navigator.pop(context);
                        _showExportSuccessDialog(context, ref, state.filePath!);
                      } else if (state.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error!)),
                        );
                      }
                    }
                  },
                ),
                const Gap(20),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLoading,
    required Color cardColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon, color: AppColors.primary),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  
  void _showExportSuccessDialog(BuildContext context, WidgetRef ref, String filePath) {
    final isDark = ref.read(isDarkModeProvider);
    final isAmoled = ref.read(isAmoledModeProvider);
    final backgroundColor = isAmoled 
        ? AppColors.backgroundAmoled 
        : isDark 
            ? AppColors.backgroundDark 
            : AppColors.background;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.income.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.check_circle, color: AppColors.income),
            ),
            const Gap(12),
            const Expanded(
              child: Text('Export Berhasil'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File telah disimpan di:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                filePath,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ref.read(exportNotifierProvider.notifier).shareFile();
            },
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Bagikan'),
          ),
        ],
      ),
    );
  }
}
