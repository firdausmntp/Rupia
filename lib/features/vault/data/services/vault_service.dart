// lib/features/vault/data/services/vault_service.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/vault_model.dart';

class VaultService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _vaultsCollection =>
      _firestore.collection('vaults');

  String? get _currentUserId => _auth.currentUser?.uid;
  String? get _currentUserEmail => _auth.currentUser?.email;

  // Create a new vault
  Future<VaultModel> createVault(String name) async {
    if (_currentUserId == null || _currentUserEmail == null) {
      throw VaultException('User not authenticated');
    }

    final vault = VaultModel(
      id: _uuid.v4(),
      name: name,
      ownerId: _currentUserId!,
      ownerEmail: _currentUserEmail!,
      members: [],
      createdAt: DateTime.now(),
    );

    await _vaultsCollection.doc(vault.id).set(vault.toMap());
    return vault;
  }

  // Get all vaults for current user (owned + member of)
  Stream<List<VaultModel>> watchUserVaults() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    // Get vaults owned by user
    return _vaultsCollection
        .where('ownerId', isEqualTo: _currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
      final ownedVaults = snapshot.docs
          .map((doc) => VaultModel.fromMap(doc.data()))
          .toList();

      // Also get vaults where user is a member
      final memberSnapshot = await _vaultsCollection
          .where('members', arrayContains: {
            'id': _currentUserId,
            'status': 'active',
          })
          .get();

      final memberVaults = memberSnapshot.docs
          .map((doc) => VaultModel.fromMap(doc.data()))
          .toList();

      return [...ownedVaults, ...memberVaults];
    });
  }

  // Get vault by ID
  Future<VaultModel?> getVault(String vaultId) async {
    final doc = await _vaultsCollection.doc(vaultId).get();
    if (!doc.exists) return null;
    return VaultModel.fromMap(doc.data()!);
  }

  // Invite member to vault
  Future<void> inviteMember(String vaultId, String email) async {
    final vault = await getVault(vaultId);
    if (vault == null) throw VaultException('Vault not found');
    
    if (vault.ownerId != _currentUserId) {
      throw VaultException('Only owner can invite members');
    }

    // Check if already invited or member
    if (vault.members.any((m) => m.email == email)) {
      throw VaultException('User already invited');
    }

    if (vault.ownerEmail == email) {
      throw VaultException('Cannot invite yourself');
    }

    // Check max members (limit 5)
    if (vault.members.length >= 4) {
      throw VaultException('Maximum 5 members per vault');
    }

    final member = VaultMember(
      id: _uuid.v4(),
      email: email,
      status: MemberStatus.pending,
      joinedAt: DateTime.now(),
    );

    await _vaultsCollection.doc(vaultId).update({
      'members': FieldValue.arrayUnion([member.toMap()]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Accept vault invitation
  Future<void> acceptInvitation(String vaultId) async {
    if (_currentUserEmail == null) return;

    final vault = await getVault(vaultId);
    if (vault == null) throw VaultException('Vault not found');

    final updatedMembers = vault.members.map((m) {
      if (m.email == _currentUserEmail && m.isPending) {
        return VaultMember(
          id: _currentUserId!,
          email: m.email,
          displayName: _auth.currentUser?.displayName,
          photoUrl: _auth.currentUser?.photoURL,
          status: MemberStatus.active,
          joinedAt: DateTime.now(),
        );
      }
      return m;
    }).toList();

    await _vaultsCollection.doc(vaultId).update({
      'members': updatedMembers.map((m) => m.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Reject/leave vault
  Future<void> leaveVault(String vaultId) async {
    if (_currentUserId == null) return;

    final vault = await getVault(vaultId);
    if (vault == null) throw VaultException('Vault not found');

    if (vault.ownerId == _currentUserId) {
      throw VaultException('Owner cannot leave vault. Delete vault instead.');
    }

    final updatedMembers = vault.members
        .where((m) => m.id != _currentUserId)
        .toList();

    await _vaultsCollection.doc(vaultId).update({
      'members': updatedMembers.map((m) => m.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Remove member (owner only)
  Future<void> removeMember(String vaultId, String memberId) async {
    final vault = await getVault(vaultId);
    if (vault == null) throw VaultException('Vault not found');

    if (vault.ownerId != _currentUserId) {
      throw VaultException('Only owner can remove members');
    }

    final updatedMembers = vault.members
        .where((m) => m.id != memberId)
        .toList();

    await _vaultsCollection.doc(vaultId).update({
      'members': updatedMembers.map((m) => m.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Delete vault (owner only)
  Future<void> deleteVault(String vaultId) async {
    final vault = await getVault(vaultId);
    if (vault == null) throw VaultException('Vault not found');

    if (vault.ownerId != _currentUserId) {
      throw VaultException('Only owner can delete vault');
    }

    // Delete all transactions in vault
    final transactions = await _vaultsCollection
        .doc(vaultId)
        .collection('transactions')
        .get();
    
    for (final doc in transactions.docs) {
      await doc.reference.delete();
    }

    await _vaultsCollection.doc(vaultId).delete();
  }

  // Add transaction to vault
  Future<void> addTransaction(VaultTransaction transaction) async {
    if (_currentUserId == null) {
      throw VaultException('User not authenticated');
    }

    final vault = await getVault(transaction.vaultId);
    if (vault == null) throw VaultException('Vault not found');

    // Check if user is owner or active member
    final isOwner = vault.ownerId == _currentUserId;
    final isMember = vault.members.any(
      (m) => m.id == _currentUserId && m.isActive,
    );

    if (!isOwner && !isMember) {
      throw VaultException('Not a member of this vault');
    }

    await _vaultsCollection
        .doc(transaction.vaultId)
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  // Watch vault transactions (real-time)
  Stream<List<VaultTransaction>> watchVaultTransactions(String vaultId) {
    return _vaultsCollection
        .doc(vaultId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VaultTransaction.fromMap(doc.data()))
            .toList());
  }

  // Get vault summary
  Future<VaultSummary> getVaultSummary(String vaultId) async {
    final transactions = await _vaultsCollection
        .doc(vaultId)
        .collection('transactions')
        .get();

    double totalExpense = 0;
    final Map<String, double> byMember = {};
    final Map<String, double> byCategory = {};

    for (final doc in transactions.docs) {
      final tx = VaultTransaction.fromMap(doc.data());
      totalExpense += tx.amount;
      
      byMember[tx.addedByEmail] = 
          (byMember[tx.addedByEmail] ?? 0) + tx.amount;
      
      byCategory[tx.category] = 
          (byCategory[tx.category] ?? 0) + tx.amount;
    }

    return VaultSummary(
      totalExpense: totalExpense,
      transactionCount: transactions.docs.length,
      byMember: byMember,
      byCategory: byCategory,
    );
  }

  // Get pending invitations for current user
  Future<List<VaultModel>> getPendingInvitations() async {
    if (_currentUserEmail == null) return [];

    final snapshot = await _vaultsCollection.get();
    final vaults = <VaultModel>[];

    for (final doc in snapshot.docs) {
      final vault = VaultModel.fromMap(doc.data());
      final isPending = vault.members.any(
        (m) => m.email == _currentUserEmail && m.isPending,
      );
      if (isPending) {
        vaults.add(vault);
      }
    }

    return vaults;
  }
}

class VaultSummary {
  final double totalExpense;
  final int transactionCount;
  final Map<String, double> byMember;
  final Map<String, double> byCategory;

  VaultSummary({
    required this.totalExpense,
    required this.transactionCount,
    required this.byMember,
    required this.byCategory,
  });
}

class VaultException implements Exception {
  final String message;
  VaultException(this.message);

  @override
  String toString() => message;
}
