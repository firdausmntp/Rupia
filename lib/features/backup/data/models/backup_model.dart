import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk backup data
class BackupModel {
  final String id;
  final DateTime createdAt;
  final int transactionCount;
  final int budgetCount;
  final int debtCount;
  final double fileSize; // dalam MB
  final String userId;
  final String? notes;
  final BackupStatus status;

  BackupModel({
    required this.id,
    required this.createdAt,
    required this.transactionCount,
    required this.budgetCount,
    required this.debtCount,
    required this.fileSize,
    required this.userId,
    this.notes,
    this.status = BackupStatus.completed,
  });

  factory BackupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BackupModel(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      transactionCount: data['transactionCount'] ?? 0,
      budgetCount: data['budgetCount'] ?? 0,
      debtCount: data['debtCount'] ?? 0,
      fileSize: (data['fileSize'] ?? 0.0).toDouble(),
      userId: data['userId'] ?? '',
      notes: data['notes'],
      status: BackupStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => BackupStatus.completed,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'transactionCount': transactionCount,
      'budgetCount': budgetCount,
      'debtCount': debtCount,
      'fileSize': fileSize,
      'userId': userId,
      'notes': notes,
      'status': status.name,
    };
  }

  BackupModel copyWith({
    String? id,
    DateTime? createdAt,
    int? transactionCount,
    int? budgetCount,
    int? debtCount,
    double? fileSize,
    String? userId,
    String? notes,
    BackupStatus? status,
  }) {
    return BackupModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      transactionCount: transactionCount ?? this.transactionCount,
      budgetCount: budgetCount ?? this.budgetCount,
      debtCount: debtCount ?? this.debtCount,
      fileSize: fileSize ?? this.fileSize,
      userId: userId ?? this.userId,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}

enum BackupStatus {
  inProgress,
  completed,
  failed,
}
