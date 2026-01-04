import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/export_service.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

// Export service provider
final exportServiceProvider = Provider<ExportService>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return ExportService(repository);
});

// Export state provider
enum ExportFormat { csv, summary }

class ExportState {
  final bool isLoading;
  final String? filePath;
  final String? error;
  final ExportFormat format;
  
  const ExportState({
    this.isLoading = false,
    this.filePath,
    this.error,
    this.format = ExportFormat.csv,
  });
  
  ExportState copyWith({
    bool? isLoading,
    String? filePath,
    String? error,
    ExportFormat? format,
  }) {
    return ExportState(
      isLoading: isLoading ?? this.isLoading,
      filePath: filePath ?? this.filePath,
      error: error ?? this.error,
      format: format ?? this.format,
    );
  }
}

class ExportNotifier extends StateNotifier<ExportState> {
  final ExportService _service;
  
  ExportNotifier(this._service) : super(const ExportState());
  
  Future<void> exportToCSV({DateTime? startDate, DateTime? endDate}) async {
    state = state.copyWith(isLoading: true, error: null, filePath: null);
    
    try {
      final path = await _service.exportToCSV(
        startDate: startDate,
        endDate: endDate,
      );
      
      if (path != null) {
        state = state.copyWith(isLoading: false, filePath: path);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Tidak ada transaksi untuk diekspor',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<void> exportSummary({DateTime? startDate, DateTime? endDate}) async {
    state = state.copyWith(isLoading: true, error: null, filePath: null);
    
    try {
      final path = await _service.exportSummary(
        startDate: startDate,
        endDate: endDate,
      );
      
      if (path != null) {
        state = state.copyWith(isLoading: false, filePath: path);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Tidak ada transaksi untuk diekspor',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<void> shareFile() async {
    if (state.filePath != null) {
      await _service.shareFile(state.filePath!);
    }
  }
  
  void reset() {
    state = const ExportState();
  }
}

final exportNotifierProvider = StateNotifierProvider<ExportNotifier, ExportState>((ref) {
  final service = ref.watch(exportServiceProvider);
  return ExportNotifier(service);
});
