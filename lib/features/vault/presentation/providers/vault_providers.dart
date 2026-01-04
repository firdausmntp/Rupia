// lib/features/vault/presentation/providers/vault_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/vault_model.dart';
import '../../data/services/vault_service.dart';

final vaultServiceProvider = Provider<VaultService>((ref) {
  return VaultService();
});

final userVaultsProvider = StreamProvider<List<VaultModel>>((ref) {
  final service = ref.watch(vaultServiceProvider);
  return service.watchUserVaults();
});

final pendingInvitationsProvider = FutureProvider<List<VaultModel>>((ref) async {
  final service = ref.watch(vaultServiceProvider);
  return await service.getPendingInvitations();
});

final vaultTransactionsProvider = StreamProviderFamily<List<VaultTransaction>, String>((ref, vaultId) {
  final service = ref.watch(vaultServiceProvider);
  return service.watchVaultTransactions(vaultId);
});

final vaultSummaryProvider = FutureProviderFamily<VaultSummary, String>((ref, vaultId) async {
  final service = ref.watch(vaultServiceProvider);
  return await service.getVaultSummary(vaultId);
});

class VaultState {
  final bool isLoading;
  final String? error;
  final VaultModel? selectedVault;

  const VaultState({
    this.isLoading = false,
    this.error,
    this.selectedVault,
  });

  VaultState copyWith({
    bool? isLoading,
    String? error,
    VaultModel? selectedVault,
  }) {
    return VaultState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedVault: selectedVault ?? this.selectedVault,
    );
  }
}

class VaultNotifier extends StateNotifier<VaultState> {
  final VaultService _service;

  VaultNotifier(this._service) : super(const VaultState());

  Future<void> createVault(String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.createVault(name);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> inviteMember(String vaultId, String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.inviteMember(vaultId, email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> acceptInvitation(String vaultId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.acceptInvitation(vaultId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> leaveVault(String vaultId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.leaveVault(vaultId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> removeMember(String vaultId, String memberId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.removeMember(vaultId, memberId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteVault(String vaultId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.deleteVault(vaultId);
      state = state.copyWith(isLoading: false, selectedVault: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addTransaction(VaultTransaction transaction) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.addTransaction(transaction);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectVault(VaultModel vault) {
    state = state.copyWith(selectedVault: vault);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final vaultNotifierProvider = StateNotifierProvider<VaultNotifier, VaultState>((ref) {
  final service = ref.watch(vaultServiceProvider);
  return VaultNotifier(service);
});
