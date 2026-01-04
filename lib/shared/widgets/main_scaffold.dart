import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/constants/color_constants.dart';
import '../../core/theme/theme_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isDark = ref.watch(isDarkModeProvider);
    final isAmoled = ref.watch(isAmoledModeProvider);
    final accentColor = ref.watch(accentColorProvider);
    
    // Get the primary color based on accent
    final primaryColor = accentColor.color;
    
    // Determine background colors based on theme
    Color navBackgroundColor;
    Color inactiveColor;
    
    if (isAmoled) {
      navBackgroundColor = AppColors.surfaceAmoled;
      inactiveColor = AppColors.textSecondaryAmoled;
    } else if (isDark) {
      navBackgroundColor = AppColors.surfaceDark;
      inactiveColor = AppColors.textSecondaryDark;
    } else {
      navBackgroundColor = Colors.white;
      inactiveColor = AppColors.textSecondary;
    }
    
    // Get bottom padding for system navigation bar
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    
    return Scaffold(
      body: child,
      extendBody: true,
      extendBodyBehindAppBar: false,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.3) 
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            // Reduced padding for smaller bottom nav
            padding: EdgeInsets.only(
              left: 8, 
              right: 8, 
              top: 4, 
              bottom: 4 + (bottomPadding > 0 ? 2 : 0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  selectedIndex: selectedIndex,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Beranda',
                  primaryColor: primaryColor,
                  inactiveColor: inactiveColor,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  selectedIndex: selectedIndex,
                  icon: Icons.pie_chart_outline,
                  activeIcon: Icons.pie_chart_rounded,
                  label: 'Analitik',
                  primaryColor: primaryColor,
                  inactiveColor: inactiveColor,
                  isDark: isDark,
                ),
                // FAB space
                const SizedBox(width: 56),
                _buildNavItem(
                  context: context,
                  index: 2,
                  selectedIndex: selectedIndex,
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  label: 'Budget',
                  primaryColor: primaryColor,
                  inactiveColor: inactiveColor,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  selectedIndex: selectedIndex,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Pengaturan',
                  primaryColor: primaryColor,
                  inactiveColor: inactiveColor,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, HSLColor.fromColor(primaryColor).withLightness(0.4).toColor()],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => context.push('/add-transaction'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int selectedIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color primaryColor,
    required Color inactiveColor,
    required bool isDark,
  }) {
    final isSelected = selectedIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index, context),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? primaryColor.withValues(alpha: 0.12) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? primaryColor : inactiveColor,
                  size: 22,
                ),
              ),
              const Gap(2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? primaryColor : inactiveColor,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/analytics')) return 1;
    if (location.startsWith('/budget')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/analytics');
        break;
      case 2:
        context.go('/budget');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}
