import 'package:flutter/material.dart';
import 'vision_item.dart';

class CanvasState {
  final List<VisionItem> items;
  final Set<String> selectedIds;
  final Matrix4 viewportTransform;

  CanvasState({
    required this.items,
    this.selectedIds = const {},
    Matrix4? viewportTransform,
  }) : viewportTransform = viewportTransform ?? Matrix4.identity();

  CanvasState copyWith({
    List<VisionItem>? items,
    Set<String>? selectedIds,
    Matrix4? viewportTransform,
  }) {
    return CanvasState(
      items: items ?? this.items,
      selectedIds: selectedIds ?? this.selectedIds,
      viewportTransform: viewportTransform ?? this.viewportTransform.clone(),
    );
  }
}
