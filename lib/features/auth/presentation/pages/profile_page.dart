// lib/features/auth/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/auth_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userAsync = ref.watch(currentUserProvider);
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
        title: const Text('Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) {
            return _buildNotLoggedIn(context, isDark, isAmoled);
          }
          return _buildProfile(context, ref, user, authState, isDark, isAmoled);
        },
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context, bool isDark, bool isAmoled) {
    final textSecondary = isAmoled 
        ? AppColors.textSecondaryAmoled 
        : isDark 
            ? AppColors.textSecondaryDark 
            : AppColors.textSecondary;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 80,
            color: textSecondary,
          ),
          const Gap(16),
          Text(
            'Belum masuk',
            style: TextStyle(color: textSecondary),
          ),
          const Gap(24),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Masuk dengan Google'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(
    BuildContext context, 
    WidgetRef ref, 
    dynamic user,
    AuthState authState,
    bool isDark,
    bool isAmoled,
  ) {
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
    final statCardColor = isAmoled 
        ? AppColors.surfaceAmoled 
        : isDark 
            ? AppColors.surfaceDark 
            : Colors.grey.shade100;
    final dangerZoneBg = isAmoled 
        ? Colors.red.shade900.withValues(alpha: 0.3)
        : isDark 
            ? Colors.red.shade900.withValues(alpha: 0.3)
            : Colors.red.shade50;
    final dangerZoneBorder = isAmoled 
        ? Colors.red.shade800
        : isDark 
            ? Colors.red.shade800
            : Colors.red.shade200;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photoUrl != null 
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null 
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const Gap(16),
                Text(
                  user.displayName ?? 'Pengguna',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(4),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textSecondary,
                  ),
                ),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: user.isPremium 
                        ? Colors.amber 
                        : isDark 
                            ? Colors.grey.shade700 
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.isPremium ? '⭐ Premium' : 'Free Plan',
                    style: TextStyle(
                      color: user.isPremium 
                          ? Colors.white 
                          : isDark 
                              ? Colors.grey.shade300 
                              : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Gap(24),
          
          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Bergabung',
                  _formatDate(user.createdAt),
                  Icons.calendar_today,
                  statCardColor,
                  textSecondary,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Login Terakhir',
                  _formatDate(user.lastLoginAt ?? user.createdAt),
                  Icons.access_time,
                  statCardColor,
                  textSecondary,
                ),
              ),
            ],
          ),
          
          const Gap(24),
          
          // Menu Items
          _buildMenuItem(
            context,
            Icons.edit,
            'Edit Profil',
            'Ubah nama dan foto',
            () {},
            cardColor,
            textSecondary,
          ),
          const Gap(10),
          _buildMenuItem(
            context,
            Icons.notifications,
            'Notifikasi',
            'Atur preferensi notifikasi',
            () {},
            cardColor,
            textSecondary,
          ),
          const Gap(10),
          _buildMenuItem(
            context,
            Icons.security,
            'Keamanan',
            'Kelola keamanan akun',
            () {},
            cardColor,
            textSecondary,
          ),
          const Gap(10),
          _buildMenuItem(
            context,
            Icons.help,
            'Bantuan',
            'FAQ dan dukungan',
            () {},
            cardColor,
            textSecondary,
          ),
          const Gap(10),
          _buildMenuItem(
            context,
            Icons.info,
            'Tentang Aplikasi',
            'Versi dan lisensi',
            () => _showAboutDialog(context),
            cardColor,
            textSecondary,
          ),
          
          const Gap(32),
          
          // Danger Zone
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dangerZoneBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dangerZoneBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zona Berbahaya',
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showDeleteAccountDialog(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Hapus Akun'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color cardColor,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const Gap(8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textSecondary,
            ),
          ),
          const Gap(4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    Color cardColor,
    Color textSecondary,
  ) {
    return Card(
      color: cardColor,
      elevation: 0,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: textSecondary),
        ),
        trailing: Icon(Icons.chevron_right, color: textSecondary),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).signOut();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text(
          'PERINGATAN: Tindakan ini tidak dapat dibatalkan. '
          'Semua data Anda akan dihapus secara permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).deleteAccount();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus Akun'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'RUPIA',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 RUPIA. All rights reserved.',
      children: [
        const Gap(16),
        const Text(
          'Aplikasi keuangan dengan Mood Analytics & Smart Sync ke Google Sheets.',
        ),
      ],
    );
  }
}
