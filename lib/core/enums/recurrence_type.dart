// lib/core/enums/recurrence_type.dart

import 'package:flutter/material.dart';

/// Enum untuk tipe recurring/berulang transaksi
enum RecurrenceType {
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly;

  String get displayName {
    switch (this) {
      case RecurrenceType.daily:
        return 'Harian';
      case RecurrenceType.weekly:
        return 'Mingguan';
      case RecurrenceType.biweekly:
        return 'Dua Mingguan';
      case RecurrenceType.monthly:
        return 'Bulanan';
      case RecurrenceType.quarterly:
        return 'Triwulan';
      case RecurrenceType.yearly:
        return 'Tahunan';
    }
  }

  String get displayNameEn {
    switch (this) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.biweekly:
        return 'Biweekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.quarterly:
        return 'Quarterly';
      case RecurrenceType.yearly:
        return 'Yearly';
    }
  }

  IconData get icon {
    switch (this) {
      case RecurrenceType.daily:
        return Icons.today;
      case RecurrenceType.weekly:
        return Icons.view_week;
      case RecurrenceType.biweekly:
        return Icons.date_range;
      case RecurrenceType.monthly:
        return Icons.calendar_month;
      case RecurrenceType.quarterly:
        return Icons.calendar_view_month;
      case RecurrenceType.yearly:
        return Icons.calendar_today;
    }
  }

  /// Menghitung tanggal berikutnya berdasarkan tipe recurrence
  DateTime getNextDate(DateTime fromDate) {
    switch (this) {
      case RecurrenceType.daily:
        return fromDate.add(const Duration(days: 1));
      case RecurrenceType.weekly:
        return fromDate.add(const Duration(days: 7));
      case RecurrenceType.biweekly:
        return fromDate.add(const Duration(days: 14));
      case RecurrenceType.monthly:
        return DateTime(fromDate.year, fromDate.month + 1, fromDate.day);
      case RecurrenceType.quarterly:
        return DateTime(fromDate.year, fromDate.month + 3, fromDate.day);
      case RecurrenceType.yearly:
        return DateTime(fromDate.year + 1, fromDate.month, fromDate.day);
    }
  }

  /// Mendapatkan interval dalam hari (perkiraan)
  int get intervalDays {
    switch (this) {
      case RecurrenceType.daily:
        return 1;
      case RecurrenceType.weekly:
        return 7;
      case RecurrenceType.biweekly:
        return 14;
      case RecurrenceType.monthly:
        return 30;
      case RecurrenceType.quarterly:
        return 90;
      case RecurrenceType.yearly:
        return 365;
    }
  }
}
