import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'hive_database.dart';
import '../../shared/providers/app_providers.dart';
import '../../features/tasks/domain/models/task_model.dart';
import '../../features/vision_room/domain/models/sticky_note.dart';
import '../../features/vision_room/domain/models/vision_item.dart';
import '../../features/vision_room/data/repositories/vision_room_repository.dart';
import '../../features/vision_room/data/services/vision_upload_service.dart';

class CloudSyncStatus {
  final String status; // 'synced' | 'syncing' | 'pending' | 'failed' | 'offline'
  final int pendingCount;
  final DateTime? lastSyncTime;

  CloudSyncStatus({
    required this.status,
    required this.pendingCount,
    this.lastSyncTime,
  });

  CloudSyncStatus copyWith({
    String? status,
    int? pendingCount,
    DateTime? lastSyncTime,
  }) {
    return CloudSyncStatus(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

class CloudSyncStatusNotifier extends StateNotifier<CloudSyncStatus> {
  final HiveDatabase _hiveDb;
  bool _isOnline = true;
  StreamSubscription? _connectivitySub;

  CloudSyncStatusNotifier(this._hiveDb)
      : super(CloudSyncStatus(status: 'synced', pendingCount: 0)) {
    updatePendingCount();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      _isOnline = results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
      updatePendingCount();
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  void setStatus(String status) {
    state = state.copyWith(status: status);
  }

  void updatePendingCount() {
    int count = 0;
    try {
      final tasks = _hiveDb.getTasks();
      count += tasks.where((t) => t['syncStatus'] == 'pending' || t['deleted'] == true).length;
    } catch (_) {}

    try {
      if (Hive.isBoxOpen('sticky_notes')) {
        final box = Hive.box<StickyNote>('sticky_notes');
        count += box.values.where((n) => n.pendingSync || n.deleted).length;
      }
    } catch (_) {}

    try {
      final visionItems = _hiveDb.getVisionItems();
      count += visionItems.where((v) => v['metadata']?['syncStatus'] == 'pending').length;
    } catch (_) {}

    final lastSyncStr = _hiveDb.getSettingsBox().get('last_successful_sync_time');
    final lastSync = lastSyncStr != null ? DateTime.tryParse(lastSyncStr.toString()) : null;

    String currentStatus = 'synced';
    if (!_isOnline) {
      currentStatus = 'offline';
    } else if (count > 0) {
      currentStatus = 'pending';
    }

    state = CloudSyncStatus(
      status: currentStatus,
      pendingCount: count,
      lastSyncTime: lastSync,
    );
  }
}

final cloudSyncStatusProvider = StateNotifierProvider<CloudSyncStatusNotifier, CloudSyncStatus>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  return CloudSyncStatusNotifier(hiveDb);
});

class SyncQueueService {
  final HiveDatabase _hiveDb;
  final Ref _ref;
  bool _isProcessing = false;
  Timer? _retryTimer;
  Timer? _debounceTimer;
  StreamSubscription? _connectivitySubscription;
  bool isSyncPaused = false;

  SyncQueueService(this._hiveDb, this._ref) {
    _startPeriodicTimer();
    _listenToConnectivity();
  }

  void _startPeriodicTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      triggerSync();
    });
  }

  void _listenToConnectivity() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        dev.log('[SyncQueue] Network connection restored. Auto triggering sync...');
        triggerSync();
      } else {
        _ref.read(cloudSyncStatusProvider.notifier).setStatus('offline');
      }
    });
  }

  void dispose() {
    _retryTimer?.cancel();
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
  }

  void triggerSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      processQueue();
    });
  }

  // Alias/No-op method for compatibility
  Future<void> queueAction({
    required String collection,
    required String operation,
    required String documentId,
    Map<String, dynamic>? payload,
  }) async {
    // Operations write directly to local Hive now. Just trigger bulk sync.
    triggerSync();
  }

  Future<void> processQueue() async {
    if (_isProcessing || isSyncPaused) return;

    // Refresh pending count
    _ref.read(cloudSyncStatusProvider.notifier).updatePendingCount();

    final token = _hiveDb.getAuthToken();
    if (token == null || token.trim().isEmpty) {
      dev.log('[SyncQueue] No active user session. Skipping cloud sync.');
      return;
    }

    final pendingCount = _ref.read(cloudSyncStatusProvider).pendingCount;
    if (pendingCount == 0) {
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult.isNotEmpty &&
        connectivityResult.any((r) => r != ConnectivityResult.none);
    if (!isOnline) {
      dev.log('[SyncQueue] Device is offline. Postponing sync.');
      _ref.read(cloudSyncStatusProvider.notifier).setStatus('offline');
      return;
    }

    _isProcessing = true;
    _ref.read(cloudSyncStatusProvider.notifier).setStatus('syncing');

    try {
      final dio = _ref.read(dioClientProvider);

      // 1. Gather Tasks
      final allTasks = _hiveDb.getTasks();
      final pendingTasks = allTasks
          .where((t) => t['syncStatus'] == 'pending' || t['deleted'] == true)
          .map((t) {
            final model = TaskModel.fromMap(Map<String, dynamic>.from(t));
            final map = model.toMap();
            if (t['deleted'] == true) {
              map['deleted'] = true;
            }
            return map;
          }).toList();

      // 1b. Gather Habits
      final allHabits = _hiveDb.getSelectedHabits();
      final pendingHabits = allHabits
          .where((h) => h['syncStatus'] == 'pending' || h['deleted'] == true)
          .map((h) {
            if (h['deleted'] == true) {
              return {
                'id': h['id'],
                'deleted': true,
              };
            }
            return h;
          }).toList();

      // 2. Gather Affirmations (full sync if any affirmation is pending)
      final allAffirmations = _hiveDb.getSelectedAffirmations();
      final hasPendingAffirmations = allAffirmations.any((a) => a['syncStatus'] == 'pending');
      final mappedAffs = hasPendingAffirmations
          ? allAffirmations.map((a) => {
                'id': a['id'],
                'localId': a['localId'] ?? a['id'],
                'title': a['title'] ?? 'Affirmation',
                'text': a['text'] ?? '',
                'author': a['author'] ?? 'Anonymous',
                'category': a['category'] ?? 'General',
                'emoji': a['emoji'] ?? '',
                'favorite': a['isFavorite'] ?? a['favorite'] ?? false,
                'pinned': a['isPinned'] ?? a['pinned'] ?? false,
                'theme': a['colorTheme'] ?? a['theme'] ?? 'Warm Amber',
                'createdAt': a['createdAt']?.toString(),
                'updatedAt': a['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
              }).toList()
          : null;

      // 3. Gather Sticky Notes
      List<Map<String, dynamic>> mappedStickyNotes = [];
      List<StickyNote> pendingStickyNotesObjs = [];
      if (Hive.isBoxOpen('sticky_notes')) {
        final stickyBox = Hive.box<StickyNote>('sticky_notes');
        pendingStickyNotesObjs = stickyBox.values.where((n) => n.pendingSync || n.deleted).toList();
        mappedStickyNotes = pendingStickyNotesObjs.map((n) {
          final json = n.toJson();
          if (n.deleted) {
            json['deleted'] = true;
          }
          return json;
        }).toList();
      }

      // 4. Gather Vision Room Items (canvas items)
      final allVisionItems = _hiveDb.getVisionItems();
      final hasPendingVision = allVisionItems.any((v) => v['metadata']?['syncStatus'] == 'pending');
      List<Map<String, dynamic>>? mappedVisionItems;
      if (hasPendingVision) {
        final repo = _ref.read(visionRoomRepositoryProvider);
        final uploadService = VisionUploadService(dio: dio.dio);
        final List<Map<String, dynamic>> itemsList = [];
        for (var v in allVisionItems) {
          final item = VisionItem.fromJson(Map<String, dynamic>.from(v));
          if (item.type == 'image' && 
              item.content.isNotEmpty && 
              !item.content.startsWith('http://') && 
              !item.content.startsWith('https://')) {
            try {
              dev.log('[SyncQueue] Uploading local vision item image: ${item.content}');
              final remoteUrl = await uploadService.uploadImage(item.content);
              if (remoteUrl != null) {
                final updatedItem = item.copyWith(content: remoteUrl);
                
                // Save updated remote url to local Hive
                final allLocalItems = _hiveDb.getVisionItems();
                final updatedLocal = allLocalItems.map((localV) {
                  if (localV['id'] == item.id) {
                    localV['content'] = remoteUrl;
                    if (localV['metadata'] != null) {
                      localV['metadata']['syncStatus'] = 'synced';
                    }
                  }
                  return localV;
                }).toList();
                await _hiveDb.saveVisionItems(updatedLocal);

                itemsList.add(repo.mapItemToDbKeys(updatedItem));
                continue;
              }
            } catch (e) {
              dev.log('[SyncQueue] Failed to upload local image ${item.content}: $e');
            }
          }
          itemsList.add(repo.mapItemToDbKeys(item));
        }
        mappedVisionItems = itemsList;
      }

      // 5. Gather Settings & Preferences
      final identity = _hiveDb.getSelectedIdentity() ?? '🚀 Entrepreneur';
      final lifeAreas = _hiveDb.getSelectedLifeAreas();
      final workspaceSettings = _hiveDb.getWorkspaceSettings();
      final readingPrefs = _hiveDb.getReadingPreferences();
      final healthPrefs = _hiveDb.getHealthPreferences();
      final financePrefs = _hiveDb.getFinancePreferences();

      final payload = {
        'profile': {
          'identity': identity,
          'lifeAreas': lifeAreas,
          'workspaceTheme': workspaceSettings?['theme'] ?? 'default',
          'customTaskCategories': _hiveDb.getCustomCategories(),
        },
        'workspaceSettings': workspaceSettings,
        'reading': {
          'dailyTargetPages': readingPrefs?['dailyReadingMinutes'] ?? 20,
          'goalBooks': readingPrefs?['bookTarget'] ?? 12,
        },
        'finance': {
          'targetAmount': financePrefs?['monthlySavings'] ?? 10000,
          'monthlySavingsTarget': financePrefs?['monthlySavings'] ?? 10000,
        },
        'health': {
          'waterGoal': healthPrefs?['waterTarget'] ?? 2000,
          'sleepGoal': healthPrefs?['sleepTarget'] ?? 8,
          'exerciseGoal': healthPrefs?['exerciseTarget'] ?? 30,
        },
        if (pendingTasks.isNotEmpty) 'tasks': pendingTasks,
        if (pendingHabits.isNotEmpty) 'habits': pendingHabits,
        if (mappedStickyNotes.isNotEmpty) 'stickyNotes': mappedStickyNotes,
        if (mappedAffs != null) 'affirmations': mappedAffs,
        if (mappedVisionItems != null) 'visionRoom': {
          'items': mappedVisionItems,
        },
      };

      final hasPendingTasks = pendingTasks.isNotEmpty;
      final hasPendingHabits = pendingHabits.isNotEmpty;

      // Log what we are syncing
      print('[SyncQueue] Bulk syncing: '
          'tasks/goals: ${pendingTasks.length}, '
          'habits: ${pendingHabits.length}, '
          'affirmations: ${mappedAffs?.length ?? 0}, '
          'visionItems: ${mappedVisionItems?.length ?? 0}');

      final response = await dio.post('/focus/sync', data: payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[SyncQueue] Bulk sync succeeded!');

        // Update Tasks in Hive
        if (hasPendingTasks) {
          final updatedTasks = allTasks
              .where((t) => t['deleted'] != true)
              .map((t) {
                if (t['syncStatus'] == 'pending') {
                  t['syncStatus'] = 'synced';
                }
                return t;
              }).toList();
          await _hiveDb.saveTasks(updatedTasks);
        }

        // Update Habits in Hive
        if (hasPendingHabits) {
          final updatedHabits = allHabits
              .where((h) => h['deleted'] != true)
              .map((h) {
                if (h['syncStatus'] == 'pending') {
                  h['syncStatus'] = 'synced';
                }
                return h;
              }).toList();
          await _hiveDb.saveSelectedHabits(updatedHabits);
        }

        // Update Sticky Notes in Hive
        if (pendingStickyNotesObjs.isNotEmpty) {
          final stickyBox = Hive.box<StickyNote>('sticky_notes');
          for (var note in pendingStickyNotesObjs) {
            if (note.deleted) {
              await stickyBox.delete(note.id);
            } else {
              final updatedNote = note.copyWith(
                pendingSync: false,
              );
              await stickyBox.put(note.id, updatedNote);
            }
          }
        }

        // Update Affirmations in Hive
        if (hasPendingAffirmations) {
          final updatedAffs = allAffirmations.map((a) {
            if (a['syncStatus'] == 'pending') {
              a['syncStatus'] = 'synced';
            }
            return a;
          }).toList();
          await _hiveDb.saveSelectedAffirmations(updatedAffs);
        }

        // Update Vision Items on Canvas in Hive
        if (hasPendingVision) {
          final updatedVision = allVisionItems.map((v) {
            if (v['metadata']?['syncStatus'] == 'pending') {
              v['metadata'] = Map<String, dynamic>.from(v['metadata'] as Map);
              v['metadata']['syncStatus'] = 'synced';
              v['metadata']['lastSyncedAt'] = DateTime.now().toIso8601String();
            }
            return v;
          }).toList();
          await _hiveDb.saveVisionItems(updatedVision);
        }

        // Save last sync timestamp
        final nowStr = DateTime.now().toIso8601String();
        await _hiveDb.getSettingsBox().put('last_successful_sync_time', nowStr);

        _ref.read(cloudSyncStatusProvider.notifier).updatePendingCount();
        _ref.read(cloudSyncStatusProvider.notifier).setStatus('synced');
      } else {
        print('[SyncQueue] Bulk sync returned status code: ${response.statusCode} - Data: ${response.data}');
        dev.log('[SyncQueue] Bulk sync returned status code: ${response.statusCode} - Data: ${response.data}');
        _ref.read(cloudSyncStatusProvider.notifier).setStatus('failed');
      }
    } catch (e, stack) {
      print('[SyncQueue] Error bulk syncing: $e');
      bool isConnectionError = false;
      if (e is DioException) {
        print('[SyncQueue] DioException detail: ${e.response?.statusCode} - ${e.response?.data}');
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.error.toString().contains('SocketException')) {
          isConnectionError = true;
        }
      } else if (e.toString().contains('SocketException')) {
        isConnectionError = true;
      }
      dev.log('[SyncQueue] Error bulk syncing: $e', error: e, stackTrace: stack);
      
      if (isConnectionError) {
        _ref.read(cloudSyncStatusProvider.notifier).setStatus('offline');
      } else {
        _ref.read(cloudSyncStatusProvider.notifier).setStatus('failed');
      }
    } finally {
      _isProcessing = false;
    }
  }
}

typedef SyncManager = SyncQueueService;

final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  return SyncQueueService(hiveDb, ref);
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  return ref.watch(syncQueueServiceProvider);
});
