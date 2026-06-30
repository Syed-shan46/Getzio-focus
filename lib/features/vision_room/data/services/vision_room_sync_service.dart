import 'dart:async';
import 'package:dio/dio.dart';
import '../../domain/models/vision_item.dart';
import '../../../../config/env.dart';

/// Production-Grade Backend & Sync Service for Vision Room Smart Objects.
/// Architecture: UI -> Riverpod -> Repository -> Hive -> REST API -> MongoDB
class VisionRoomSyncService {
  final Dio _dio;
  final List<Map<String, dynamic>> _offlineSyncQueue = [];
  bool _isSyncing = false;

  VisionRoomSyncService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: EnvConfig.baseUrl.endsWith('/') ? '${EnvConfig.baseUrl}focus/vision-room' : '${EnvConfig.baseUrl}/focus/vision-room',
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ));

  /// Background non-blocking sync call to MongoDB backend.
  Future<void> syncObjectToBackend(VisionItem item) async {
    final payload = item.toJson();
    try {
      await _dio.patch('/objects/${item.id}', data: payload);
      _processOfflineQueue();
    } catch (e) {
      // Offline or network error: push to offline queue and retry automatically
      _offlineSyncQueue.add(payload);
    }
  }

  /// Delete object on MongoDB backend.
  Future<void> deleteObjectFromBackend(String id) async {
    try {
      await _dio.delete('/objects/$id');
    } catch (e) {
      _offlineSyncQueue.add({'action': 'DELETE', 'id': id});
    }
  }

  /// Process queued offline updates when network restores.
  Future<void> _processOfflineQueue() async {
    if (_isSyncing || _offlineSyncQueue.isEmpty) return;
    _isSyncing = true;
    final pending = List<Map<String, dynamic>>.from(_offlineSyncQueue);
    _offlineSyncQueue.clear();

    for (final payload in pending) {
      try {
        if (payload['action'] == 'DELETE') {
          await _dio.delete('/objects/${payload['id']}');
        } else {
          await _dio.patch('/objects/${payload['id']}', data: payload);
        }
      } catch (_) {
        _offlineSyncQueue.add(payload);
      }
    }
    _isSyncing = false;
  }
}
