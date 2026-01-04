// lib/features/bills/data/models/bill_model.dart

import 'package:equatable/equatable.dart';
import '../../../../core/enums/bill_status.dart';
import '../../../../core/enums/recurrence_type.dart';
import '../../../../core/enums/currency_code.dart';

/// Model untuk tagihan/bill
class BillModel extends Equatable {
  final int? id;
  final String name;
  final double amount;
  final BillCategory category;
  final BillStatus status;
  final DateTime dueDate;
  final RecurrenceType? recurrence;
  final bool isRecurring;
  final String? billerName;
  final String? accountNumber;
  final String? note;
  final CurrencyCode currency;
  final bool reminderEnabled;
  final int reminderDaysBefore;
  final DateTime? paidDate;
  final double? paidAmount;
  final String? receiptImagePath;
  final int? linkedTransactionId;
  final String? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BillModel({
    this.id,
    required this.name,
    required this.amount,
    required this.category,
    this.status = BillStatus.pending,
    required this.dueDate,
    this.recurrence,
    this.isRecurring = false,
    this.billerName,
    this.accountNumber,
    this.note,
    this.currency = CurrencyCode.idr,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 3,
    this.paidDate,
    this.paidAmount,
    this.receiptImagePath,
    this.linkedTransactionId,
    this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPaid => status == BillStatus.paid;
  bool get isPending => status == BillStatus.pending;
  bool get isCancelled => status == BillStatus.cancelled;
  
  bool get isOverdue {
    if (isPaid || isCancelled) return false;
    return DateTime.now().isAfter(dueDate);
  }

  bool get isDueSoon {
    if (isPaid || isCancelled) return false;
    final reminderDate = dueDate.subtract(Duration(days: reminderDaysBefore));
    return DateTime.now().isAfter(reminderDate) && DateTime.now().isBefore(dueDate);
  }

  bool get isDueToday {
    if (isPaid || isCancelled) return false;
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  int get daysUntilDue {
    final now = DateTime.now();
    return dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  BillStatus get calculatedStatus {
    if (status == BillStatus.paid || status == BillStatus.cancelled) {
      return status;
    }
    if (isOverdue) {
      return BillStatus.overdue;
    }
    return BillStatus.pending;
  }

  DateTime? get nextDueDate {
    if (!isRecurring || recurrence == null) return null;
    return recurrence!.getNextDate(dueDate);
  }

  BillModel copyWith({
    int? id,
    String? name,
    double? amount,
    BillCategory? category,
    BillStatus? status,
    DateTime? dueDate,
    RecurrenceType? recurrence,
    bool? isRecurring,
    String? billerName,
    String? accountNumber,
    String? note,
    CurrencyCode? currency,
    bool? reminderEnabled,
    int? reminderDaysBefore,
    DateTime? paidDate,
    double? paidAmount,
    String? receiptImagePath,
    int? linkedTransactionId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      recurrence: recurrence ?? this.recurrence,
      isRecurring: isRecurring ?? this.isRecurring,
      billerName: billerName ?? this.billerName,
      accountNumber: accountNumber ?? this.accountNumber,
      note: note ?? this.note,
      currency: currency ?? this.currency,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      paidDate: paidDate ?? this.paidDate,
      paidAmount: paidAmount ?? this.paidAmount,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      linkedTransactionId: linkedTransactionId ?? this.linkedTransactionId,
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
      'category': category.name,
      'status': status.name,
      'due_date': dueDate.toIso8601String(),
      'recurrence': recurrence?.name,
      'is_recurring': isRecurring ? 1 : 0,
      'biller_name': billerName,
      'account_number': accountNumber,
      'note': note,
      'currency': currency.code,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_days_before': reminderDaysBefore,
      'paid_date': paidDate?.toIso8601String(),
      'paid_amount': paidAmount,
      'receipt_image_path': receiptImagePath,
      'linked_transaction_id': linkedTransactionId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: BillCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => BillCategory.other,
      ),
      status: BillStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BillStatus.pending,
      ),
      dueDate: DateTime.parse(map['due_date'] as String),
      recurrence: map['recurrence'] != null
          ? RecurrenceType.values.firstWhere(
              (e) => e.name == map['recurrence'],
              orElse: () => RecurrenceType.monthly,
            )
          : null,
      isRecurring: (map['is_recurring'] as int?) == 1,
      billerName: map['biller_name'] as String?,
      accountNumber: map['account_number'] as String?,
      note: map['note'] as String?,
      currency: CurrencyCode.fromCode(map['currency'] as String? ?? 'IDR'),
      reminderEnabled: (map['reminder_enabled'] as int?) != 0,
      reminderDaysBefore: map['reminder_days_before'] as int? ?? 3,
      paidDate: map['paid_date'] != null ? DateTime.parse(map['paid_date'] as String) : null,
      paidAmount: (map['paid_amount'] as num?)?.toDouble(),
      receiptImagePath: map['receipt_image_path'] as String?,
      linkedTransactionId: map['linked_transaction_id'] as int?,
      userId: map['user_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  /// Mark bill as paid and create next occurrence if recurring
  BillModel markAsPaid({double? actualAmount, String? receiptPath}) {
    return copyWith(
      status: BillStatus.paid,
      paidDate: DateTime.now(),
      paidAmount: actualAmount ?? amount,
      receiptImagePath: receiptPath ?? receiptImagePath,
      updatedAt: DateTime.now(),
    );
  }

  /// Create next recurring bill from this one
  BillModel? createNextRecurrence() {
    if (!isRecurring || recurrence == null) return null;
    
    return BillModel(
      name: name,
      amount: amount,
      category: category,
      status: BillStatus.pending,
      dueDate: recurrence!.getNextDate(dueDate),
      recurrence: recurrence,
      isRecurring: true,
      billerName: billerName,
      accountNumber: accountNumber,
      note: note,
      currency: currency,
      reminderEnabled: reminderEnabled,
      reminderDaysBefore: reminderDaysBefore,
      userId: userId,
      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        category,
        status,
        dueDate,
        recurrence,
        isRecurring,
        billerName,
        accountNumber,
        note,
        currency,
        reminderEnabled,
        reminderDaysBefore,
        paidDate,
        paidAmount,
        receiptImagePath,
        linkedTransactionId,
        userId,
        createdAt,
        updatedAt,
      ];
}
