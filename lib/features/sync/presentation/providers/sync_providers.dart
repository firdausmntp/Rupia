import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/google_sheets_service.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';

// Repository provider
final transactionRepositoryForSyncProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// Google Sheets service provider
final googleSheetsServiceProvider = Provider<GoogleSheetsService>((ref) {
  final repository = ref.watch(transactionRepositoryForSyncProvider);
  return GoogleSheetsService(repository);
});

// Sync state
class SyncState {
  final bool isConnected;
  final bool isSyncing;
  final DateTime? lastSync;
  final String? spreadsheetUrl;
  final String? errorMessage;

  SyncState({
    this.isConnected = false,
    this.isSyncing = false,
    this.lastSync,
    this.spreadsheetUrl,
    this.errorMessage,
  });

  SyncState copyWith({
    bool? isConnected,
    bool? isSyncing,
    DateTime? lastSync,
    String? spreadsheetUrl,
    String? errorMessage,
  }) {
    return SyncState(
      isConnected: isConnected ?? this.isConnected,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSync: lastSync ?? this.lastSync,
      spreadsheetUrl: spreadsheetUrl ?? this.spreadsheetUrl,
      errorMessage: errorMessage,
    );
  }
}

// Sync notifier
class SyncNotifier extends StateNotifier<SyncState> {
  final GoogleSheetsService _service;

  SyncNotifier(this._service) : super(SyncState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _service.initialize();
    final lastSync = await _service.getLastSyncTime();
    state = state.copyWith(
      isConnected: _service.isConnected,
      lastSync: lastSync,
      spreadsheetUrl: _service.getSpreadsheetUrl(),
    );
  }

  Future<void> configureService(String clientId, String clientSecret) async {
    await _service.configure(clientId: clientId, clientSecret: clientSecret);
  }

  String getAuthUrl() {
    return _service.getAuthorizationUrl();
  }

  Future<bool> authenticate(String code) async {
    state = state.copyWith(isSyncing: true);
    final success = await _service.exchangeCodeForToken(code);
    
    if (success) {
      // Create spreadsheet if not exists
      if (_service.getSpreadsheetUrl() == null) {
        await _service.createSpreadsheet();
      }
      
      state = state.copyWith(
        isConnected: true,
        isSyncing: false,
        spreadsheetUrl: _service.getSpreadsheetUrl(),
      );
    } else {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Gagal autentikasi',
      );
    }
    
    return success;
  }

  Future<SyncResult> sync() async {
    state = state.copyWith(isSyncing: true, errorMessage: null);
    
    final result = await _service.syncTransactions();
    final lastSync = await _service.getLastSyncTime();
    
    state = state.copyWith(
      isSyncing: false,
      lastSync: lastSync,
      errorMessage: result.success ? null : result.message,
    );
    
    return result;
  }

  Future<void> disconnect() async {
    await _service.disconnect();
    state = SyncState();
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final service = ref.watch(googleSheetsServiceProvider);
  return SyncNotifier(service);
});
