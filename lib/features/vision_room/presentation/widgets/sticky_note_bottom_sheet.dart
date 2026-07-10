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
import '../../../../core/theme/app_theme.dart';

class StickyNoteBottomSheet extends ConsumerStatefulWidget {
  final StickyNote? existingNote;

  const StickyNoteBottomSheet({super.key, this.existingNote});

  static void show(BuildContext context, {StickyNote? existingNote}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
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
  String _selectedColor = '#FCD34D';

  final List<String> _noteColors = [
    '#FCD34D', // Pastel Yellow (default)
    '#86EFAC', // Pastel Green
    '#93C5FD', // Pastel Blue
    '#FBCFE8', // Pastel Pink
    '#C084FC', // Pastel Purple
    '#FDBA74', // Pastel Orange
  ];

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
    _selectedColor = widget.existingNote?.color ?? '#FCD34D';
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
    final userId = authState.value?.id ?? '';

    final savedCategory = _category;

    final note =
        widget.existingNote?.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          progress: _progress.toInt(),
          priority: _priority,
          category: savedCategory,
          dueDate: _dueDate,
          color: _selectedColor,
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
          color: _selectedColor,
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
      height: MediaQuery.of(context).size.height * 0.60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: context.colors.bg2.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: context.colors.textPrimary.withValues(alpha: 0.08),
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
                margin: const EdgeInsets.only(top: 4, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: context.colors.textPrimary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingNote == null
                      ? 'CREATE STICKY NOTE'
                      : 'EDIT STICKY NOTE',
                  style: TextStyle(
                    color: context.colors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.close,
                    color: context.colors.textMuted,
                    size: 16,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title Input
            TextField(
              controller: _titleController,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Enter note title...',
                hintStyle: TextStyle(
                  color: context.colors.textPrimary.withValues(alpha: 0.25),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 6),

            // Description Input
            TextField(
              controller: _descController,
              style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add description / checklist items...',
                hintStyle: TextStyle(
                  color: context.colors.textPrimary.withValues(alpha: 0.25),
                ),
                filled: true,
                fillColor: context.colors.textPrimary.withValues(alpha: 0.02),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: context.colors.textPrimary.withValues(alpha: 0.05),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: context.colors.textPrimary.withValues(alpha: 0.05),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: activeColor),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Color Selector Row
            Text(
              'Select Note Color',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _noteColors.map((hexColor) {
                  final parsedColor = Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
                  final isSelected = _selectedColor == hexColor;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedColor = hexColor);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: parsedColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? context.colors.textPrimary : Colors.transparent,
                          width: 2.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: parsedColor.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.black54,
                                size: 14,
                              ),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Progress Slider Block
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: context.colors.textPrimary.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.textPrimary.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_progress.toInt()}%',
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: activeColor,
                      inactiveTrackColor: context.colors.textPrimary.withValues(alpha: 0.06),
                      thumbColor: context.colors.textPrimary,
                      overlayColor: activeColor.withValues(alpha: 0.2),
                      trackHeight: 3.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 10.0,
                      ),
                    ),
                    child: SizedBox(
                      height: 16,
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
            const SizedBox(height: 12),

            // Priority & Category Dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _priority,
                    dropdownColor: context.colors.bg2,
                    style: TextStyle(color: context.colors.textPrimary, fontSize: 12),
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      labelStyle: TextStyle(
                        color: context.colors.textMuted,
                        fontSize: 11,
                      ),
                      filled: true,
                      fillColor: context.colors.textPrimary.withValues(alpha: 0.02),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: context.colors.textPrimary.withValues(alpha: 0.05),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: context.colors.textPrimary.withValues(alpha: 0.05),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: activeColor),
                      ),
                    ),
                    items: ['Low', 'Medium', 'High']
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                p,
                                style: TextStyle(color: context.colors.textPrimary),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _priority = val!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _category,
                    dropdownColor: context.colors.bg2,
                    style: TextStyle(color: context.colors.textPrimary, fontSize: 12),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(
                        color: context.colors.textMuted,
                        fontSize: 11,
                      ),
                      filled: true,
                      fillColor: context.colors.textPrimary.withValues(alpha: 0.02),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: context.colors.textPrimary.withValues(alpha: 0.05),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: context.colors.textPrimary.withValues(alpha: 0.05),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: activeColor),
                      ),
                    ),
                    items: ['Personal', 'Work', 'Health', 'Study', 'Business']
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: TextStyle(color: context.colors.textPrimary),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _category = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Due Date Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: context.colors.textPrimary.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.textPrimary.withValues(alpha: 0.05)),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  Icons.calendar_today_rounded,
                  color: activeColor,
                  size: 16,
                ),
                title: Text(
                  'Due Date',
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _dueDate != null
                      ? '${_dueDate!.toLocal()}'.split(' ')[0]
                      : 'No Due Date Set',
                  style: TextStyle(color: context.colors.textMuted, fontSize: 11),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: context.colors.textMuted,
                    size: 12,
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: isDark
                                ? ColorScheme.dark(
                                    primary: activeColor,
                                    onPrimary: Colors.black,
                                    surface: context.colors.bg2,
                                    onSurface: context.colors.textPrimary,
                                  )
                                : ColorScheme.light(
                                    primary: activeColor,
                                    onPrimary: Colors.white,
                                    surface: context.colors.bg2,
                                    onSurface: context.colors.textPrimary,
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
            const SizedBox(height: 12),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: activeColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(42),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _save,
              child: const Text(
                'Save Note',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
