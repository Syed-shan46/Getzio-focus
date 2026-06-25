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
    final cached = _hiveDb.getVisionItems();
    final items = cached.map((json) => VisionItem.fromJson(json)).toList();
    state = CanvasState(items: items);
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void _saveState() {
    final serializedItems = state.items.map((i) => i.toJson()).toList();
    _hiveDb.saveVisionItems(serializedItems);

    // Sync to backend if logged in
    final hasToken = _hiveDb.getAuthToken() != null;
    if (hasToken) {
      try {
        final dio = _ref.read(dioClientProvider);
        dio.post(
          '/api/focus/vision-room',
          data: {
            'items': serializedItems,
          },
        ).then((_) {
          debugPrint('[CanvasSync] Synced vision items to server successfully');
        }).catchError((e) {
          debugPrint('[CanvasSync] Failed to sync vision items: $e');
        });
      } catch (e) {
        debugPrint('[CanvasSync] Error syncing vision items: $e');
      }
    }
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
  }

  void bringToFront(String id) {
    int maxZ = 0;
    for (var i in state.items) {
      if (i.zIndex > maxZ) maxZ = i.zIndex;
    }
    
    final newItems = state.items.map((item) {
      if (item.id == id) {
        return item.copyWith(zIndex: maxZ + 1);
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
        return item.copyWith(zIndex: minZ - 1);
      }
      return item;
    }).toList();
    
    newItems.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    commitState(state.copyWith(items: newItems));
  }

  void updatePosition(String id, double dx, double dy) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(x: item.x + dx, y: item.y + dy);
        }
        return item;
      }).toList(),
    );
  }

  void updateSize(String id, double width, double height, {double? dx, double? dy}) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(
            width: width.clamp(50.0, 2000.0),
            height: height.clamp(50.0, 2000.0),
            x: item.x + (dx ?? 0),
            y: item.y + (dy ?? 0),
          );
        }
        return item;
      }).toList(),
    );
  }

  void updateContent(String id, String newContent) {
    commitState(state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(content: newContent);
        }
        return item;
      }).toList(),
    ));
  }

  void updateAttachment(String id, String type, String style) {
    commitState(state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(attachmentType: type, attachmentStyle: style);
        }
        return item;
      }).toList(),
    ));
  }

  void commitTransform(String id, double newWidth, double newHeight, double newRotation) {
    // This is called at the end of a gesture (e.g., drag end or scale end).
    // Here we commit the final position/scale/rotation to the undo stack.
    final newItems = state.items.map((item) {
      if (item.id == id) {
        return item.copyWith(
          width: newWidth.clamp(50.0, 2000.0),
          height: newHeight.clamp(50.0, 2000.0),
          rotation: newRotation,
        );
      }
      return item;
    }).toList();
    commitState(state.copyWith(items: newItems));
  }

  void removeItem(String id) {
    commitState(state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    ));
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
}

final canvasStateProvider = StateNotifierProvider<CanvasHistoryNotifier, CanvasState>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  final notifier = CanvasHistoryNotifier(hiveDb, ref);
  return notifier;
});
