import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/models/canvas_state.dart';
import '../../domain/models/vision_item.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/models/auth_user_model.dart';

class CanvasHistoryNotifier extends StateNotifier<CanvasState> {
  final HiveDatabase _hiveDb;
  final Ref _ref;
  final List<CanvasState> _undoStack = [];
  final List<CanvasState> _redoStack = [];
  final Map<String, Timer> _itemDebouncers = {};

  CanvasHistoryNotifier(this._hiveDb, this._ref) : super(CanvasState(items: [])) {
    _loadInitialItems();

    // Listen to authentication state changes to reload vision items
    _ref.listen<AsyncValue<AuthUserModel?>>(authProvider, (previous, next) {
      if (next.hasValue) {
        debugPrint('[CanvasHistoryNotifier] Auth state changed, reloading initial items...');
        _loadInitialItems();
      }
    });
  }

  void _loadInitialItems() {
    final hasToken = _hiveDb.getAuthToken() != null;
    if (hasToken) {
      try {
        final dio = _ref.read(dioClientProvider);
        dio.get('/focus/vision-room').then((response) {
          if (response.data != null && response.data['success'] == true) {
            final data = response.data['data'];
            final itemsList = data['items'] as List?;
            if (itemsList != null) {
              final items = itemsList.map((itemJson) {
                return VisionItem(
                  id: itemJson['itemId'] ?? '',
                  type: itemJson['type'] ?? '',
                  content: itemJson['type'] == 'image' ? (itemJson['imageUrl'] ?? '') : (itemJson['text'] ?? ''),
                  x: (itemJson['xPosition'] as num?)?.toDouble() ?? 0.0,
                  y: (itemJson['yPosition'] as num?)?.toDouble() ?? 0.0,
                  width: (itemJson['width'] as num?)?.toDouble() ?? 180.0,
                  height: (itemJson['height'] as num?)?.toDouble() ?? 120.0,
                  rotation: (itemJson['rotation'] as num?)?.toDouble() ?? 0.0,
                  colorValue: itemJson['color'] != null && itemJson['color'].toString().isNotEmpty
                      ? int.tryParse(itemJson['color'], radix: 16) ?? 0xFF1E1B4B
                      : 0xFF1E1B4B,
                  isPinned: itemJson['locked'] ?? false,
                  zIndex: (itemJson['zIndex'] as num?)?.toInt() ?? 0,
                  attachmentType: 'pin',
                  attachmentStyle: 'redPin',
                  materialStyle: 'default',
                  metadata: {
                    'scale': (itemJson['scale'] as num?)?.toDouble() ?? 1.0,
                    'opacity': (itemJson['opacity'] as num?)?.toDouble() ?? 1.0,
                    'font': itemJson['font'] ?? '',
                  }
                );
              }).toList();
              
              items.sort((a, b) => a.zIndex.compareTo(b.zIndex));
              state = CanvasState(items: items);
              
              final serialized = items.map((i) => i.toJson()).toList();
              _hiveDb.saveVisionItems(serialized);
              return;
            }
          }
          _loadLocalCached();
        }).catchError((e) {
          debugPrint('[CanvasSync] Error loading initial items from backend: $e');
          _loadLocalCached();
        });
      } catch (e) {
        debugPrint('[CanvasSync] Exception loading initial items: $e');
        _loadLocalCached();
      }
    } else {
      _loadLocalCached();
    }
  }

