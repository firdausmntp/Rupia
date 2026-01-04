import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);
  
  // Semantic Colors
  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFDC2626);
  
  // Light Mode Neutral Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color disabled = Color(0xFFCBD5E1);
  
  // Dark Mode Neutral Colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardBackgroundDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color borderDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF1E293B);
  static const Color disabledDark = Color(0xFF475569);
  
  // AMOLED Black Mode Colors (Pure black for OLED screens)
  static const Color backgroundAmoled = Color(0xFF000000);
  static const Color surfaceAmoled = Color(0xFF0A0A0A);
  static const Color cardBackgroundAmoled = Color(0xFF121212);
  static const Color textPrimaryAmoled = Color(0xFFFFFFFF);
  static const Color textSecondaryAmoled = Color(0xFFB0B0B0);
  static const Color textTertiaryAmoled = Color(0xFF808080);
  static const Color borderAmoled = Color(0xFF1F1F1F);
  static const Color dividerAmoled = Color(0xFF1A1A1A);
  static const Color disabledAmoled = Color(0xFF404040);
  
  // Mood Colors
  static const Color moodHappy = Color(0xFF10B981);
  static const Color moodStress = Color(0xFFEF4444);
  static const Color moodTired = Color(0xFF8B5CF6);
  static const Color moodBored = Color(0xFF6B7280);
  static const Color moodNeutral = Color(0xFF3B82F6);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient incomeGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient expenseGradient = LinearGradient(
    colors: [expense, Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
