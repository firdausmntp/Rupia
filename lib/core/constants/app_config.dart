import 'package:flutter/foundation.dart';

class AppConfig {
  // App selalu menggunakan Firebase di mobile (google-services.json sudah ada)
  // Web mode = demo mode dengan mock data
  static bool get isDemoMode => kIsWeb;
  
  // Database - SQLite untuk mobile, mock data untuk web
  static bool get useMockData => kIsWeb;
  
  // App Info
  static const String appVersion = '3.3.2';
  static const String buildNumber = '1';
  
  // Supported Languages
  static const String defaultLocale = 'id';
  static const List<String> supportedLocales = ['id', 'en'];
  
  // Gamification Config
  static const int dailyLoginPoints = 10;
  static const int transactionAddPoints = 5;
  static const int budgetAchievedPoints = 50;
  static const int savingsGoalPoints = 100;
  
  // Budget Alert Thresholds
  static const double budgetWarningThreshold = 0.8; // 80%
  static const double budgetDangerThreshold = 0.95; // 95%
  
  // Widget Update Interval (minutes)
  static const int widgetUpdateInterval = 30;
}
