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
  ConsumerState<StickyNoteBottomSheet> createState() => _StickyNoteBottomSheetState();
}

class _StickyNoteBottomSheetState extends ConsumerState<StickyNoteBottomSheet> with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  double _progress = 0;
  String _priority = 'Low';
  String _category = 'Personal';
  DateTime? _dueDate;
  
  late TabController _tabController;

  bool _addToShelf = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
    _descController = TextEditingController(text: widget.existingNote?.description ?? '');
    _progress = (widget.existingNote?.progress ?? 0).toDouble();
    _priority = widget.existingNote?.priority ?? 'Low';
    final rawCategory = widget.existingNote?.category ?? 'Personal';
    _category = rawCategory.split('#').first;
    _addToShelf = rawCategory.contains('#shelf');
    _dueDate = widget.existingNote?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tabController.dispose();
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

    final savedCategory = _addToShelf ? '$_category#shelf' : _category;

    final note = widget.existingNote?.copyWith(
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
      // For debouncing API calls, the Notifier itself should handle the debounce or we rely on the repository queue.
      // But we must update the state instantly so the UI reflects it.
      ref.read(stickyNotesProvider.notifier).updateNote(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Checklist'),
              Tab(text: 'History'),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                const Center(child: Text('Checklist (Future)', style: TextStyle(color: Colors.white54))),
                const Center(child: Text('History (Future)', style: TextStyle(color: Colors.white54))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TextField(
          controller: _titleController,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Sticky Note Title...',
            hintStyle: TextStyle(color: Colors.white30),
            border: InputBorder.none,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descController,
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Description (optional)',
            hintStyle: TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Progress Slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progress', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
            Text('${_progress.toInt()}%', style: GoogleFonts.outfit(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.blueAccent,
            inactiveTrackColor: Colors.white10,
            thumbColor: Colors.white,
            trackHeight: 6,
          ),
          child: Slider(
            value: _progress,
            min: 0,
            max: 100,
            onChanged: _updateProgressLive,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Priority & Category
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _priority,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Priority',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: ['Low', 'Medium', 'High'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) => setState(() => _priority = val!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: ['Personal', 'Work', 'Health', 'Study', 'Business'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Due Date
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Due Date', style: GoogleFonts.outfit(color: Colors.white)),
          subtitle: Text(
            _dueDate != null ? '${_dueDate!.toLocal()}'.split(' ')[0] : 'No Due Date',
            style: const TextStyle(color: Colors.white54),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dueDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) setState(() => _dueDate = date);
            },
          ),
        ),
        
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.archive_outlined, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Add to Wooden Shelf',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            Switch(
              value: _addToShelf,
              activeColor: Colors.blueAccent,
              onChanged: (val) => setState(() => _addToShelf = val),
            ),
          ],
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            minimumSize: const Size.fromHeight(50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _save,
          child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
