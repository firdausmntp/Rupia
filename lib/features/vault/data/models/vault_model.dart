// lib/features/vault/data/models/vault_model.dart

class VaultModel {
  final String id;
  final String name;
  final String ownerId;
  final String ownerEmail;
  final List<VaultMember> members;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VaultModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.ownerEmail,
    this.members = const [],
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'members': members.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory VaultModel.fromMap(Map<String, dynamic> map) {
    return VaultModel(
      id: map['id'] as String,
      name: map['name'] as String,
      ownerId: map['ownerId'] as String,
      ownerEmail: map['ownerEmail'] as String,
      members: (map['members'] as List<dynamic>?)
          ?.map((m) => VaultMember.fromMap(m as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  VaultModel copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? ownerEmail,
    List<VaultMember>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VaultModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOwner => true; // Implement with actual user ID check
  int get memberCount => members.length + 1; // +1 for owner
}

class VaultMember {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final MemberStatus status;
  final DateTime joinedAt;

  VaultMember({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.status = MemberStatus.pending,
    required this.joinedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'status': status.name,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory VaultMember.fromMap(Map<String, dynamic> map) {
    return VaultMember(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      status: MemberStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => MemberStatus.pending,
      ),
      joinedAt: DateTime.parse(map['joinedAt'] as String),
    );
  }

  bool get isPending => status == MemberStatus.pending;
  bool get isActive => status == MemberStatus.active;
}

enum MemberStatus {
  pending,
  active,
  left,
  removed,
}

class VaultTransaction {
  final String id;
  final String vaultId;
  final String addedByUserId;
  final String addedByEmail;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final DateTime createdAt;

  VaultTransaction({
    required this.id,
    required this.vaultId,
    required this.addedByUserId,
    required this.addedByEmail,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vaultId': vaultId,
      'addedByUserId': addedByUserId,
      'addedByEmail': addedByEmail,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VaultTransaction.fromMap(Map<String, dynamic> map) {
    return VaultTransaction(
      id: map['id'] as String,
      vaultId: map['vaultId'] as String,
      addedByUserId: map['addedByUserId'] as String,
      addedByEmail: map['addedByEmail'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
