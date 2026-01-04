import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Extended theme mode with AMOLED support
enum AppThemeMode {
  system,
  light,
  dark,
  amoled,
}

/// App primary color options for customization without restart
enum AppAccentColor {
  purple(Color(0xFF6366F1), 'Ungu'),
  blue(Color(0xFF3B82F6), 'Biru'),
  green(Color(0xFF10B981), 'Hijau'),
  orange(Color(0xFFF59E0B), 'Oranye'),
  red(Color(0xFFEF4444), 'Merah'),
  pink(Color(0xFFEC4899), 'Pink'),
  teal(Color(0xFF14B8A6), 'Teal'),
  indigo(Color(0xFF4F46E5), 'Indigo');

  final Color color;
  final String label;
  const AppAccentColor(this.color, this.label);
  
  Color get darkColor => HSLColor.fromColor(color).withLightness(0.6).toColor();
}

/// Theme state notifier for managing app theme
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const String _themeKey = 'app_theme_mode';
  static const String _accentColorKey = 'app_accent_color';
  
  AppThemeMode _appThemeMode = AppThemeMode.system;
  AppAccentColor _accentColor = AppAccentColor.purple;
  
  AppThemeMode get appThemeMode => _appThemeMode;
  AppAccentColor get accentColor => _accentColor;

  /// Load saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = prefs.getString(_themeKey);
      final accentColorName = prefs.getString(_accentColorKey);
      
      if (themeName != null) {
        switch (themeName) {
          case 'light':
            state = ThemeMode.light;
            _appThemeMode = AppThemeMode.light;
            break;
          case 'dark':
            state = ThemeMode.dark;
            _appThemeMode = AppThemeMode.dark;
            break;
          case 'amoled':
            state = ThemeMode.dark;
            _appThemeMode = AppThemeMode.amoled;
            break;
          default:
            state = ThemeMode.system;
            _appThemeMode = AppThemeMode.system;
        }
      }
      
      if (accentColorName != null) {
        try {
          _accentColor = AppAccentColor.values.firstWhere(
            (c) => c.name == accentColorName,
            orElse: () => AppAccentColor.purple,
          );
        } catch (_) {
          _accentColor = AppAccentColor.purple;
        }
      }
    } catch (e) {
      // Default to system theme on error
      state = ThemeMode.system;
      _appThemeMode = AppThemeMode.system;
    }
  }

  /// Set theme mode and save to SharedPreferences
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    
    // Update app theme mode based on ThemeMode
    if (mode == ThemeMode.light) {
      _appThemeMode = AppThemeMode.light;
    } else if (mode == ThemeMode.dark) {
      _appThemeMode = AppThemeMode.dark;
    } else {
      _appThemeMode = AppThemeMode.system;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeName;
      
      switch (_appThemeMode) {
        case AppThemeMode.light:
          themeName = 'light';
          break;
        case AppThemeMode.dark:
          themeName = 'dark';
          break;
        case AppThemeMode.amoled:
          themeName = 'amoled';
          break;
        default:
          themeName = 'system';
      }
      
      await prefs.setString(_themeKey, themeName);
    } catch (e) {
      // Ignore save errors
    }
  }
  
  /// Set app theme mode (including AMOLED)
  Future<void> setAppThemeMode(AppThemeMode mode) async {
    _appThemeMode = mode;
    
    // Update ThemeMode accordingly
    switch (mode) {
      case AppThemeMode.light:
        state = ThemeMode.light;
        break;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        state = ThemeMode.dark;
        break;
      case AppThemeMode.system:
        state = ThemeMode.system;
        break;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeName;
      
      switch (mode) {
        case AppThemeMode.light:
          themeName = 'light';
          break;
        case AppThemeMode.dark:
          themeName = 'dark';
          break;
        case AppThemeMode.amoled:
          themeName = 'amoled';
          break;
        default:
          themeName = 'system';
      }
      
      await prefs.setString(_themeKey, themeName);
    } catch (e) {
      // Ignore save errors
    }
  }
  
  /// Set accent color without restarting app - triggers UI rebuild
  Future<void> setAccentColor(AppAccentColor color) async {
    _accentColor = color;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accentColorKey, color.name);
    } catch (e) {
      // Ignore save errors
    }
    
    // Force UI rebuild by temporarily changing state
    final currentState = state;
    state = currentState == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await Future.delayed(const Duration(milliseconds: 10));
    state = currentState;
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setTheme(ThemeMode.light);
    } else {
      await setTheme(ThemeMode.dark);
    }
  }

  /// Check if current theme is dark
  bool get isDark => state == ThemeMode.dark;
  
  /// Check if using system theme
  bool get isSystem => state == ThemeMode.system;
  
  /// Check if AMOLED mode
  bool get isAmoled => _appThemeMode == AppThemeMode.amoled;
}

/// Theme provider for Riverpod
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Provider for app theme mode (including AMOLED)
final appThemeModeProvider = Provider<AppThemeMode>((ref) {
  ref.watch(themeProvider); // Subscribe to changes
  final notifier = ref.read(themeProvider.notifier);
  return notifier.appThemeMode;
});

/// Provider for accent color
final accentColorProvider = Provider<AppAccentColor>((ref) {
  ref.watch(themeProvider); // Subscribe to changes
  final notifier = ref.read(themeProvider.notifier);
  return notifier.accentColor;
});

/// Helper provider to check if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  if (themeMode == ThemeMode.system) {
    // Return based on platform brightness
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }
  return themeMode == ThemeMode.dark;
});

/// Helper provider to check if AMOLED mode is active
final isAmoledModeProvider = Provider<bool>((ref) {
  ref.watch(themeProvider); // Subscribe to changes
  final notifier = ref.read(themeProvider.notifier);
  return notifier.isAmoled;
});
