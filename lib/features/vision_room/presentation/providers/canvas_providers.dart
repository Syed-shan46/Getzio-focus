import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/models/canvas_state.dart';
import '../../domain/models/vision_item.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/models/auth_user_model.dart';
import '../../data/repositories/vision_room_repository.dart';
import '../../../../core/storage/sync_manager.dart';

class CanvasHistoryNotifier extends StateNotifier<CanvasState> {
  final HiveDatabase _hiveDb;
  final Ref _ref;
  final List<CanvasState> _undoStack = [];
  final List<CanvasState> _redoStack = [];
  final Map<String, Timer> _itemDebouncers = {};
  Timer? _viewportDebouncer;
  bool _initialized = false;

  CanvasHistoryNotifier(this._hiveDb, this._ref)
    : super(CanvasState(items: [])) {
    // FIRST: Immediately set defaults for guest users before any async ops.
    // This runs synchronously and guarantees the vision room is never empty.
    final token = _hiveDb.getAuthToken();
    final isGuest = token == null || token.trim().isEmpty;
    if (isGuest) {
      state = state.copyWith(
        items: _getGuestDefaults(),
      );
    }

    // THEN: schedule async loading (for logged-in users from backend)
    Future.microtask(() => _initAsync());
  }

  static List<VisionItem> _getGuestDefaults() {
    return [
      VisionItem(
        id: "14393812-96a0-467f-ac72-715425daa015",
        type: "quote",
        content: "Dream boldly, act consistently, and let your progress tell the story",
        x: 15.125,
        y: 444.458,
        width: 105.12,
        height: 60.07,
        rotation: -0.01638,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 19,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-05T18:12:25.751856",
          "scale": 1.0,
          "opacity": 1.0,
          "quote": "Dream boldly, act consistently, and let your progress tell the story",
          "author": "Getzio",
          "style": "Dark Luxury",
        },
      ),
      VisionItem(
        id: "3459e2dc-41c2-46c8-b612-cf6d803e27e8",
        type: "task",
        content: "Plan My Next Adventure",
        x: 211.667,
        y: 661.375,
        width: 72.12,
        height: 93.758,
        rotation: 0.0136,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 21,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-05T18:12:25.751918",
          "scale": 1.0,
          "opacity": 1.0,
          "title": "Plan My Next Adventure",
          "priority": "Medium",
          "progress": 10.0,
          "dueDate": "2026-07-31T00:00:00.000",
          "checklist": [
            {"id": "1783252653138_0", "title": "Choose destination", "isCompleted": false},
            {"id": "1783252653138_1", "title": "Estimate budget", "isCompleted": false},
            {"id": "1783252653138_2", "title": "Create countdown", "isCompleted": false},
            {"id": "1783252653138_3", "title": "Save inspiration photos", "isCompleted": false}
          ],
        },
      ),
      VisionItem(
        id: "55dbfe5e-b561-4699-bce0-daed4c52dfd5",
        type: "goal",
        content: "Turn Dreams Into Goals",
        x: 120.833,
        y: 45.062,
        width: 155.727,
        height: 103.818,
        rotation: -6.297,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 7,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-04T15:50:01.643429",
          "scale": 1.0,
          "opacity": 1.0,
          "title": "Turn Dreams Into Goals",
          "description": "Create meaningful goals with milestones, priorities, due dates, and visual progress—all in one inspiring workspace.",
          "progress": 40.0,
          "dueDate": "2026-07-31T00:00:00.000",
          "priority": "High",
          "color": 4285132974,
        },
      ),
      VisionItem(
        id: "55f235b3-23e8-4af1-87ac-16273e5650b5",
        type: "image",
        content: "https://res.cloudinary.com/dkiizrpqr/image/upload/v1783158787/focus_vision_board/dnxjsudr1pzfjpnhhz9j.jpg",
        x: 8.354,
        y: 334.718,
        width: 100.18,
        height: 100.18,
        rotation: -0.0102,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 1,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-04T15:50:01.643249",
          "scale": 1.0,
          "opacity": 1.0,
          "progress": 52.0,
          "caption": "Dream House",
          "emoji": "heart",
        },
      ),
      VisionItem(
        id: "632d6e85-e82e-48f4-9701-ad6fdfaa1d02",
        type: "quote",
        content: "Every completed task is another promise you've kept to yourself.\"",
        x: 126.25,
        y: 569.062,
        width: 129.39,
        height: 73.937,
        rotation: -0.0068,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 20,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-05T18:12:25.751886",
          "scale": 1.0,
          "opacity": 1.0,
          "quote": "Every completed task is another promise you've kept to yourself.\"",
          "author": "Getzio",
          "style": "Neon",
        },
      ),
      VisionItem(
        id: "8338a5e3-6999-4b2c-98bd-43d9b358b479",
        type: "task",
        content: "Build My Vision Room",
        x: 17.416,
        y: 41.458,
        width: 83.60,
        height: 108.68,
        rotation: -0.0271,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 17,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-05T18:12:25.751745",
          "scale": 1.0,
          "opacity": 1.0,
          "title": "Build My Vision Room",
          "priority": "Medium",
          "progress": 40.0,
          "checklist": [
            {"id": "1783250139636_0", "title": "Add dream house", "isCompleted": false},
            {"id": "1783250139636_1", "title": "Pin dream car", "isCompleted": false},
            {"id": "1783250139636_2", "title": "Add travel destination", "isCompleted": false},
            {"id": "1783250139636_3", "title": "Create motivational quote", "isCompleted": false},
            {"id": "1783250139636_4", "title": "Arrange board layout", "isCompleted": false}
          ],
        },
      ),
      VisionItem(
        id: "8aff44e5-37b7-443d-9127-b64f6c6a8be2",
        type: "quote",
        content: "Thank you for not giving up on the days when progress was invisible. That's why I'm here",
        x: 224.625,
        y: 161.322,
        width: 135.78,
        height: 83.60,
        rotation: -0.0296,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 6,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-04T15:50:01.643373",
          "scale": 1.0,
          "opacity": 1.0,
          "quote": "Thank you for not giving up on the days when progress was invisible. That's why I'm here",
          "author": "Future you",
          "style": "Typewriter",
        },
      ),
      VisionItem(
        id: "8d645e44-03bb-414d-a11a-a91681ed12a8",
        type: "image",
        content: "https://res.cloudinary.com/dkiizrpqr/image/upload/v1783254589/focus_vision_board/o7mimjbhpfjeaahvo1vy.jpg",
        x: 260.916,
        y: 510.25,
        width: 93.13,
        height: 93.13,
        rotation: -0.0099,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 24,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-05T18:12:25.752084",
          "scale": 1.0,
          "opacity": 1.0,
          "progress": 38.0,
          "caption": "Keep growing",
          "emoji": "heart",
        },
      ),
      VisionItem(
        id: "8f3aa04a-225a-4817-ba66-080e8414a078",
        type: "countdown",
        content: "🏠 Move Into My Dream Home",
        x: 5.375,
        y: 339.29,
        width: 50.0,
        height: 50.0,
        rotation: 6.2098,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 11,
        countdownDate: DateTime(2027, 8, 3),
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-04T16:54:18.608130",
          "scale": 1.0,
          "opacity": 1.0,
          "title": "🏠 Move Into My Dream Home",
          "days": 395,
          "targetDate": "2027-08-03T00:00:00.000",
        },
      ),
      VisionItem(
        id: "989225ce-2374-4387-b79e-4c0ea1d0b1b0",
        type: "image",
        content: "https://res.cloudinary.com/dkiizrpqr/image/upload/v1783247472/focus_vision_board/xofnow3a6mwep0wsuzcw.jpg",
        x: 125.354,
        y: 163.395,
        width: 88.38,
        height: 88.38,
        rotation: -0.0276,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 13,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-05T16:04:17.665222",
          "scale": 1.0,
          "opacity": 1.0,
          "progress": 30.0,
          "caption": "Drive your dream",
          "emoji": "heart",
        },
      ),
      VisionItem(
        id: "9f146ed7-c2a2-4409-9d78-c2f2d50cdfe0",
        type: "image",
        content: "https://res.cloudinary.com/dkiizrpqr/image/upload/v1783249606/focus_vision_board/eb8u4ojzyctsht4mbphw.jpg",
        x: 19.791,
        y: 238.531,
        width: 86.84,
        height: 86.84,
        rotation: -0.0258,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 15,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-05T18:12:25.751656",
          "scale": 1.0,
          "opacity": 1.0,
          "progress": 18.0,
          "caption": "Explore the word",
          "emoji": "globe",
        },
      ),
      VisionItem(
        id: "ae7eb588-3ba3-42cf-a327-49a50884cd42",
        type: "quote",
        content: "Create beautiful quote cards with your favorite words, personal reflections, and memorable authors to inspire you every day.",
        x: 8.541,
        y: 166.0,
        width: 105.41,
        height: 60.23,
        rotation: -0.0109,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 2,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-04T15:50:01.643334",
          "scale": 1.0,
          "opacity": 1.0,
          "quote": "Create beautiful quote cards with your favorite words, personal reflections, and memorable authors to inspire you every day.",
          "author": "Getzio",
          "style": "Elegant Minimal",
        },
      ),
      VisionItem(
        id: "af2c4b64-e7ca-4c76-8f83-2dd62324d903",
        type: "image",
        content: "https://res.cloudinary.com/dkiizrpqr/image/upload/v1783254490/focus_vision_board/nvlq148mgecnafwhfjzm.jpg",
        x: 125.354,
        y: 358.343,
        width: 137.65,
        height: 137.65,
        rotation: -0.0074,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 22,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-05T18:12:25.751961",
          "scale": 1.0,
          "opacity": 1.0,
          "progress": 26.0,
          "caption": "Adventures await",
          "emoji": "globe",
        },
      ),
      VisionItem(
        id: "c3bdc2cd-a083-4991-8c06-135fd2706855",
        type: "financeGoal",
        content: "Buy BMW S1000RR",
        x: 116.041,
        y: 261.26,
        width: 153.25,
        height: 87.57,
        rotation: -0.0112,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 16,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-05T18:12:25.751707",
          "scale": 1.0,
          "opacity": 1.0,
          "title": "Buy BMW S1000RR",
          "amount": "2850000",
          "targetAmount": 2850000.0,
          "currentAmount": 712500.0,
          "progress": 25.0,
          "description": "Every small investment today brings me closer to my dream ride",
          "motivation": "Owning the BMW S1000RR is a reward for my years of hard work and consistency. Every rupee I save reminds me that big dreams are achieved through disciplined daily actions.",
          "monthlyAmount": "50,000",
          "targetDate": "2027-12-31T00:00:00.000",
        },
      ),
      VisionItem(
        id: "c479449a-befe-4dc3-9274-55a6b69e6a55",
        type: "quote",
        content: "Your future is quietly built by the choices you make today.",
        x: 137.437,
        y: 503.645,
        width: 92.15,
        height: 52.66,
        rotation: -0.0075,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 18,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-05T18:12:25.751820",
          "scale": 1.0,
          "opacity": 1.0,
          "quote": "Your future is quietly built by the choices you make today.",
          "author": "Future you",
          "style": "Elegant Minimal",
        },
      ),
      VisionItem(
        id: "c7c65057-a887-41af-b486-13265e270303",
        type: "countdown",
        content: "But A new Car",
        x: 212.083,
        y: 56.958,
        width: 50.0,
        height: 50.0,
        rotation: -0.0232,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 14,
        countdownDate: DateTime(2027, 4, 1),
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-05T16:04:17.665276",
          "scale": 1.0,
          "opacity": 1.0,
          "title": "But A new Car",
          "days": 270,
          "targetDate": "2027-04-01T00:00:00.000",
        },
      ),
      VisionItem(
        id: "c8bef7fa-163b-47eb-80e7-9fceeb4a6a82",
        type: "image",
        content: "https://res.cloudinary.com/dkiizrpqr/image/upload/v1783254559/focus_vision_board/c87cunuitcrtqn7ifwmi.jpg",
        x: 80.687,
        y: 661.229,
        width: 101.77,
        height: 101.77,
        rotation: -0.0748,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 23,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-05T18:12:25.751991",
          "scale": 1.0,
          "opacity": 1.0,
          "progress": 24.0,
          "caption": "plan, Focus, Succeed",
          "emoji": "camera",
        },
      ),
      VisionItem(
        id: "f758e47b-6c8d-44a7-8fa0-d7645e00ea78",
        type: "task",
        content: "Get Fit",
        x: 272.937,
        y: 334.666,
        width: 70.12,
        height: 91.16,
        rotation: -0.0176,
        colorValue: 4280163147,
        isPinned: false,
        zIndex: 8,
        attachmentType: "tape",
        attachmentStyle: "beige",
        materialStyle: "default",
        metadata: const {
          "isOnShelf": false,
          "createdAt": "2026-07-04T15:50:01.643481",
          "scale": 1.0,
          "opacity": 1.0,
          "title": "Get Fit",
          "priority": "High",
          "progress": 38.0,
          "checklist": [
            {"id": "1783159822515_0", "title": "✓ Morning Workout", "isCompleted": true},
            {"id": "1783159822515_1", "title": "⏳ Healthy Meal Plan", "isCompleted": true},
            {"id": "1783159822515_2", "title": "☐ Track Weekly Progress", "isCompleted": false}
          ],
        },
      ),
    ];
  }

  Future<void> _initAsync() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Load from local Hive first
      final repo = _ref.read(visionRoomRepositoryProvider);
      List<VisionItem> items = [];
      try {
        items = repo.getLocalVisionItems();
      } catch (_) {}

      final token = _hiveDb.getAuthToken();
      final isGuest = token == null || token.trim().isEmpty;
      debugPrint('[CanvasSync] _initAsync: isGuest = $isGuest, token = "$token", local cached items count = ${items.length}');

      if (!isGuest) {
        // Double safety: if user is logged in, but cache still has guest items, clear them!
        final hasGuestItems = items.any((i) => i.id.startsWith('guest_') || i.id == '14393812-96a0-467f-ac72-715425daa015');
        if (hasGuestItems) {
          debugPrint('[CanvasSync] _initAsync: clearing guest items on successful login');
          await repo.saveLocalVisionItems([]);
          items = [];
          state = state.copyWith(items: []);
        }
      }

      if (isGuest) {
        // For guest users: if Hive has items (from seed or previous session) and has all 18 guest defaults, use those.
        // Otherwise, reload/reset to our 18 beautiful default cards.
        final hasNewDefaults = items.length >= 18 &&
            items.any((i) => i.id == '14393812-96a0-467f-ac72-715425daa015');
        debugPrint('[CanvasSync] _initAsync: guest path, hasNewDefaults = $hasNewDefaults');
        if (items.isNotEmpty && hasNewDefaults) {
          state = state.copyWith(items: items);
        } else {
          debugPrint('[CanvasSync] _initAsync: resetting to defaults list');
          final defaults = _getGuestDefaults();
          repo.saveLocalVisionItems(defaults);
          state = state.copyWith(items: defaults);
        }
      } else {
        // For logged-in users: load from Hive and/or fetch from server
        if (items.isNotEmpty) {
          state = state.copyWith(items: items);
        }

        try {
          final remoteItems = await repo.fetchVisionRoomFromServer();
          if (remoteItems != null && remoteItems.isNotEmpty) {
            final localJson = jsonEncode(
              state.items.map((i) => i.toJson()).toList(),
            );
            final remoteJson = jsonEncode(
              remoteItems.map((i) => i.toJson()).toList(),
            );
            if (localJson != remoteJson) {
              await repo.saveLocalVisionItems(remoteItems);
              state = state.copyWith(items: remoteItems);
            }
          }
        } catch (_) {}

        _ref.read(syncManagerProvider).processQueue();
      }

      // Restore viewport if exists
      final cachedViewport = _hiveDb.getVisionViewport();
      if (cachedViewport != null) {
        state = state.copyWith(
          viewportTransform: Matrix4.fromList(cachedViewport),
        );
      }
    } catch (e) {
      debugPrint('[CanvasSync] _initAsync error: $e');
    }
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void _saveState() {
    final repo = _ref.read(visionRoomRepositoryProvider);
    repo.saveLocalVisionItems(state.items);
    if (state.viewportTransform != null) {
      _hiveDb.saveVisionViewport(state.viewportTransform!.storage.toList());
    }
  }

  Future<void> saveRoomToServer() async {
    final hasToken = _hiveDb.getAuthToken() != null;
    if (!hasToken) return;

    try {
      final dio = _ref.read(dioClientProvider);
      final repo = _ref.read(visionRoomRepositoryProvider);
      final serializedItems = state.items
          .map((i) => repo.mapItemToDbKeys(i))
          .toList();
      await dio.post(
        '/focus/vision-room',
        data: {
          'items': serializedItems,
          'viewport': state.viewportTransform?.storage.toList(),
        },
      );
      debugPrint('[CanvasSync] Saved entire room to server successfully');
    } catch (e) {
      debugPrint('[CanvasSync] Error saving entire room: $e');
      rethrow;
    }
  }

  void _debouncePatchItem(String id) {
    final hasToken = _hiveDb.getAuthToken() != null;
    if (!hasToken) return;

    _itemDebouncers[id]?.cancel();
    _itemDebouncers[id] = Timer(const Duration(milliseconds: 350), () {
      try {
        final itemIndex = state.items.indexWhere((i) => i.id == id);
        if (itemIndex == -1) return;
        final item = state.items[itemIndex];
        final repo = _ref.read(visionRoomRepositoryProvider);
        final data = repo.mapItemToDbKeys(item);
        final dio = _ref.read(dioClientProvider);
        dio
            .patch('/focus/vision-room/item/$id', data: data)
            .then((_) {
              debugPrint('[CanvasSync] Patched item $id successfully');
            })
            .catchError((e) async {
              debugPrint(
                '[CanvasSync] Failed to patch item $id, queuing sync: $e',
              );
              await repo.queueItemUpsert(item, 'update');
            });
      } catch (e) {
        debugPrint('[CanvasSync] Exception patching item $id: $e');
      }
    });
  }

  void commitState(CanvasState newState) {
    if (state != newState) {
      _undoStack.add(state);
      _redoStack.clear();
      state = newState;
      _saveState();
    }
  }

  void undo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(state);
      state = _undoStack.removeLast();
      _saveState();
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(state);
      state = _redoStack.removeLast();
      _saveState();
    }
  }

  void addItem(VisionItem item) {
    int maxZ = 0;
    for (var i in state.items) {
      if (i.zIndex > maxZ) maxZ = i.zIndex;
    }
    final newItem = item.copyWith(zIndex: maxZ + 1);

    final newItems = List<VisionItem>.from(state.items)..add(newItem);
    newItems.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    commitState(state.copyWith(items: newItems));

    final hasToken = _hiveDb.getAuthToken() != null;
    if (hasToken) {
      try {
        final repo = _ref.read(visionRoomRepositoryProvider);
        final dio = _ref.read(dioClientProvider);
        final payload = repo.mapItemToDbKeys(newItem);
        final createdAt = DateTime.now().toIso8601String();
        payload['metadata'] = {...?(newItem.metadata), 'createdAt': createdAt};
        payload['countdownDate'] = newItem.countdownDate?.toIso8601String();
        dio
            .post('/focus/vision-room/item', data: payload)
            .then((_) {
              debugPrint('[CanvasSync] Created item ${newItem.id} on backend');
            })
            .catchError((e) async {
              debugPrint(
                '[CanvasSync] Failed to create item ${newItem.id}, queuing sync: $e',
              );
              await repo.queueItemUpsert(newItem, 'create');
            });
      } catch (e) {
        debugPrint('[CanvasSync] Exception creating item: $e');
      }
    }
  }

  void bringToFront(String id) {
    int maxZ = 0;
    for (var i in state.items) {
      if (i.zIndex > maxZ) maxZ = i.zIndex;
    }

    final newItems = state.items.map((item) {
      if (item.id == id) {
        final updated = item.copyWith(zIndex: maxZ + 1);
        _debouncePatchItem(id);
        return updated;
      }
      return item;
    }).toList();

    newItems.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    commitState(state.copyWith(items: newItems));
  }

  void sendToBack(String id) {
    int minZ = 0;
    for (var i in state.items) {
      if (i.zIndex < minZ) minZ = i.zIndex;
    }

    final newItems = state.items.map((item) {
      if (item.id == id) {
        final updated = item.copyWith(zIndex: minZ - 1);
        _debouncePatchItem(id);
        return updated;
      }
      return item;
    }).toList();

    newItems.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    commitState(state.copyWith(items: newItems));
  }

  void updatePosition(String id, double dx, double dy) {
    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        final updated = item.copyWith(x: item.x + dx, y: item.y + dy);
        return updated;
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedItems);
  }

  void updateSize(
    String id,
    double width,
    double height, {
    double? dx,
    double? dy,
  }) {
    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        final updated = item.copyWith(
          width: width.clamp(50.0, 2000.0),
          height: height.clamp(50.0, 2000.0),
          x: item.x + (dx ?? 0),
          y: item.y + (dy ?? 0),
        );
        return updated;
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedItems);
  }

  void updateContent(String id, String newContent) {
    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        final updated = item.copyWith(content: newContent);
        _debouncePatchItem(id);
        return updated;
      }
      return item;
    }).toList();
    commitState(state.copyWith(items: updatedItems));
  }

  void updateItemDetails(
    String id, {
    String? content,
    String? secondaryContent,
    int? colorValue,
    Map<String, dynamic>? metadata,
  }) {
    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        final newMetadata = metadata != null
            ? {...?item.metadata, ...metadata}
            : item.metadata;
        
        DateTime? newCountdownDate = item.countdownDate;
        if (newMetadata != null && newMetadata.containsKey('targetDate')) {
          final targetStr = newMetadata['targetDate'] as String?;
          newCountdownDate = targetStr != null ? DateTime.tryParse(targetStr) : null;
        }

        final updated = item.copyWith(
          content: content ?? item.content,
          secondaryContent: secondaryContent ?? item.secondaryContent,
          colorValue: colorValue ?? item.colorValue,
          metadata: newMetadata,
          countdownDate: newCountdownDate,
        );
        _debouncePatchItem(id);
        return updated;
      }
      return item;
    }).toList();
    commitState(state.copyWith(items: updatedItems));
  }

  void duplicateItem(String id) {
    final itemIndex = state.items.indexWhere((i) => i.id == id);
    if (itemIndex == -1) return;
    final original = state.items[itemIndex];
    final newItem = original.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      x: original.x + 30,
      y: original.y + 30,
      zIndex: original.zIndex + 1,
    );
    addItem(newItem);
  }

  void updateAttachment(String id, String type, String style) {
    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        final updated = item.copyWith(
          attachmentType: type,
          attachmentStyle: style,
        );
        _debouncePatchItem(id);
        return updated;
      }
      return item;
    }).toList();
    commitState(state.copyWith(items: updatedItems));
  }

  void commitTransform(
    String id,
    double newWidth,
    double newHeight,
    double newRotation, {
    bool isFinal = false,
  }) {
    final newItems = state.items.map((item) {
      if (item.id == id) {
        final updated = item.copyWith(
          width: newWidth.clamp(50.0, 2000.0),
          height: newHeight.clamp(50.0, 2000.0),
          rotation: newRotation,
        );
        if (isFinal) {
          _debouncePatchItem(id);
        }
        return updated;
      }
      return item;
    }).toList();
    commitState(state.copyWith(items: newItems));
  }

  void updateTransform(
    String id,
    double newWidth,
    double newHeight,
    double newRotation,
  ) {
    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        return item.copyWith(
          width: newWidth.clamp(50.0, 2000.0),
          height: newHeight.clamp(50.0, 2000.0),
          rotation: newRotation,
        );
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedItems);
  }

  void removeItem(String id) {
    commitState(
      state.copyWith(
        items: state.items.where((item) => item.id != id).toList(),
      ),
    );

    final hasToken = _hiveDb.getAuthToken() != null;
    if (hasToken) {
      try {
        final repo = _ref.read(visionRoomRepositoryProvider);
        final dio = _ref.read(dioClientProvider);
        dio
            .delete('/focus/vision-room/item/$id')
            .then((_) {
              debugPrint('[CanvasSync] Deleted item $id on backend');
            })
            .catchError((e) async {
              debugPrint(
                '[CanvasSync] Failed to delete item $id, queuing sync: $e',
              );
              await repo.queueItemDeletion(id);
            });
      } catch (e) {
        debugPrint('[CanvasSync] Exception deleting item: $e');
      }
    }
  }

  void updateViewport(Matrix4 newTransform) {
    state = state.copyWith(viewportTransform: newTransform);
  }

  void commitViewport() {
    commitState(state);

    final hasToken = _hiveDb.getAuthToken() != null;
    if (!hasToken) return;
    _viewportDebouncer?.cancel();
    _viewportDebouncer = Timer(const Duration(milliseconds: 800), () {
      try {
        final dio = _ref.read(dioClientProvider);
        dio
            .patch(
              '/focus/vision-room/viewport',
              data: {'viewport': state.viewportTransform?.storage.toList()},
            )
            .then((_) {
              debugPrint('[CanvasSync] Viewport synced to backend');
            })
            .catchError((e) {
              debugPrint(
                '[CanvasSync] Viewport patch failed ($e), falling back to full save',
              );
              saveRoomToServer().catchError((_) {});
            });
      } catch (e) {
        debugPrint('[CanvasSync] Exception syncing viewport: $e');
      }
    });
  }

  void selectItem(String id) {
    state = state.copyWith(selectedIds: {id});
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: {});
  }

  @override
  void dispose() {
    for (var debouncer in _itemDebouncers.values) {
      debouncer.cancel();
    }
    _viewportDebouncer?.cancel();
    super.dispose();
  }
}

final canvasStateProvider =
    StateNotifierProvider<CanvasHistoryNotifier, CanvasState>((ref) {
      final hiveDb = ref.watch(hiveDatabaseProvider);
      ref.watch(authProvider); // Force recreation on auth change (login/logout)
      final notifier = CanvasHistoryNotifier(hiveDb, ref);
      return notifier;
    });
