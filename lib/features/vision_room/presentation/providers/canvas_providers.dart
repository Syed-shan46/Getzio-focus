import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/canvas_state.dart';
import '../../domain/models/vision_item.dart';

class CanvasHistoryNotifier extends StateNotifier<CanvasState> {
  final List<CanvasState> _undoStack = [];
  final List<CanvasState> _redoStack = [];

  CanvasHistoryNotifier(super.state);

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void commitState(CanvasState newState) {
    if (state != newState) {
      _undoStack.add(state);
      _redoStack.clear();
      state = newState;
      
      // Limit history to 50 items to save memory if necessary, but "unlimited" is requested
      // If we experience memory issues with 200+ objects, we might restrict this.
    }
  }

  void undo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(state);
      state = _undoStack.removeLast();
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(state);
      state = _redoStack.removeLast();
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
  final notifier = CanvasHistoryNotifier(CanvasState(items: []));
  return notifier;
});
