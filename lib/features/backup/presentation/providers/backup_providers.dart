import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/backup_model.dart';
import '../../data/repositories/backup_repository.dart';

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepository();
});

final backupsProvider = StreamProvider<List<BackupModel>>((ref) {
  final repository = ref.watch(backupRepositoryProvider);
  return repository.getBackups();
});

final backupNotifierProvider =
    StateNotifierProvider<BackupNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(backupRepositoryProvider);
  return BackupNotifier(repository);
});

class BackupNotifier extends StateNotifier<AsyncValue<void>> {
  final BackupRepository _repository;

  BackupNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createBackup({String? notes}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.createBackup(notes: notes));
  }

  Future<void> restoreBackup(String backupId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.restoreBackup(backupId));
  }

  Future<void> deleteBackup(String backupId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteBackup(backupId));
  }
}
