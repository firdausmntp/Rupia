import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/services/database_service.dart';
import '../models/backup_model.dart';

/// Repository untuk mengelola backup dan restore
class BackupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Membuat backup semua data ke cloud
  Future<BackupModel> createBackup({String? notes}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // 1. Ambil semua data dari SQLite
    final db = await DatabaseService.database;
    
    final transactions = await db.query('transactions');
    final budgets = await db.query('budgets');
    final debts = await db.query('debts');

    // 2. Buat file JSON backup
    final backupData = {
      'version': '3.1.0',
      'createdAt': DateTime.now().toIso8601String(),
      'userId': user.uid,
      'transactions': transactions,
      'budgets': budgets,
      'debts': debts,
    };

    // 3. Compress dengan GZip
    final jsonString = jsonEncode(backupData);
    final bytes = utf8.encode(jsonString);
    final compressed = GZipEncoder().encode(bytes);

    // 4. Upload ke Firebase Storage
    final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json.gz';
    final storageRef = _storage.ref().child('backups/${user.uid}/$fileName');
    
    await storageRef.putData(
      Uint8List.fromList(compressed!),
      SettableMetadata(contentType: 'application/gzip'),
    );

    // 5. Simpan metadata ke Firestore
    final fileSize = compressed.length / (1024 * 1024); // MB
    final backup = BackupModel(
      id: fileName,
      createdAt: DateTime.now(),
      transactionCount: transactions.length,
      budgetCount: budgets.length,
      debtCount: debts.length,
      fileSize: fileSize,
      userId: user.uid,
      notes: notes,
      status: BackupStatus.completed,
    );

    await _firestore
        .collection('backups')
        .doc(fileName)
        .set(backup.toFirestore());

    return backup;
  }

  /// Restore data dari backup
  Future<void> restoreBackup(String backupId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // 1. Download file dari Storage
    final storageRef = _storage.ref().child('backups/${user.uid}/$backupId');
    final bytes = await storageRef.getData();
    
    if (bytes == null) throw Exception('Backup file not found');

    // 2. Decompress
    final decompressed = GZipDecoder().decodeBytes(bytes);
    final jsonString = utf8.decode(decompressed);
    final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

    // 3. Clear existing data
    final db = await DatabaseService.database;
    await db.delete('transactions');
    await db.delete('budgets');
    await db.delete('debts');

    // 4. Restore data
    final transactions = backupData['transactions'] as List;
    final budgets = backupData['budgets'] as List;
    final debts = backupData['debts'] as List;

    for (var transaction in transactions) {
      await db.insert('transactions', transaction as Map<String, dynamic>);
    }
    
    for (var budget in budgets) {
      await db.insert('budgets', budget as Map<String, dynamic>);
    }
    
    for (var debt in debts) {
      await db.insert('debts', debt as Map<String, dynamic>);
    }
  }

  /// Mendapatkan daftar backup
  Stream<List<BackupModel>> getBackups() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('backups')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BackupModel.fromFirestore(doc)).toList());
  }

  /// Hapus backup
  Future<void> deleteBackup(String backupId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Hapus dari Storage
    final storageRef = _storage.ref().child('backups/${user.uid}/$backupId');
    await storageRef.delete();

    // Hapus dari Firestore
    await _firestore.collection('backups').doc(backupId).delete();
  }

  /// Export backup ke local file untuk manual sharing
  Future<File> exportBackupToLocal(String backupId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final storageRef = _storage.ref().child('backups/${user.uid}/$backupId');
    final bytes = await storageRef.getData();
    
    if (bytes == null) throw Exception('Backup file not found');

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$backupId');
    await file.writeAsBytes(bytes);

    return file;
  }

  /// Import backup dari local file
  Future<void> importBackupFromLocal(File file) async {
    final bytes = await file.readAsBytes();
    
    // Decompress dan parse
    final decompressed = GZipDecoder().decodeBytes(bytes);
    final jsonString = utf8.decode(decompressed);
    final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

    // Restore seperti biasa
    final db = await DatabaseService.database;
    await db.delete('transactions');
    await db.delete('budgets');
    await db.delete('debts');

    final transactions = backupData['transactions'] as List;
    final budgets = backupData['budgets'] as List;
    final debts = backupData['debts'] as List;

    for (var transaction in transactions) {
      await db.insert('transactions', transaction as Map<String, dynamic>);
    }
    
    for (var budget in budgets) {
      await db.insert('budgets', budget as Map<String, dynamic>);
    }
    
    for (var debt in debts) {
      await db.insert('debts', debt as Map<String, dynamic>);
    }
  }
}
