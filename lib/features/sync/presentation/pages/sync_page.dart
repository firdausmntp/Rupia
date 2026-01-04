import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/color_constants.dart';

import '../../../../core/utils/date_formatter.dart';
import '../providers/sync_providers.dart';

class SyncPage extends ConsumerStatefulWidget {
  const SyncPage({super.key});

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _authCodeController = TextEditingController();
  bool _showAuthCodeInput = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _authCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncProvider);

    // Animate sync icon when syncing
    if (syncState.isSyncing) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sheets Sync'),
        actions: [
          if (syncState.isConnected)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => _openSpreadsheet(syncState.spreadsheetUrl),
              tooltip: 'Buka Spreadsheet',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(syncState),
            const Gap(24),

            // Connection Section
            if (!syncState.isConnected) ...[
              _buildConnectSection(),
            ] else ...[
              // Sync Actions
              _buildSyncActions(syncState),
              const Gap(24),

              // Sync Info
              _buildSyncInfo(syncState),
              const Gap(24),

              // Spreadsheet Info
              _buildSpreadsheetInfo(syncState),
              const Gap(24),

              // Danger Zone
              _buildDangerZone(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(SyncState syncState) {
    final isConnected = syncState.isConnected;
    final isSyncing = syncState.isSyncing;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isConnected
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isConnected ? const Color(0xFF10B981) : AppColors.primary)
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: isSyncing
                ? RotationTransition(
                    turns: _animationController,
                    child: const Icon(
                      Icons.sync,
                      color: Colors.white,
                      size: 32,
                    ),
                  )
                : Icon(
                    isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: Colors.white,
                    size: 32,
                  ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSyncing
                      ? 'Sedang Menyinkronkan...'
                      : isConnected
                          ? 'Terhubung'
                          : 'Belum Terhubung',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(4),
                Text(
                  isConnected
                      ? 'Google Sheets siap digunakan'
                      : 'Hubungkan akun Google Anda',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Hubungkan Google Sheets'),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step 1
              _buildStepItem(
                step: 1,
                title: 'Konfigurasi OAuth',
                description: 'Masukkan Client ID & Secret dari Google Cloud Console',
                action: ElevatedButton.icon(
                  onPressed: _showConfigDialog,
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Konfigurasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const Divider(height: 32),

              // Step 2
              _buildStepItem(
                step: 2,
                title: 'Autentikasi Google',
                description: 'Login dengan akun Google Anda',
                action: ElevatedButton.icon(
                  onPressed: _startAuth,
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text('Login Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Auth Code Input
              if (_showAuthCodeInput) ...[
                const Gap(16),
                TextField(
                  controller: _authCodeController,
                  decoration: InputDecoration(
                    labelText: 'Kode Otorisasi',
                    hintText: 'Paste kode dari browser',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _submitAuthCode,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const Gap(24),

        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  'Setelah terhubung, transaksi akan otomatis disinkronkan ke Google Sheets Anda.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required int step,
    required String title,
    required String description,
    required Widget action,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Gap(4),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Gap(12),
              action,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSyncActions(SyncState syncState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Sinkronisasi'),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.sync,
                title: 'Sync Sekarang',
                subtitle: 'Sinkronkan semua transaksi',
                color: AppColors.primary,
                onTap: syncState.isSyncing ? null : _syncNow,
                isLoading: syncState.isSyncing,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.cloud_upload,
                title: 'Force Sync',
                subtitle: 'Upload ulang semua data',
                color: const Color(0xFFF59E0B),
                onTap: syncState.isSyncing ? null : _forceSyncAll,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      )
                    : Icon(icon, color: color, size: 24),
              ),
              const Gap(12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Gap(4),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncInfo(SyncState syncState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informasi Sync'),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow(
                icon: Icons.access_time,
                label: 'Terakhir Sync',
                value: syncState.lastSync != null
                    ? DateFormatter.formatRelative(syncState.lastSync!)
                    : 'Belum pernah',
              ),
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.check_circle_outline,
                label: 'Status',
                value: syncState.isSyncing
                    ? 'Menyinkronkan...'
                    : syncState.errorMessage ?? 'Siap',
                valueColor: syncState.errorMessage != null
                    ? AppColors.expense
                    : AppColors.income,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
        const Gap(12),
        Expanded(
          child: Column(
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
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpreadsheetInfo(SyncState syncState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Spreadsheet'),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F9D58).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.table_chart,
                      color: Color(0xFF0F9D58),
                      size: 24,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rupia - Keuangan Pribadi',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'Google Sheets',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openSpreadsheet(syncState.spreadsheetUrl),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Buka di Browser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F9D58),
                    side: const BorderSide(color: Color(0xFF0F9D58)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pengaturan'),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.expense.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.expense.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.link_off,
                    color: AppColors.expense,
                  ),
                ),
                title: const Text(
                  'Putuskan Koneksi',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Hapus koneksi Google Sheets',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                trailing: TextButton(
                  onPressed: _disconnect,
                  child: Text(
                    'Putuskan',
                    style: TextStyle(color: AppColors.expense),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  // Actions
  void _showConfigDialog() {
    final clientIdController = TextEditingController();
    final clientSecretController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfigurasi OAuth'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: clientIdController,
              decoration: const InputDecoration(
                labelText: 'Client ID',
                hintText: 'Dari Google Cloud Console',
              ),
            ),
            const Gap(16),
            TextField(
              controller: clientSecretController,
              decoration: const InputDecoration(
                labelText: 'Client Secret',
                hintText: 'Dari Google Cloud Console',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(syncProvider.notifier).configureService(
                    clientIdController.text,
                    clientSecretController.text,
                  );
              if (context.mounted) Navigator.pop(context);
              _showSnackBar('Konfigurasi disimpan');
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _startAuth() async {
    try {
      final authUrl = ref.read(syncProvider.notifier).getAuthUrl();
      
      // Copy URL and show dialog
      await Clipboard.setData(ClipboardData(text: authUrl));
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Autentikasi Google'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1. URL autentikasi sudah di-copy ke clipboard\n'
                  '2. Buka browser dan paste URL\n'
                  '3. Login dengan akun Google\n'
                  '4. Copy kode otorisasi yang muncul\n'
                  '5. Paste kode di bawah',
                ),
                const Gap(16),
                SelectableText(
                  authUrl,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final uri = Uri.parse(authUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Buka Browser'),
              ),
            ],
          ),
        );
      }
      
      setState(() {
        _showAuthCodeInput = true;
      });
    } catch (e) {
      _showSnackBar('Error: Konfigurasi OAuth terlebih dahulu');
    }
  }

  void _submitAuthCode() async {
    final code = _authCodeController.text.trim();
    if (code.isEmpty) {
      _showSnackBar('Masukkan kode otorisasi');
      return;
    }

    final success = await ref.read(syncProvider.notifier).authenticate(code);
    
    if (success) {
      _showSnackBar('Berhasil terhubung!', isSuccess: true);
      setState(() {
        _showAuthCodeInput = false;
      });
      _authCodeController.clear();
    } else {
      _showSnackBar('Gagal autentikasi. Coba lagi.');
    }
  }

  void _syncNow() async {
    final result = await ref.read(syncProvider.notifier).sync();
    
    if (result.success) {
      _showSnackBar('${result.syncedCount} transaksi berhasil disinkronkan!', isSuccess: true);
    } else {
      _showSnackBar(result.message);
    }
  }

  void _forceSyncAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force Sync?'),
        content: const Text(
          'Semua data di spreadsheet akan dihapus dan diupload ulang. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
            ),
            child: const Text('Ya, Lanjutkan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ref.read(syncProvider.notifier).sync();
      
      if (result.success) {
        _showSnackBar('Force sync berhasil!', isSuccess: true);
      } else {
        _showSnackBar(result.message);
      }
    }
  }

  void _disconnect() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Putuskan Koneksi?'),
        content: const Text(
          'Data di Google Sheets tidak akan dihapus, hanya koneksi yang diputus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
            ),
            child: const Text('Ya, Putuskan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(syncProvider.notifier).disconnect();
      _showSnackBar('Koneksi diputus');
    }
  }

  void _openSpreadsheet(String? url) async {
    if (url == null) {
      _showSnackBar('URL spreadsheet tidak tersedia');
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Tidak dapat membuka URL');
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.income : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
