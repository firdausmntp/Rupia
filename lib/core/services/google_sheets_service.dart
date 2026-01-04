import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/transactions/data/repositories/transaction_repository.dart';
import '../utils/date_formatter.dart';

/// Service to sync transactions with Google Sheets
/// Uses Google Sheets API to create and update a spreadsheet
class GoogleSheetsService {
  static const String _spreadsheetIdKey = 'google_sheets_spreadsheet_id';
  static const String _accessTokenKey = 'google_sheets_access_token';
  static const String _refreshTokenKey = 'google_sheets_refresh_token';
  static const String _lastSyncKey = 'google_sheets_last_sync';

  final _secureStorage = const FlutterSecureStorage();
  final TransactionRepository _transactionRepository;

  // Google OAuth credentials (you'll need to set these from Google Cloud Console)
  String? _clientId;
  String? _clientSecret;
  String? _spreadsheetId;
  String? _accessToken;

  GoogleSheetsService(this._transactionRepository);

  bool get isConfigured => _clientId != null && _clientSecret != null;
  bool get isConnected => _accessToken != null && _spreadsheetId != null;

  /// Initialize the service and load saved credentials
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _spreadsheetId = prefs.getString(_spreadsheetIdKey);
    _accessToken = await _secureStorage.read(key: _accessTokenKey);
  }

  /// Configure OAuth credentials
  Future<void> configure({
    required String clientId,
    required String clientSecret,
  }) async {
    _clientId = clientId;
    _clientSecret = clientSecret;
  }

  /// Get the authorization URL for OAuth flow
  String getAuthorizationUrl() {
    if (_clientId == null) throw Exception('Service not configured');

    final scopes = [
      'https://www.googleapis.com/auth/spreadsheets',
      'https://www.googleapis.com/auth/drive.file',
    ].join(' ');

    return Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': _clientId!,
      'redirect_uri': 'urn:ietf:wg:oauth:2.0:oob',
      'response_type': 'code',
      'scope': scopes,
      'access_type': 'offline',
    }).toString();
  }

  /// Exchange authorization code for access token
  Future<bool> exchangeCodeForToken(String code) async {
    if (_clientId == null || _clientSecret == null) {
      throw Exception('Service not configured');
    }

    try {
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        body: {
          'client_id': _clientId!,
          'client_secret': _clientSecret!,
          'code': code,
          'grant_type': 'authorization_code',
          'redirect_uri': 'urn:ietf:wg:oauth:2.0:oob',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];

        await _secureStorage.write(key: _accessTokenKey, value: _accessToken);
        if (refreshToken != null) {
          await _secureStorage.write(
              key: _refreshTokenKey, value: refreshToken);
        }

        return true;
      }
    } catch (e) {
      developer.log('Error exchanging code: $e', name: 'GoogleSheetsService');
    }
    return false;
  }

  /// Refresh access token using refresh token
  Future<bool> refreshAccessToken() async {
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    if (refreshToken == null || _clientId == null || _clientSecret == null) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        body: {
          'client_id': _clientId!,
          'client_secret': _clientSecret!,
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        await _secureStorage.write(key: _accessTokenKey, value: _accessToken);
        return true;
      }
    } catch (e) {
      developer.log('Error refreshing token: $e', name: 'GoogleSheetsService');
    }
    return false;
  }

  /// Create a new spreadsheet for transactions
  Future<String?> createSpreadsheet() async {
    if (_accessToken == null) throw Exception('Not authenticated');

    try {
      final response = await http.post(
        Uri.parse('https://sheets.googleapis.com/v4/spreadsheets'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'properties': {
            'title': 'Rupia - Keuangan Pribadi',
          },
          'sheets': [
            {
              'properties': {
                'title': 'Transaksi',
              },
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _spreadsheetId = data['spreadsheetId'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_spreadsheetIdKey, _spreadsheetId!);

        // Add headers
        await _addHeaders();

        return _spreadsheetId;
      }
    } catch (e) {
      developer.log('Error creating spreadsheet: $e', name: 'GoogleSheetsService');
    }
    return null;
  }

  /// Add headers to the spreadsheet
  Future<void> _addHeaders() async {
    if (_accessToken == null || _spreadsheetId == null) return;

    final headers = [
      'ID',
      'Tanggal',
      'Deskripsi',
      'Kategori',
      'Tipe',
      'Jumlah',
      'Mood',
      'Catatan',
      'Dibuat'
    ];

    try {
      await http.put(
        Uri.parse(
          'https://sheets.googleapis.com/v4/spreadsheets/$_spreadsheetId/values/Transaksi!A1:I1?valueInputOption=RAW',
        ),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'values': [headers],
        }),
      );
    } catch (e) {
      developer.log('Error adding headers: $e', name: 'GoogleSheetsService');
    }
  }

  /// Sync all unsynced transactions to Google Sheets
  Future<SyncResult> syncTransactions() async {
    if (_accessToken == null || _spreadsheetId == null) {
      return SyncResult(
        success: false,
        message: 'Tidak terhubung ke Google Sheets',
      );
    }

    try {
      final unsyncedTransactions =
          await _transactionRepository.getUnsyncedTransactions();

      if (unsyncedTransactions.isEmpty) {
        return SyncResult(
          success: true,
          message: 'Semua data sudah tersinkron',
          syncedCount: 0,
        );
      }

      // Convert transactions to rows
      final rows = unsyncedTransactions.map((t) => _transactionToRow(t)).toList();

      // Append to spreadsheet
      final response = await http.post(
        Uri.parse(
          'https://sheets.googleapis.com/v4/spreadsheets/$_spreadsheetId/values/Transaksi!A:I:append?valueInputOption=USER_ENTERED',
        ),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'values': rows,
        }),
      );

      if (response.statusCode == 200) {
        // Mark transactions as synced
        final ids = unsyncedTransactions.map((t) => t.id!).toList();
        await _transactionRepository.markAsSynced(ids);

        // Save last sync time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

        return SyncResult(
          success: true,
          message: 'Berhasil sync ${ids.length} transaksi',
          syncedCount: ids.length,
        );
      } else {
        // Try to refresh token and retry
        if (response.statusCode == 401) {
          final refreshed = await refreshAccessToken();
          if (refreshed) {
            return syncTransactions(); // Retry
          }
        }

        return SyncResult(
          success: false,
          message: 'Gagal sync: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Convert a transaction to a spreadsheet row
  List<dynamic> _transactionToRow(TransactionModel transaction) {
    return [
      transaction.id ?? '',
      DateFormatter.formatShort(transaction.date),
      transaction.description,
      transaction.category.displayName,
      transaction.type.name,
      transaction.amount,
      transaction.mood?.displayName ?? '',
      transaction.note ?? '',
      DateFormatter.formatFull(transaction.createdAt),
    ];
  }

  /// Get the last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString(_lastSyncKey);
    if (lastSync != null) {
      return DateTime.parse(lastSync);
    }
    return null;
  }

  /// Get spreadsheet URL
  String? getSpreadsheetUrl() {
    if (_spreadsheetId == null) return null;
    return 'https://docs.google.com/spreadsheets/d/$_spreadsheetId';
  }

  /// Disconnect from Google Sheets
  Future<void> disconnect() async {
    _accessToken = null;
    _spreadsheetId = null;

    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_spreadsheetIdKey);
    await prefs.remove(_lastSyncKey);
  }
}

/// Result of a sync operation
class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedCount = 0,
  });
}
