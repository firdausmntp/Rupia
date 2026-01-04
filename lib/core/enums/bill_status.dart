// lib/core/enums/bill_status.dart

import 'package:flutter/material.dart';

/// Enum untuk status tagihan
enum BillStatus {
  pending,
  paid,
  overdue,
  cancelled;

  String get displayName {
    switch (this) {
      case BillStatus.pending:
        return 'Belum Dibayar';
      case BillStatus.paid:
        return 'Sudah Dibayar';
      case BillStatus.overdue:
        return 'Terlambat';
      case BillStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  String get displayNameEn {
    switch (this) {
      case BillStatus.pending:
        return 'Pending';
      case BillStatus.paid:
        return 'Paid';
      case BillStatus.overdue:
        return 'Overdue';
      case BillStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData get icon {
    switch (this) {
      case BillStatus.pending:
        return Icons.schedule;
      case BillStatus.paid:
        return Icons.check_circle;
      case BillStatus.overdue:
        return Icons.warning;
      case BillStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color get color {
    switch (this) {
      case BillStatus.pending:
        return const Color(0xFFF59E0B); // warning/amber
      case BillStatus.paid:
        return const Color(0xFF10B981); // green
      case BillStatus.overdue:
        return const Color(0xFFEF4444); // red
      case BillStatus.cancelled:
        return const Color(0xFF6B7280); // gray
    }
  }
}

/// Enum untuk kategori tagihan
enum BillCategory {
  electricity,
  water,
  internet,
  phone,
  tv,
  insurance,
  rent,
  mortgage,
  subscription,
  loan,
  creditCard,
  tax,
  education,
  other;

  String get displayName {
    switch (this) {
      case BillCategory.electricity:
        return 'Listrik';
      case BillCategory.water:
        return 'Air';
      case BillCategory.internet:
        return 'Internet';
      case BillCategory.phone:
        return 'Telepon';
      case BillCategory.tv:
        return 'TV/Streaming';
      case BillCategory.insurance:
        return 'Asuransi';
      case BillCategory.rent:
        return 'Sewa';
      case BillCategory.mortgage:
        return 'KPR';
      case BillCategory.subscription:
        return 'Langganan';
      case BillCategory.loan:
        return 'Pinjaman';
      case BillCategory.creditCard:
        return 'Kartu Kredit';
      case BillCategory.tax:
        return 'Pajak';
      case BillCategory.education:
        return 'Pendidikan';
      case BillCategory.other:
        return 'Lainnya';
    }
  }

  String get displayNameEn {
    switch (this) {
      case BillCategory.electricity:
        return 'Electricity';
      case BillCategory.water:
        return 'Water';
      case BillCategory.internet:
        return 'Internet';
      case BillCategory.phone:
        return 'Phone';
      case BillCategory.tv:
        return 'TV/Streaming';
      case BillCategory.insurance:
        return 'Insurance';
      case BillCategory.rent:
        return 'Rent';
      case BillCategory.mortgage:
        return 'Mortgage';
      case BillCategory.subscription:
        return 'Subscription';
      case BillCategory.loan:
        return 'Loan';
      case BillCategory.creditCard:
        return 'Credit Card';
      case BillCategory.tax:
        return 'Tax';
      case BillCategory.education:
        return 'Education';
      case BillCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case BillCategory.electricity:
        return Icons.bolt;
      case BillCategory.water:
        return Icons.water_drop;
      case BillCategory.internet:
        return Icons.wifi;
      case BillCategory.phone:
        return Icons.phone_android;
      case BillCategory.tv:
        return Icons.tv;
      case BillCategory.insurance:
        return Icons.security;
      case BillCategory.rent:
        return Icons.home;
      case BillCategory.mortgage:
        return Icons.house;
      case BillCategory.subscription:
        return Icons.subscriptions;
      case BillCategory.loan:
        return Icons.account_balance;
      case BillCategory.creditCard:
        return Icons.credit_card;
      case BillCategory.tax:
        return Icons.receipt_long;
      case BillCategory.education:
        return Icons.school;
      case BillCategory.other:
        return Icons.more_horiz;
    }
  }

  Color get color {
    switch (this) {
      case BillCategory.electricity:
        return const Color(0xFFF59E0B);
      case BillCategory.water:
        return const Color(0xFF3B82F6);
      case BillCategory.internet:
        return const Color(0xFF8B5CF6);
      case BillCategory.phone:
        return const Color(0xFF10B981);
      case BillCategory.tv:
        return const Color(0xFFEC4899);
      case BillCategory.insurance:
        return const Color(0xFF14B8A6);
      case BillCategory.rent:
        return const Color(0xFFF97316);
      case BillCategory.mortgage:
        return const Color(0xFF6366F1);
      case BillCategory.subscription:
        return const Color(0xFFE11D48);
      case BillCategory.loan:
        return const Color(0xFF0EA5E9);
      case BillCategory.creditCard:
        return const Color(0xFFDC2626);
      case BillCategory.tax:
        return const Color(0xFF059669);
      case BillCategory.education:
        return const Color(0xFF7C3AED);
      case BillCategory.other:
        return const Color(0xFF6B7280);
    }
  }
}
