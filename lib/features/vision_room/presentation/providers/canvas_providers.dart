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
        items: [
          // 1. Polaroid Image
          VisionItem(
            id: 'guest_image_1',
            type: VisionItemType.image.name,
            content: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&auto=format&fit=crop&q=80',
            x: -280,
            y: -180,
            width: 170,
            height: 190,
            rotation: -0.05,
            colorValue: 0xFFFFFFFF,
            attachmentType: 'tape',
            attachmentStyle: 'beige',
            metadata: const {
              'caption': 'Yosemite Wilderness 🌲',
              'emoji': 'mountain',
              'scale': 1.0,
              'opacity': 1.0,
              'isOnShelf': true,
            },
          ),
          // 2. Finance Goal Progress
          VisionItem(
            id: 'guest_finance_1',
            type: VisionItemType.financeGoal.name,
            content: 'Dream House Fund',
            x: -80,
            y: -210,
            width: 210,
            height: 130,
            rotation: 0.02,
            colorValue: 0xFF1E1B4B,
            attachmentType: 'pin',
            attachmentStyle: 'redPin',
            metadata: const {
              'current': 35000.0,
              'target': 150000.0,
              'monthlyAmount': '1200',
              'description': 'For a modern cozy cabin by the lake.',
              'scale': 1.0,
              'opacity': 1.0,
              'isOnShelf': true,
            },
          ),
          // 3. Goal Tracker Card
          VisionItem(
            id: 'guest_goal_1',
            type: VisionItemType.goal.name,
            content: 'Fitness Marathon',
            x: 160,
            y: -220,
            width: 190,
            height: 130,
            rotation: -0.03,
            colorValue: 0xFF0D9488,
            attachmentType: 'pin',
            attachmentStyle: 'redPin',
            metadata: const {
              'current': 18.0,
              'target': 42.0,
              'targetDate': '2026-12-31',
              'category': 'Health',
              'description': 'Train to finish the full marathon under 4 hours.',
              'scale': 1.0,
              'opacity': 1.0,
              'isOnShelf': true,
            },
          ),
          // 4. Inspirational Quote
          VisionItem(
            id: 'guest_quote_1',
            type: VisionItemType.quote.name,
            content: '“The secret of getting ahead is getting started.”',
            x: -290,
            y: 40,
            width: 180,
            height: 120,
            rotation: 0.04,
            colorValue: 0xFF6B21A8,
            attachmentType: 'pin',
            attachmentStyle: 'redPin',
            metadata: const {
              'author': 'Mark Twain',
              'scale': 1.0,
              'opacity': 1.0,
              'isOnShelf': true,
            },
          ),
          // 5. Habits Checklist (Sticky Note)
          VisionItem(
            id: 'guest_note_1',
            type: VisionItemType.stickyNote.name,
            content: 'Daily Routine:\n• Meditate 10m 🧘\n• Read 15 pages 📚\n• Run 5km 🏃',
            x: -70,
            y: -30,
            width: 180,
            height: 180,
            rotation: -0.04,
            colorValue: 0xFFFEF08A, // Soft yellow
            attachmentType: 'tape',
            attachmentStyle: 'beige',
            metadata: const {
              'scale': 1.0,
              'opacity': 1.0,
              'isOnShelf': true,
            },
          ),
          // 6. Live Countdown Timer
          VisionItem(
            id: 'guest_countdown_1',
            type: VisionItemType.countdown.name,
            content: 'Product Launch Day 🚀',
            x: 140,
            y: 20,
            width: 190,
            height: 130,
            rotation: 0.03,
            colorValue: 0xFFB91C1C,
            attachmentType: 'pin',
            attachmentStyle: 'redPin',
            countdownDate: DateTime(2026, 12, 31),
            metadata: const {
              'description': 'Ship the beta release to the global community.',
              'scale': 1.0,
              'opacity': 1.0,
              'isOnShelf': true,
            },
          ),
        ],
      );
    }

    // THEN: schedule async loading (for logged-in users from backend)
    Future.microtask(() => _initAsync());
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
        final hasGuestItems = items.any((i) => i.id.startsWith('guest_'));
        if (hasGuestItems) {
          debugPrint('[CanvasSync] _initAsync: clearing guest items on successful login');
          await repo.saveLocalVisionItems([]);
          items = [];
          state = state.copyWith(items: []);
        }
      }

      if (isGuest) {
        // For guest users: if Hive has items (from seed or previous session) and has all 6 guest defaults with positive coordinates, use those.
        // Otherwise, reload/reset to our 6 beautiful default cards.
        final hasNewDefaults = items.length >= 6 &&
            items.any((i) => i.id == 'guest_countdown_1') &&
            items.every((i) => i.x >= 0) &&
            items.any((i) => i.id == 'guest_goal_1' && i.metadata?['milestones'] != null);
        debugPrint('[CanvasSync] _initAsync: guest path, hasNewDefaults = $hasNewDefaults');
        if (items.isNotEmpty && hasNewDefaults) {
          state = state.copyWith(items: items);
        } else {
          debugPrint('[CanvasSync] _initAsync: resetting to defaults list');
          final defaults = [
            // 1. Polaroid Image
            VisionItem(
              id: 'guest_image_1',
              type: VisionItemType.image.name,
              content: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&auto=format&fit=crop&q=80',
              x: 16,
              y: 50,
              width: 150,
              height: 165,
              rotation: -0.05,
              colorValue: 0xFFFFFFFF,
              attachmentType: 'tape',
              attachmentStyle: 'beige',
              metadata: const {
                'caption': 'Yosemite Wilderness 🌲',
                'emoji': 'mountain',
                'scale': 1.0,
                'opacity': 1.0,
                'isOnShelf': true,
              },
            ),
            // 2. Finance Goal Progress
            VisionItem(
              id: 'guest_finance_1',
              type: VisionItemType.financeGoal.name,
              content: 'Dream House Fund',
              x: 180,
              y: 40,
              width: 165,
              height: 115,
              rotation: 0.02,
              colorValue: 0xFF1E1B4B,
              attachmentType: 'pin',
              attachmentStyle: 'redPin',
              metadata: const {
                'currentAmount': 35000.0,
                'targetAmount': 150000.0,
                'monthlyAmount': '1200',
                'description': 'For a modern cozy cabin by the lake.',
                'scale': 1.0,
                'opacity': 1.0,
                'isOnShelf': true,
              },
            ),
            // 3. Goal Tracker Card
            VisionItem(
              id: 'guest_goal_1',
              type: VisionItemType.goal.name,
              content: 'Fitness Marathon',
              x: 16,
              y: 235,
              width: 165,
              height: 128,
              rotation: -0.03,
              colorValue: 0xFF0D9488,
              attachmentType: 'pin',
              attachmentStyle: 'redPin',
              metadata: const {
                'currentAmount': 18.0,
                'targetAmount': 42.0,
                'showProgress': true,
                'priority': 'high',
                'targetDate': '2026-12-31',
                'category': 'Health',
                'description': 'Train to finish the full marathon under 4 hours.',
                'scale': 1.0,
                'opacity': 1.0,
                'isOnShelf': true,
                'milestones': [
                  {'id': 'm1', 'title': 'Beta Test Release', 'isCompleted': true},
                  {'id': 'm2', 'title': 'App Store Launch', 'isCompleted': false},
                ],
                'checklist': [
                  {'id': 's1', 'title': 'Fix UI bugs', 'isCompleted': true},
                  {'id': 's2', 'title': 'Design cards', 'isCompleted': true},
                ],
              },
            ),
            // 4. Inspirational Quote
            VisionItem(
              id: 'guest_quote_1',
              type: VisionItemType.quote.name,
              content: '“The secret of getting ahead is getting started.”',
              x: 185,
              y: 170,
              width: 160,
              height: 115,
              rotation: 0.04,
              colorValue: 0xFF6B21A8,
              attachmentType: 'pin',
              attachmentStyle: 'redPin',
              metadata: const {
                'author': 'Mark Twain',
                'scale': 1.0,
                'opacity': 1.0,
                'isOnShelf': true,
              },
            ),
            // 5. Habits Checklist (Sticky Note)
            VisionItem(
              id: 'guest_note_1',
              type: VisionItemType.stickyNote.name,
              content: 'Daily Routine:\n• Meditate 10m 🧘\n• Read 15 pages 📚\n• Run 5km 🏃',
              x: 16,
              y: 365,
              width: 160,
              height: 110,
              rotation: -0.04,
              colorValue: 0xFFFEF08A, // Soft yellow
              attachmentType: 'tape',
              attachmentStyle: 'beige',
              metadata: const {
                'scale': 1.0,
                'opacity': 1.0,
                'isOnShelf': true,
              },
            ),
            // 6. Live Countdown Timer
            VisionItem(
              id: 'guest_countdown_1',
              type: VisionItemType.countdown.name,
              content: 'Product Launch Day 🚀',
              x: 185,
              y: 300,
              width: 160,
              height: 115,
              rotation: 0.03,
              colorValue: 0xFFB91C1C,
              attachmentType: 'pin',
              attachmentStyle: 'redPin',
              countdownDate: DateTime(2026, 12, 31),
              metadata: const {
                'description': 'Ship the beta release to the global community.',
                'scale': 1.0,
                'opacity': 1.0,
                'isOnShelf': true,
              },
            ),
          ];
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
    final isGuest = _hiveDb.getAuthToken() == null;
    if (isGuest) {
      if (item.type == 'stickyNote') {
        final count = state.items.where((i) => i.type == 'stickyNote').length;
        if (count >= 3) {
          _ref.read(premiumAuthTriggerProvider.notifier).state = 'stickyNote';
          return;
        }
      } else if (item.type == 'image') {
        final count = state.items.where((i) => i.type == 'image').length;
        if (count >= 2) {
          _ref.read(premiumAuthTriggerProvider.notifier).state = 'image';
          return;
        }
      } else if (item.type == 'quote') {
        final count = state.items.where((i) => i.type == 'quote').length;
        if (count >= 2) {
          _ref.read(premiumAuthTriggerProvider.notifier).state = 'quote';
          return;
        }
      }
    }

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