  void _loadLocalCached() {
    final cached = _hiveDb.getVisionItems();
    var items = cached.map((json) => VisionItem.fromJson(json)).toList();
    if (items.isEmpty) {
      items = [
        VisionItem(
          id: 'sample_note_1',
          type: VisionItemType.stickyNote.name,
          content: 'Focus on daily progress ✨',
          x: 50,
          y: 160,
          width: 170,
          height: 160,
          rotation: -0.04,
          colorValue: 0xFF3B82F6,
          attachmentType: 'pin',
          attachmentStyle: 'redPin',
        ),
        VisionItem(
          id: 'sample_quote_1',
          type: VisionItemType.quote.name,
          content: '"Small steps every day leads to massive results."',
          x: 230,
          y: 190,
          width: 180,
          height: 140,
          rotation: 0.03,
          attachmentType: 'pin',
          attachmentStyle: 'redPin',
          metadata: const {'author': 'Daily Discipline'},
        ),
        VisionItem(
          id: 'sample_goal_1',
          type: VisionItemType.goal.name,
          content: 'Master My Habits',
          x: 100,
          y: 350,
          width: 220,
          height: 150,
          rotation: -0.02,
          attachmentType: 'pin',
          attachmentStyle: 'redPin',
          metadata: const {'targetDate': '2026-12-31', 'category': 'Growth'},
        ),
      ];
      final serialized = items.map((i) => i.toJson()).toList();
      _hiveDb.saveVisionItems(serialized);
    }
    state = CanvasState(items: items);
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void _saveState() {
    final serializedItems = state.items.map((i) => i.toJson()).toList();
    _hiveDb.saveVisionItems(serializedItems);
  }

  Future<void> saveRoomToServer() async {
    final hasToken = _hiveDb.getAuthToken() != null;
    if (!hasToken) return;

    try {
      final dio = _ref.read(dioClientProvider);
      final serializedItems = state.items.map((i) => i.toJson()).toList();
      await dio.post(
        '/focus/vision-room',
        data: {
          'items': serializedItems,
        },
      );
      debugPrint('[CanvasSync] Saved entire room to server successfully');
    } catch (e) {
      debugPrint('[CanvasSync] Error saving entire room: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _mapItemToDbKeys(VisionItem item) {
    return {
      'itemId': item.id,
      'type': item.type,
      'imageUrl': item.type == 'image' ? item.content : '',
      'text': item.type != 'image' ? item.content : '',
      'color': item.colorValue.toRadixString(16),
      'font': item.metadata?['font'] ?? '',
      'xPosition': item.x,
      'yPosition': item.y,
      'width': item.width,
      'height': item.height,
      'rotation': item.rotation,
      'scale': item.metadata?['scale'] ?? 1.0,
      'zIndex': item.zIndex,
      'opacity': item.metadata?['opacity'] ?? 1.0,
      'locked': item.isPinned,
    };
  }

  void _debouncePatchItem(String id, Map<String, dynamic> data) {
    final hasToken = _hiveDb.getAuthToken() != null;
    if (!hasToken) return;

    _itemDebouncers[id]?.cancel();
    _itemDebouncers[id] = Timer(const Duration(milliseconds: 350), () {
      try {
        final dio = _ref.read(dioClientProvider);
        dio.patch('/focus/vision-room/item/$id', data: data).then((_) {
          debugPrint('[CanvasSync] Patched item $id successfully');
        }).catchError((e) {
          debugPrint('[CanvasSync] Failed to patch item $id: $e');
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
        final dio = _ref.read(dioClientProvider);
        final payload = _mapItemToDbKeys(newItem);
        payload['countdownDate'] = newItem.countdownDate?.toIso8601String();
        payload['metadata'] = newItem.metadata;
        dio.post('/focus/vision-room/item', data: payload).then((_) {
          debugPrint('[CanvasSync] Created item ${newItem.id} on backend');
        }).catchError((e) {
          debugPrint('[CanvasSync] Failed to create item ${newItem.id}: $e');
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
        _debouncePatchItem(id, {'zIndex': updated.zIndex});
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
        _debouncePatchItem(id, {'zIndex': updated.zIndex});
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
        _debouncePatchItem(id, {
          'xPosition': updated.x,
          'yPosition': updated.y
        });
        return updated;
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedItems);
  }

  void updateSize(String id, double width, double height, {double? dx, double? dy}) {
    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        final updated = item.copyWith(
          width: width.clamp(50.0, 2000.0),
          height: height.clamp(50.0, 2000.0),
          x: item.x + (dx ?? 0),
          y: item.y + (dy ?? 0),
        );
        _debouncePatchItem(id, {
          'xPosition': updated.x,
          'yPosition': updated.y,
          'width': updated.width,
          'height': updated.height
        });
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
        final patchData = updated.type == 'image' 
            ? {'imageUrl': newContent} 
            : {'text': newContent};
        _debouncePatchItem(id, patchData);
        return updated;
      }
      return item;
    }).toList();
    commitState(state.copyWith(items: updatedItems));
  }

  void updateItemDetails(String id, {String? content, int? colorValue, Map<String, dynamic>? metadata}) {
    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        final newMetadata = metadata != null
            ? {...?item.metadata, ...metadata}
            : item.metadata;
        final updated = item.copyWith(
          content: content ?? item.content,
          colorValue: colorValue ?? item.colorValue,
          metadata: newMetadata,
        );
        _debouncePatchItem(id, {
          if (content != null) (updated.type == 'image' ? 'imageUrl' : 'text'): content,
          if (colorValue != null) 'color': colorValue.toRadixString(16),
          'metadata': newMetadata,
        });
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
        final updated = item.copyWith(attachmentType: type, attachmentStyle: style);
        _debouncePatchItem(id, {
          'attachmentType': type,
          'attachmentStyle': style
        });
        return updated;
      }
      return item;
    }).toList();
    commitState(state.copyWith(items: updatedItems));
  }

  void commitTransform(String id, double newWidth, double newHeight, double newRotation) {
    final newItems = state.items.map((item) {
      if (item.id == id) {
        final updated = item.copyWith(
          width: newWidth.clamp(50.0, 2000.0),
          height: newHeight.clamp(50.0, 2000.0),
          rotation: newRotation,
        );
        _debouncePatchItem(id, {
          'width': updated.width,
          'height': updated.height,
          'rotation': updated.rotation
        });
        return updated;
      }
      return item;
    }).toList();
    commitState(state.copyWith(items: newItems));
  }

  void removeItem(String id) {
    commitState(state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    ));

    final hasToken = _hiveDb.getAuthToken() != null;
    if (hasToken) {
      try {
        final dio = _ref.read(dioClientProvider);
        dio.delete('/focus/vision-room/item/$id').then((_) {
          debugPrint('[CanvasSync] Deleted item $id on backend');
        }).catchError((e) {
          debugPrint('[CanvasSync] Failed to delete item $id: $e');
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
    super.dispose();
  }
}

final canvasStateProvider = StateNotifierProvider<CanvasHistoryNotifier, CanvasState>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  final notifier = CanvasHistoryNotifier(hiveDb, ref);
  return notifier;
});
