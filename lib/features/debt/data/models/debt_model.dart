// lib/features/debt/data/models/debt_model.dart

import 'package:equatable/equatable.dart';

enum DebtType { iOwe, owedToMe }
enum DebtStatus { pending, partial, paid }

class DebtModel extends Equatable {
  final int? id;
  final DebtType type;
  final String personName;
  final double amount;
  final double paidAmount;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? note;
  final DebtStatus status;
  final String? personPhone;
  
  const DebtModel({
    this.id,
    required this.type,
    required this.personName,
    required this.amount,
    this.paidAmount = 0,
    required this.createdAt,
    this.dueDate,
    this.note,
    this.status = DebtStatus.pending,
    this.personPhone,
  });
  
  double get remainingAmount => amount - paidAmount;
  double get paidPercentage => amount > 0 ? (paidAmount / amount * 100) : 0;
  
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && status != DebtStatus.paid;
  }
  
  DebtModel copyWith({
    int? id,
    DebtType? type,
    String? personName,
    double? amount,
    double? paidAmount,
    DateTime? createdAt,
    DateTime? dueDate,
    String? note,
    DebtStatus? status,
    String? personPhone,
  }) {
    return DebtModel(
      id: id ?? this.id,
      type: type ?? this.type,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      status: status ?? this.status,
      personPhone: personPhone ?? this.personPhone,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'personName': personName,
      'amount': amount,
      'paidAmount': paidAmount,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'note': note,
      'status': status.index,
      'personPhone': personPhone,
    };
  }
  
  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'] as int?,
      type: DebtType.values[map['type'] as int],
      personName: map['personName'] as String,
      amount: (map['amount'] as num).toDouble(),
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      note: map['note'] as String?,
      status: DebtStatus.values[map['status'] as int? ?? 0],
      personPhone: map['personPhone'] as String?,
    );
  }
  
  @override
  List<Object?> get props => [id, type, personName, amount, paidAmount, createdAt, dueDate, note, status, personPhone];
}
