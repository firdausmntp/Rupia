// lib/features/recurring/data/models/recurring_transaction_model.dart

import 'package:equatable/equatable.dart';
import '../../../../core/enums/recurrence_type.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/enums/category_type.dart';
import '../../../../core/enums/currency_code.dart';

/// Model untuk transaksi berulang/recurring
class RecurringTransactionModel extends Equatable {
  final int? id;
  final String name;
  final double amount;
  final TransactionType type;
  final CategoryType category;
  final RecurrenceType recurrence;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastProcessedDate;
  final DateTime? nextDueDate;
  final bool isActive;
  final String? note;
  final CurrencyCode currency;
  final bool autoCreate;
  final int? reminderDaysBefore;
  final String? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RecurringTransactionModel({
    this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.category,
    required this.recurrence,
    required this.startDate,
    this.endDate,
    this.lastProcessedDate,
    this.nextDueDate,
    this.isActive = true,
    this.note,
    this.currency = CurrencyCode.idr,
    this.autoCreate = true,
    this.reminderDaysBefore,
    this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  bool get isDueToday {
    if (nextDueDate == null) return false;
    final now = DateTime.now();
    return nextDueDate!.year == now.year &&
        nextDueDate!.month == now.month &&
        nextDueDate!.day == now.day;
  }

  bool get isDueSoon {
    if (nextDueDate == null || reminderDaysBefore == null) return false;
    final reminderDate = nextDueDate!.subtract(Duration(days: reminderDaysBefore!));
    return DateTime.now().isAfter(reminderDate) && DateTime.now().isBefore(nextDueDate!);
  }

  DateTime calculateNextDueDate() {
    final baseDate = lastProcessedDate ?? startDate;
    return recurrence.getNextDate(baseDate);
  }

  RecurringTransactionModel copyWith({
    int? id,
    String? name,
    double? amount,
    TransactionType? type,
    CategoryType? category,
    RecurrenceType? recurrence,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastProcessedDate,
    DateTime? nextDueDate,
    bool? isActive,
    String? note,
    CurrencyCode? currency,
    bool? autoCreate,
    int? reminderDaysBefore,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransactionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      recurrence: recurrence ?? this.recurrence,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastProcessedDate: lastProcessedDate ?? this.lastProcessedDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      note: note ?? this.note,
      currency: currency ?? this.currency,
      autoCreate: autoCreate ?? this.autoCreate,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'recurrence': recurrence.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'last_processed_date': lastProcessedDate?.toIso8601String(),
      'next_due_date': nextDueDate?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'note': note,
      'currency': currency.code,
      'auto_create': autoCreate ? 1 : 0,
      'reminder_days_before': reminderDaysBefore,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory RecurringTransactionModel.fromMap(Map<String, dynamic> map) {
    return RecurringTransactionModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      category: CategoryType.values.firstWhere((e) => e.name == map['category']),
      recurrence: RecurrenceType.values.firstWhere((e) => e.name == map['recurrence']),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      lastProcessedDate: map['last_processed_date'] != null 
          ? DateTime.parse(map['last_processed_date'] as String) 
          : null,
      nextDueDate: map['next_due_date'] != null 
          ? DateTime.parse(map['next_due_date'] as String) 
          : null,
      isActive: (map['is_active'] as int?) == 1,
      note: map['note'] as String?,
      currency: CurrencyCode.fromCode(map['currency'] as String? ?? 'IDR'),
      autoCreate: (map['auto_create'] as int?) == 1,
      reminderDaysBefore: map['reminder_days_before'] as int?,
      userId: map['user_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        type,
        category,
        recurrence,
        startDate,
        endDate,
        lastProcessedDate,
        nextDueDate,
        isActive,
        note,
        currency,
        autoCreate,
        reminderDaysBefore,
        userId,
        createdAt,
        updatedAt,
      ];
}
