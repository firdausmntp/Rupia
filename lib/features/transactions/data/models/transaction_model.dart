import '../../../../core/enums/transaction_type.dart';
import '../../../../core/enums/mood_type.dart';
import '../../../../core/enums/category_type.dart';

class TransactionModel {
  final int? id;
  final double amount;
  final String description;
  final DateTime date;
  final TransactionType type;
  final CategoryType category;
  final MoodType? mood;
  final String? note;
  final String? receiptImagePath;
  final bool isSynced;
  final DateTime? syncedAt;
  final String? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
    required this.category,
    this.mood,
    this.note,
    this.receiptImagePath,
    this.isSynced = false,
    this.syncedAt,
    this.userId,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'type': type.name,
      'category': category.name,
      'mood': mood?.name,
      'note': note,
      'receiptImagePath': receiptImagePath,
      'isSynced': isSynced ? 1 : 0,
      'syncedAt': syncedAt?.millisecondsSinceEpoch,
      'userId': userId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      category: CategoryType.values.firstWhere((e) => e.name == map['category']),
      mood: map['mood'] != null
          ? MoodType.values.firstWhere((e) => e.name == map['mood'])
          : null,
      note: map['note'] as String?,
      receiptImagePath: map['receiptImagePath'] as String?,
      isSynced: (map['isSynced'] as int) == 1,
      syncedAt: map['syncedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['syncedAt'] as int)
          : null,
      userId: map['userId'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
    );
  }

  TransactionModel copyWith({
    int? id,
    double? amount,
    String? description,
    DateTime? date,
    TransactionType? type,
    CategoryType? category,
    MoodType? mood,
    String? note,
    String? receiptImagePath,
    bool? isSynced,
    DateTime? syncedAt,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt ?? this.syncedAt,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
