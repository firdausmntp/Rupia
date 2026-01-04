// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';

import '../../../../main.dart' show firebaseInitialized;
import '../providers/auth_providers.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    // Check if Firebase is available - either web demo mode OR Firebase init failed
    final isOfflineMode = kIsWeb || !firebaseInitialized;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    // Listen for auth success
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.isAuthenticated && !next.isLoading) {
        context.go('/');
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: isOfflineMode ? Colors.orange : Colors.red,
            duration: Duration(seconds: isOfflineMode ? 4 : 3),
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: isSmallScreen ? 16.0 : 24.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Section - Logo & Title
                      Column(
                        children: [
                          Gap(isSmallScreen ? 16 : 40),
                          
                          // Logo with gradient shadow
                          Container(
                            width: isSmallScreen ? 80 : 100,
                            height: isSmallScreen ? 80 : 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              size: isSmallScreen ? 40 : 50,
                              color: Colors.white,
                            ),
                          ),
                          Gap(isSmallScreen ? 16 : 24),
                          
                          Text(
                            'RUPIA',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: isSmallScreen ? 28 : 32,
                              letterSpacing: 2,
                            ),
                          ),
                          const Gap(8),
                          
                          Text(
                            'Kelola Keuangan dengan Cerdas',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ],
                      ),
                      
                      // Middle Section - Features
                      if (!isSmallScreen) ...[
                        const Gap(32),
                        Column(
                          children: [
                            _buildFeatureItem(
                              context,
                              Icons.mood,
                              'Mood Analytics',
                              'Pahami pola pengeluaran berdasarkan suasana hati',
                              isSmallScreen,
                            ),
                            const Gap(16),
                            _buildFeatureItem(
                              context,
                              Icons.sync,
                              'Smart Sync',
                              'Backup otomatis ke Google Sheets',
                              isSmallScreen,
                            ),
                            const Gap(16),
                            _buildFeatureItem(
                              context,
                              Icons.receipt_long,
                              'Scan Struk',
                              'Input transaksi cepat dengan OCR',
                              isSmallScreen,
                            ),
                          ],
                        ),
                        const Gap(32),
                      ],
                      
                      if (isSmallScreen) const Gap(24),
                      
                      // Bottom Section - Login Buttons
                      Column(
                        children: [
                          // Demo mode banner
                          if (isOfflineMode)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                                  const Gap(12),
                                  Expanded(
                                    child: Text(
                                      'Demo Mode: Login tidak tersedia di web. Test di mobile atau lewati untuk preview UI.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Google Sign In Button - Premium Design
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: authState.isLoading 
                                  ? null 
                                  : () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                elevation: 3,
                                shadowColor: Colors.black26,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                                ),
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Image.network(
                                            'https://www.google.com/favicon.ico',
                                            width: 22,
                                            height: 22,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Icon(
                                                Icons.g_mobiledata,
                                                size: 20,
                                                color: Colors.red.shade600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Gap(12),
                                        const Text(
                                          'Masuk dengan Google',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          
                          const Gap(12),
                          
                          // Skip login button - Fixed overflow
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => context.go('/'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Lewati (Mode Offline)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          
                          Gap(isSmallScreen ? 16 : 24),
                          
                          // Terms - Better readability
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Dengan masuk, Anda menyetujui Syarat & Ketentuan dan Kebijakan Privasi',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ),
                          Gap(isSmallScreen ? 8 : 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    bool isSmallScreen,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primaryDark.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
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
                const Gap(2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
