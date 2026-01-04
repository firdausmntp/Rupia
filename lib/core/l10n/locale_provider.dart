// lib/core/l10n/locale_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_config.dart';

// Locale Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'app_locale';
  
  LocaleNotifier() : super(Locale(AppConfig.defaultLocale)) {
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey) ?? AppConfig.defaultLocale;
    state = Locale(languageCode);
  }
  
  Future<void> setLocale(String languageCode) async {
    if (!AppConfig.supportedLocales.contains(languageCode)) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    state = Locale(languageCode);
  }
  
  String get currentLanguageCode => state.languageCode;
  
  String get currentLanguageName {
    switch (state.languageCode) {
      case 'id':
        return 'Bahasa Indonesia';
      case 'en':
        return 'English';
      default:
        return 'Bahasa Indonesia';
    }
  }
}
