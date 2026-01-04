// lib/features/split/data/models/split_transaction_model.dart

import 'package:equatable/equatable.dart';
import '../../../../core/enums/category_type.dart';
import '../../../../core/enums/currency_code.dart';

/// Status pembayaran untuk split participant
enum SplitPaymentStatus {
  pending,
  paid,
  declined;

  String get displayName {
    switch (this) {
      case SplitPaymentStatus.pending:
        return 'Menunggu';
      case SplitPaymentStatus.paid:
        return 'Lunas';
      case SplitPaymentStatus.declined:
        return 'Ditolak';
    }
  }

  String get displayNameEn {
    switch (this) {
      case SplitPaymentStatus.pending:
        return 'Pending';
      case SplitPaymentStatus.paid:
        return 'Paid';
      case SplitPaymentStatus.declined:
        return 'Declined';
    }
  }
}

/// Model untuk item/participant dalam split transaction
class SplitItemModel extends Equatable {
  final int? id;
  final int splitTransactionId;
  final String participantName;
  final String? participantEmail;
  final String? participantPhone;
  final double amount;
  final double? percentage;
  final SplitPaymentStatus status;
  final DateTime? paidAt;
  final String? note;

  const SplitItemModel({
    this.id,
    required this.splitTransactionId,
    required this.participantName,
    this.participantEmail,
    this.participantPhone,
    required this.amount,
    this.percentage,
    this.status = SplitPaymentStatus.pending,
    this.paidAt,
    this.note,
  });

  bool get isPaid => status == SplitPaymentStatus.paid;
  bool get isPending => status == SplitPaymentStatus.pending;

  SplitItemModel copyWith({
    int? id,
    int? splitTransactionId,
    String? participantName,
    String? participantEmail,
    String? participantPhone,
    double? amount,
    double? percentage,
    SplitPaymentStatus? status,
    DateTime? paidAt,
    String? note,
  }) {
    return SplitItemModel(
      id: id ?? this.id,
      splitTransactionId: splitTransactionId ?? this.splitTransactionId,
      participantName: participantName ?? this.participantName,
      participantEmail: participantEmail ?? this.participantEmail,
      participantPhone: participantPhone ?? this.participantPhone,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'split_transaction_id': splitTransactionId,
      'participant_name': participantName,
      'participant_email': participantEmail,
      'participant_phone': participantPhone,
      'amount': amount,
      'percentage': percentage,
      'status': status.name,
      'paid_at': paidAt?.toIso8601String(),
      'note': note,
    };
  }

  factory SplitItemModel.fromMap(Map<String, dynamic> map) {
    return SplitItemModel(
      id: map['id'] as int?,
      splitTransactionId: map['split_transaction_id'] as int,
      participantName: map['participant_name'] as String,
      participantEmail: map['participant_email'] as String?,
      participantPhone: map['participant_phone'] as String?,
      amount: (map['amount'] as num).toDouble(),
      percentage: (map['percentage'] as num?)?.toDouble(),
      status: SplitPaymentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SplitPaymentStatus.pending,
      ),
      paidAt: map['paid_at'] != null ? DateTime.parse(map['paid_at'] as String) : null,
      note: map['note'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        splitTransactionId,
        participantName,
        participantEmail,
        participantPhone,
        amount,
        percentage,
        status,
        paidAt,
        note,
      ];
}

/// Tipe pembagian split
enum SplitType {
  equal,
  percentage,
  custom;

  String get displayName {
    switch (this) {
      case SplitType.equal:
        return 'Sama Rata';
      case SplitType.percentage:
        return 'Persentase';
      case SplitType.custom:
        return 'Kustom';
    }
  }

  String get displayNameEn {
    switch (this) {
      case SplitType.equal:
        return 'Equal';
      case SplitType.percentage:
        return 'Percentage';
      case SplitType.custom:
        return 'Custom';
    }
  }
}

/// Model untuk transaksi split
class SplitTransactionModel extends Equatable {
  final int? id;
  final String description;
  final double totalAmount;
  final CategoryType category;
  final DateTime date;
  final SplitType splitType;
  final CurrencyCode currency;
  final List<SplitItemModel> items;
  final String? receiptImagePath;
  final String? note;
  final String? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SplitTransactionModel({
    this.id,
    required this.description,
    required this.totalAmount,
    required this.category,
    required this.date,
    this.splitType = SplitType.equal,
    this.currency = CurrencyCode.idr,
    this.items = const [],
    this.receiptImagePath,
    this.note,
    this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  int get participantCount => items.length;
  
  double get totalPaid => items
      .where((item) => item.isPaid)
      .fold(0.0, (sum, item) => sum + item.amount);
  
  double get totalPending => items
      .where((item) => item.isPending)
      .fold(0.0, (sum, item) => sum + item.amount);
  
  double get paidPercentage => totalAmount > 0 ? (totalPaid / totalAmount * 100) : 0;
  
  bool get isFullyPaid => totalPaid >= totalAmount;
  
  int get paidCount => items.where((item) => item.isPaid).length;
  int get pendingCount => items.where((item) => item.isPending).length;

  SplitTransactionModel copyWith({
    int? id,
    String? description,
    double? totalAmount,
    CategoryType? category,
    DateTime? date,
    SplitType? splitType,
    CurrencyCode? currency,
    List<SplitItemModel>? items,
    String? receiptImagePath,
    String? note,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SplitTransactionModel(
      id: id ?? this.id,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      category: category ?? this.category,
      date: date ?? this.date,
      splitType: splitType ?? this.splitType,
      currency: currency ?? this.currency,
      items: items ?? this.items,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      note: note ?? this.note,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'total_amount': totalAmount,
      'category': category.name,
      'date': date.toIso8601String(),
      'split_type': splitType.name,
      'currency': currency.code,
      'receipt_image_path': receiptImagePath,
      'note': note,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory SplitTransactionModel.fromMap(Map<String, dynamic> map, {List<SplitItemModel>? items}) {
    return SplitTransactionModel(
      id: map['id'] as int?,
      description: map['description'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      category: CategoryType.values.firstWhere((e) => e.name == map['category']),
      date: DateTime.parse(map['date'] as String),
      splitType: SplitType.values.firstWhere(
        (e) => e.name == map['split_type'],
        orElse: () => SplitType.equal,
      ),
      currency: CurrencyCode.fromCode(map['currency'] as String? ?? 'IDR'),
      items: items ?? [],
      receiptImagePath: map['receipt_image_path'] as String?,
      note: map['note'] as String?,
      userId: map['user_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  /// Create split with equal distribution
  static SplitTransactionModel createEqual({
    required String description,
    required double totalAmount,
    required CategoryType category,
    required DateTime date,
    required List<String> participantNames,
    CurrencyCode currency = CurrencyCode.idr,
    String? note,
    String? userId,
  }) {
    final amountPerPerson = totalAmount / participantNames.length;
    final percentagePerPerson = 100.0 / participantNames.length;

    return SplitTransactionModel(
      description: description,
      totalAmount: totalAmount,
      category: category,
      date: date,
      splitType: SplitType.equal,
      currency: currency,
      note: note,
      userId: userId,
      createdAt: DateTime.now(),
      items: participantNames.asMap().entries.map((entry) {
        return SplitItemModel(
          splitTransactionId: 0, // Will be set after insert
          participantName: entry.value,
          amount: amountPerPerson,
          percentage: percentagePerPerson,
        );
      }).toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        description,
        totalAmount,
        category,
        date,
        splitType,
        currency,
        items,
        receiptImagePath,
        note,
        userId,
        createdAt,
        updatedAt,
      ];
}
