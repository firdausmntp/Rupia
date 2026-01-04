class BudgetModel {
  final int? id;
  final String name;
  final double amount;
  final double spent;
  final int month;
  final int year;
  final String? categoryName;
  final String? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BudgetModel({
    this.id,
    required this.name,
    required this.amount,
    this.spent = 0,
    required this.month,
    required this.year,
    this.categoryName,
    this.userId,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get remaining => amount - spent;
  double get percentUsed => amount > 0 ? (spent / amount) * 100 : 0;
  bool get isOverBudget => spent > amount;
  bool get isWarning => percentUsed >= 80 && percentUsed < 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'spent': spent,
      'month': month,
      'year': year,
      'categoryName': categoryName,
      'userId': userId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      spent: (map['spent'] as num).toDouble(),
      month: map['month'] as int,
      year: map['year'] as int,
      categoryName: map['categoryName'] as String?,
      userId: map['userId'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
    );
  }

  BudgetModel copyWith({
    int? id,
    String? name,
    double? amount,
    double? spent,
    int? month,
    int? year,
    String? categoryName,
    String? userId,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      month: month ?? this.month,
      year: year ?? this.year,
      categoryName: categoryName ?? this.categoryName,
      userId: userId ?? this.userId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
