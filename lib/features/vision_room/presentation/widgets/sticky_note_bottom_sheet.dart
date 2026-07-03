import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/sticky_note.dart';
import '../providers/sticky_note_provider.dart';
import '../providers/vision_room_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/preview_mode_provider.dart';
import '../../../auth/presentation/widgets/premium_auth_sheet.dart';
import '../../../auth/presentation/widgets/start_workspace_sheet.dart';

class StickyNoteBottomSheet extends ConsumerStatefulWidget {
  final StickyNote? existingNote;

  const StickyNoteBottomSheet({super.key, this.existingNote});

  static void show(BuildContext context, {StickyNote? existingNote}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StickyNoteBottomSheet(existingNote: existingNote),
      ),
    );
  }

  @override
  ConsumerState<StickyNoteBottomSheet> createState() =>
      _StickyNoteBottomSheetState();
}

class _StickyNoteBottomSheetState extends ConsumerState<StickyNoteBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  double _progress = 0;
  String _priority = 'Low';
  String _category = 'Personal';
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.existingNote?.title ?? '',
    );
    _descController = TextEditingController(
      text: widget.existingNote?.description ?? '',
    );
    _progress = (widget.existingNote?.progress ?? 0).toDouble();
    _priority = widget.existingNote?.priority ?? 'Low';
    final rawCategory = widget.existingNote?.category ?? 'Personal';
    _category = rawCategory.split('#').first;
    _dueDate = widget.existingNote?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;

    final authState = ref.read(authProvider);
    final isGuest = authState.value == null;
    final userId = authState.value?.id ?? '';
    final isPreviewMode = ref.read(previewModeProvider);

    if (widget.existingNote == null) {
      if (isPreviewMode) {
        Navigator.pop(context);
        StartWorkspaceSheet.show(context);
        return;
      }

      if (isGuest) {
        final currentNotes = ref.read(stickyNotesProvider);
        if (currentNotes.length >= 1) {
          Navigator.pop(context);
          PremiumAuthSheet.show(context);
          return;
        }
      }
    }

    final savedCategory = _category;

    final note =
        widget.existingNote?.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          progress: _progress.toInt(),
          priority: _priority,
          category: savedCategory,
          dueDate: _dueDate,
        ) ??
        StickyNote(
          id: const Uuid().v4(),
          userId: userId,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          progress: _progress.toInt(),
          priority: _priority,
          category: savedCategory,
          dueDate: _dueDate,
        );

    if (widget.existingNote == null) {
      ref.read(stickyNotesProvider.notifier).addNote(note);
    } else {
      ref.read(stickyNotesProvider.notifier).updateNote(note);
    }

    Navigator.pop(context);
  }

  void _updateProgressLive(double val) {
    setState(() => _progress = val);

    // Live update the Vision Room Card immediately!
    if (widget.existingNote != null) {
      final updated = widget.existingNote!.copyWith(progress: val.toInt());
      ref.read(stickyNotesProvider.notifier).updateNote(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF6366F1); // Indigo premium accent

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingNote == null
                      ? 'CREATE STICKY NOTE'
                      : 'EDIT STICKY NOTE',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white38,
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title Input
            TextField(
              controller: _titleController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Enter note title...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 12),

            // Description Input
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add description / checklist items...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.02),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: activeColor),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Progress Slider Block
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_progress.toInt()}%',
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: activeColor,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.06),
                      thumbColor: Colors.white,
                      overlayColor: activeColor.withValues(alpha: 0.2),
                      trackHeight: 4.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14.0,
                      ),
                    ),
                    child: SizedBox(
                      height: 20,
                      child: Slider(
                        value: _progress,
                        min: 0,
                        max: 100,
                        onChanged: _updateProgressLive,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Priority & Category Dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _priority,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      labelStyle: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.02),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: activeColor),
                      ),
                    ),
                    items: ['Low', 'Medium', 'High']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) => setState(() => _priority = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _category,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.02),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: activeColor),
                      ),
                    ),
                    items: ['Personal', 'Work', 'Health', 'Study', 'Business']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => _category = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Due Date Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  Icons.calendar_today_rounded,
                  color: activeColor,
                  size: 18,
                ),
                title: const Text(
                  'Due Date',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _dueDate != null
                      ? '${_dueDate!.toLocal()}'.split(' ')[0]
                      : 'No Due Date Set',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white24,
                    size: 14,
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.dark(
                              primary: activeColor,
                              onPrimary: Colors.black,
                              surface: const Color(0xFF0F172A),
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) setState(() => _dueDate = date);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Add to Wooden Shelf Switch Row

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: activeColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(50),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _save,
              child: const Text(
                'Save Note',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
