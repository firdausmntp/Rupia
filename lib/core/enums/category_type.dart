import 'package:flutter/material.dart';

enum CategoryType {
  food,
  transportation,
  shopping,
  entertainment,
  bills,
  health,
  education,
  salary,
  investment,
  gift,
  other;

  String get displayName {
    switch (this) {
      case CategoryType.food:
        return 'Makanan & Minuman';
      case CategoryType.transportation:
        return 'Transportasi';
      case CategoryType.shopping:
        return 'Belanja';
      case CategoryType.entertainment:
        return 'Hiburan';
      case CategoryType.bills:
        return 'Tagihan';
      case CategoryType.health:
        return 'Kesehatan';
      case CategoryType.education:
        return 'Pendidikan';
      case CategoryType.salary:
        return 'Gaji';
      case CategoryType.investment:
        return 'Investasi';
      case CategoryType.gift:
        return 'Hadiah';
      case CategoryType.other:
        return 'Lainnya';
    }
  }

  String get emoji {
    switch (this) {
      case CategoryType.food:
        return '🍔';
      case CategoryType.transportation:
        return '🚗';
      case CategoryType.shopping:
        return '🛒';
      case CategoryType.entertainment:
        return '🎬';
      case CategoryType.bills:
        return '📄';
      case CategoryType.health:
        return '💊';
      case CategoryType.education:
        return '📚';
      case CategoryType.salary:
        return '💰';
      case CategoryType.investment:
        return '📈';
      case CategoryType.gift:
        return '🎁';
      case CategoryType.other:
        return '📦';
    }
  }

  IconData get icon {
    switch (this) {
      case CategoryType.food:
        return Icons.restaurant;
      case CategoryType.transportation:
        return Icons.directions_car;
      case CategoryType.shopping:
        return Icons.shopping_cart;
      case CategoryType.entertainment:
        return Icons.movie;
      case CategoryType.bills:
        return Icons.receipt_long;
      case CategoryType.health:
        return Icons.medical_services;
      case CategoryType.education:
        return Icons.school;
      case CategoryType.salary:
        return Icons.account_balance_wallet;
      case CategoryType.investment:
        return Icons.trending_up;
      case CategoryType.gift:
        return Icons.card_giftcard;
      case CategoryType.other:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case CategoryType.food:
        return const Color(0xFFFF6B6B);
      case CategoryType.transportation:
        return const Color(0xFF4ECDC4);
      case CategoryType.shopping:
        return const Color(0xFFFFE66D);
      case CategoryType.entertainment:
        return const Color(0xFF95E1D3);
      case CategoryType.bills:
        return const Color(0xFFF38181);
      case CategoryType.health:
        return const Color(0xFFAA96DA);
      case CategoryType.education:
        return const Color(0xFF6C5CE7);
      case CategoryType.salary:
        return const Color(0xFF00B894);
      case CategoryType.investment:
        return const Color(0xFF0984E3);
      case CategoryType.gift:
        return const Color(0xFFFDAA5E);
      case CategoryType.other:
        return const Color(0xFF636E72);
    }
  }

  bool get isIncome {
    return this == CategoryType.salary ||
        this == CategoryType.investment ||
        this == CategoryType.gift;
  }

  bool get isIncomeCategory => isIncome;
}
