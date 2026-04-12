import 'dart:async';
import 'package:dio/dio.dart';
import 'database_service.dart';
import '../config/environment.dart';

class SyncService {
  final DatabaseService _database;
  final Dio _dio;
  bool _isSyncing = false;
  Timer? _syncTimer;

  SyncService(this._database) : _dio = Dio() {
    _dio.options.baseUrl = Environment.apiUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  void startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(AppConfig.syncInterval, (_) => sync());
  }

  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<SyncResult> sync() async {
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    if (Environment.tenantId.isEmpty) {
      return SyncResult(success: false, message: 'Tenant not configured');
    }

    _isSyncing = true;
    final startTime = DateTime.now();
    final result = SyncResult();

    try {
      await _pushChanges();
      await _pullChanges();
      
      result.success = true;
      result.duration = DateTime.now().difference(startTime);
    } catch (e) {
      result.success = false;
      result.error = e.toString();
    } finally {
      _isSyncing = false;
    }

    return result;
  }

  Future<void> _pushChanges() async {
    final pendingItems = await _database.getPendingSyncItems(limit: 100);

    if (pendingItems.isEmpty) return;

    final changes = pendingItems.map((item) => {
      'entity': item.entityType,
      'localId': item.entityId,
      'action': item.action,
      'data': item.data,
    }).toList();

    try {
      final response = await _dio.post(
        '/sync/push',
        data: {'changes': changes},
        options: Options(
          headers: Environment.defaultHeaders,
        ),
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as Map<String, dynamic>;
        
        for (final item in pendingItems) {
          if (results[item.entityType]?['errors']?.isEmpty ?? true) {
            await _database.removeSyncQueueItem(item.id);
          } else {
            await _database.incrementSyncRetry(item.id, 'Server returned errors');
          }
        }
      }
    } on DioException catch (e) {
      for (final item in pendingItems) {
        await _database.incrementSyncRetry(item.id, e.message ?? 'Network error');
      }
      rethrow;
    }
  }

  Future<void> _pullChanges() async {
    try {
      final response = await _dio.get(
        '/sync/pull',
        queryParameters: {'entityTypes': 'patient,encounter,billing,inventory,user'},
        options: Options(
          headers: Environment.defaultHeaders,
        ),
      );

      if (response.statusCode == 200) {
        final entities = response.data['entities'] as Map<String, dynamic>;

        if (entities['patients'] != null) {
          for (final patient in entities['patients']) {
            await _database.savePatient(patient);
          }
        }

        if (entities['encounters'] != null) {
          for (final encounter in entities['encounters']) {
            await _database.saveEncounter(encounter);
          }
        }

        if (entities['inventory'] != null) {
          for (final item in entities['inventory']) {
            await _database.saveInventoryItem(item);
          }
        }
      }
    } on DioException catch (e) {
      if (e.type != DioExceptionType.connectionTimeout &&
          e.type != DioExceptionType.receiveTimeout) {
        rethrow;
      }
    }
  }

  Future<SyncStatus> getStatus() async {
    final stats = await _database.getSyncStats();
    return SyncStatus(
      isSyncing: _isSyncing,
      pendingChanges: stats['total'] ?? 0,
      lastSyncAt: DateTime.now(),
    );
  }
}

class SyncResult {
  bool success;
  String? message;
  String? error;
  Duration? duration;

  SyncResult({
    this.success = false,
    this.message,
    this.error,
    this.duration,
  });
}

class SyncStatus {
  final bool isSyncing;
  final int pendingChanges;
  final DateTime lastSyncAt;

  SyncStatus({
    required this.isSyncing,
    required this.pendingChanges,
    required this.lastSyncAt,
  });
}

final syncServiceProvider = SyncService;
