import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/sticky_note.dart';
import '../providers/sticky_note_provider.dart';
import '../providers/vision_room_providers.dart';
import 'sticky_note_bottom_sheet.dart';

class StickyNoteWidget extends ConsumerStatefulWidget {
  final StickyNote note;

  const StickyNoteWidget({super.key, required this.note});

  @override
  ConsumerState<StickyNoteWidget> createState() => _StickyNoteWidgetState();
}

class _StickyNoteWidgetState extends ConsumerState<StickyNoteWidget> {
  bool _isHovering = false;
  double _dragStartX = 0;
  double _dragStartY = 0;
  double _initialX = 0;
  double _initialY = 0;

  double _initialScale = 1.0;
  double _initialRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    final isEditMode = ref.watch(editModeProvider);
    final isCompleted = widget.note.progress == 100;
    final paperColor = Color(int.parse(widget.note.color.replaceFirst('#', '0xFF')));

    return GestureDetector(
      onTap: () {
        if (!isEditMode) {
          HapticFeedback.lightImpact();
          StickyNoteBottomSheet.show(context, existingNote: widget.note);
        }
      },
      onScaleStart: isEditMode ? (details) {
        _dragStartX = details.focalPoint.dx;
        _dragStartY = details.focalPoint.dy;
        _initialX = widget.note.x;
        _initialY = widget.note.y;
        _initialScale = widget.note.scale;
        _initialRotation = widget.note.rotation;
      } : null,
      onScaleUpdate: isEditMode ? (details) {
        final dx = details.focalPoint.dx - _dragStartX;
        final dy = details.focalPoint.dy - _dragStartY;
        final updated = widget.note.copyWith(
          x: _initialX + dx,
          y: _initialY + dy,
          scale: _initialScale * details.scale,
          rotation: _initialRotation + details.rotation,
        );
        ref.read(stickyNotesProvider.notifier).updateNote(updated);
      } : null,
      onScaleEnd: isEditMode ? (_) {
        HapticFeedback.lightImpact();
      } : null,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 160,
          height: 160,
          transform: Matrix4.rotationZ(widget.note.rotation)..scale(widget.note.scale),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: paperColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovering || isEditMode ? 0.3 : 0.15),
                blurRadius: _isHovering || isEditMode ? 12 : 6,
                offset: Offset(4, _isHovering || isEditMode ? 8 : 4),
              ),
              // Inner shadow to simulate paper texture
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(-2, -2),
              ),
            ],
            border: isEditMode ? Border.all(color: Colors.blueAccent, width: 2) : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Sticky Note Tape
              Positioned(
                top: -12,
                left: 45,
                right: 45,
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.note.title,
                      maxLines: widget.note.description.isEmpty ? 4 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.kalam(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withValues(alpha: 0.85),
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (widget.note.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          widget.note.description,
                          maxLines: 4,
                          overflow: TextOverflow.fade,
                          style: GoogleFonts.kalam(
                            fontSize: 14,
                            color: Colors.black.withValues(alpha: 0.7),
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Edit mode delete button
              if (isEditMode)
                Positioned(
                  right: -8,
                  top: -8,
                  child: GestureDetector(
                    onTap: () => ref.read(stickyNotesProvider.notifier).deleteNote(widget.note.id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
