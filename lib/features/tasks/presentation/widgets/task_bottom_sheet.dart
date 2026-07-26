import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../domain/models/task_model.dart';
import '../providers/tasks_provider.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../auth/presentation/widgets/premium_auth_sheet.dart';
import '../../../../core/theme/app_theme.dart';

class TaskBottomSheet extends ConsumerStatefulWidget {
  final TaskModel? existingTask;

  const TaskBottomSheet({super.key, this.existingTask});

  @override
  ConsumerState<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends ConsumerState<TaskBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _category;
  late TaskPriority _priority;
  DateTime? _dueDate;
  bool _pinned = false;
  double _manualProgress = 0;
  List<SubtaskModel> _subtasks = [];
  
  // Smart Planning Subtask Editor state
  bool _showSubtaskEditor = false;
  int? _editingSubtaskIndex;
  final _subtaskTitleController = TextEditingController();
  DateTime? _subtaskDueDate;
  String? _subtaskDueTime;
  bool _subtaskReminder = true;

  bool get _isReadOnly => false;

  final List<String> _defaultCategories = [
    'Personal',
    'Work',
    'Business',
    'Study',
    'Health',
    'Fitness',
    'Finance',
    'Shopping',
  ];
  List<String> _customCategories = [];

  List<String> get _allCategories => [
    ..._defaultCategories,
    ..._customCategories,
  ];

  @override
  void initState() {
    super.initState();

    // Load custom categories from Hive
    final hive = ref.read(hiveDatabaseProvider);
    _customCategories = hive.getCustomCategories();

    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _category = task?.category ?? 'Personal';
    _priority = task?.priority ?? TaskPriority.medium;
    _dueDate = task?.dueDate;
    _pinned = task?.pinned ?? false;
    _manualProgress = task?.manualProgress ?? 0;
    _subtasks = task?.subtasks.toList() ?? [];

    // Sort subtasks by sortOrder initially
    _subtasks.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskTitleController.dispose();
    super.dispose();
  }

  void _openSubtaskEditor({int? index}) {
    setState(() {
      _editingSubtaskIndex = index;
      _showSubtaskEditor = true;
      if (index != null) {
        final sub = _subtasks[index];
        _subtaskTitleController.text = sub.title;
        _subtaskDueDate = sub.dueDate;
        _subtaskDueTime = sub.dueTime;
        _subtaskReminder = sub.reminder;
      } else {
        _subtaskTitleController.clear();
        _subtaskDueDate = DateTime.now(); // default today
        _subtaskDueTime = null;
        _subtaskReminder = true;
      }
    });
  }

  void _saveSubtask() {
    final title = _subtaskTitleController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      if (_editingSubtaskIndex != null) {
        final existing = _subtasks[_editingSubtaskIndex!];
        _subtasks[_editingSubtaskIndex!] = existing.copyWith(
          title: title,
          dueDate: _subtaskDueDate,
          dueTime: _subtaskDueTime,
          reminder: _subtaskReminder,
          reminderStyle: _subtaskReminder ? ReminderStyle.balanced : ReminderStyle.none,
          updatedAt: DateTime.now(),
        );
      } else {
        _subtasks.add(
          SubtaskModel(
            id: const Uuid().v4(),
            title: title,
            completed: false,
            dueDate: _subtaskDueDate,
            dueTime: _subtaskDueTime,
            reminder: _subtaskReminder,
            reminderStyle: _subtaskReminder ? ReminderStyle.balanced : ReminderStyle.none,
            sortOrder: _subtasks.length,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
      
      _sortSubtasks();
      
      _showSubtaskEditor = false;
      _editingSubtaskIndex = null;
      _subtaskTitleController.clear();
      _subtaskDueDate = null;
      _subtaskDueTime = null;
      _subtaskReminder = true;
    });
  }

  void _cancelSubtaskEditor() {
    setState(() {
      _showSubtaskEditor = false;
      _editingSubtaskIndex = null;
      _subtaskTitleController.clear();
      _subtaskDueDate = null;
      _subtaskDueTime = null;
      _subtaskReminder = true;
    });
  }

  void _sortSubtasks() {
    _subtasks.sort((a, b) {
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1;
      }
      
      if (a.completed && b.completed) {
        if (a.completedAt == null) return 1;
        if (b.completedAt == null) return -1;
        return b.completedAt!.compareTo(a.completedAt!);
      }
      
      if (a.dueDate != null && b.dueDate == null) return -1;
      if (a.dueDate == null && b.dueDate != null) return 1;
      if (a.dueDate != null && b.dueDate != null) {
        final aDate = DateTime(a.dueDate!.year, a.dueDate!.month, a.dueDate!.day);
        final bDate = DateTime(b.dueDate!.year, b.dueDate!.month, b.dueDate!.day);
        if (aDate != bDate) {
          return aDate.compareTo(bDate);
        }
        
        if (a.dueTime != null && b.dueTime == null) return -1;
        if (a.dueTime == null && b.dueTime != null) return 1;
        if (a.dueTime != null && b.dueTime != null) {
          return a.dueTime!.compareTo(b.dueTime!);
        }
      }
      
      return a.sortOrder.compareTo(b.sortOrder);
    });
  }

  String _getCountdownString(DateTime? date, String? timeStr) {
    if (date == null) return 'No deadline set';
    final now = DateTime.now();
    
    DateTime targetDateTime;
    if (timeStr != null) {
      final timeFormat = DateFormat('h:mm a');
      try {
        final parsedTime = timeFormat.parse(timeStr);
        targetDateTime = DateTime(date.year, date.month, date.day, parsedTime.hour, parsedTime.minute);
      } catch (_) {
        targetDateTime = DateTime(date.year, date.month, date.day);
      }
    } else {
      targetDateTime = DateTime(date.year, date.month, date.day, 23, 59);
    }

    final diff = targetDateTime.difference(now);
    
    if (diff.isNegative) {
      if (diff.inDays.abs() > 0) {
        return 'Overdue by ${diff.inDays.abs()} Days';
      } else if (diff.inHours.abs() > 0) {
        return 'Overdue by ${diff.inHours.abs()}h';
      } else {
        return 'Overdue';
      }
    }

    if (timeStr != null) {
      if (diff.inHours > 0) {
        return '${diff.inHours}h ${diff.inMinutes % 60}m left';
      } else {
        return '${diff.inMinutes} mins left';
      }
    } else {
      final today = DateTime(now.year, now.month, now.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      final daysDiff = targetDate.difference(today).inDays;
      if (daysDiff == 0) {
        return 'Today';
      } else if (daysDiff == 1) {
        return 'Tomorrow';
      } else {
        return '$daysDiff Days Left';
      }
    }
  }

  Color _getCountdownColor(DateTime? date, String? timeStr, bool completed) {
    if (completed) return Colors.grey;
    if (date == null) return Colors.grey;
    final now = DateTime.now();
    
    DateTime targetDateTime;
    if (timeStr != null) {
      final timeFormat = DateFormat('h:mm a');
      try {
        final parsedTime = timeFormat.parse(timeStr);
        targetDateTime = DateTime(date.year, date.month, date.day, parsedTime.hour, parsedTime.minute);
      } catch (_) {
        targetDateTime = DateTime(date.year, date.month, date.day);
      }
    } else {
      targetDateTime = DateTime(date.year, date.month, date.day, 23, 59);
    }

    final diff = targetDateTime.difference(now);
    if (diff.isNegative) return Colors.redAccent;

    if (timeStr != null) {
      if (diff.inHours < 3) return Colors.redAccent;
      return Colors.amber;
    } else {
      final today = DateTime(now.year, now.month, now.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      final daysDiff = targetDate.difference(today).inDays;
      if (daysDiff <= 0) {
        return Colors.amber;
      } else if (daysDiff <= 3) {
        return Colors.amber;
      } else {
        return Colors.greenAccent;
      }
    }
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) return;

    for (int i = 0; i < _subtasks.length; i++) {
      _subtasks[i] = _subtasks[i].copyWith(sortOrder: i);
    }

    final task =
        widget.existingTask?.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          category: _category,
          priority: _priority,
          dueDate: _dueDate,
          pinned: _pinned,
          manualProgress: _manualProgress,
          subtasks: _subtasks,
          updatedAt: DateTime.now(),
        ) ??
        TaskModel(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          category: _category,
          priority: _priority,
          dueDate: _dueDate,
          pinned: _pinned,
          manualProgress: _manualProgress,
          subtasks: _subtasks,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    if (widget.existingTask != null) {
      ref.read(tasksProvider.notifier).updateTask(task);
    } else {
      ref.read(tasksProvider.notifier).addTask(task);
    }

    Navigator.pop(context);
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  void _toggleSubtask(int index) {
    setState(() {
      final current = _subtasks[index];
      _subtasks[index] = current.copyWith(
        completed: !current.completed,
        completedAt: !current.completed ? DateTime.now() : null,
      );
      _sortSubtasks();
    });
  }

  Widget _buildSubtaskItem(int index) {
    final subtask = _subtasks[index];
    final dateStr = subtask.dueDate == null
        ? null
        : DateFormat('dd MMM').format(subtask.dueDate!);
    final countdown = _getCountdownString(subtask.dueDate, subtask.dueTime);
    final countdownColor = _getCountdownColor(subtask.dueDate, subtask.dueTime, subtask.completed);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: ValueKey(subtask.id),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : context.colors.textPrimary.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : context.colors.textPrimary.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ReorderableDragStartListener(
          index: index,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.drag_handle_rounded, color: context.colors.textMuted, size: 20),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _toggleSubtask(index);
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: subtask.completed 
                          ? Colors.greenAccent 
                          : (isDark ? Colors.white54 : context.colors.textMuted),
                      width: 1.5,
                    ),
                    color: subtask.completed
                        ? Colors.greenAccent.withValues(alpha: 0.2)
                        : Colors.transparent,
                  ),
                  child: subtask.completed
                      ? const Icon(Icons.check, size: 14, color: Colors.greenAccent)
                      : null,
                ),
              ),
            ],
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtask.title,
              style: GoogleFonts.outfit(
                color: subtask.completed 
                    ? (isDark ? Colors.white54 : context.colors.textMuted) 
                    : context.colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                decoration: subtask.completed ? TextDecoration.lineThrough : null,
              ),
            ),
            if (subtask.dueDate != null) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : context.colors.textPrimary.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 9, color: Colors.blueAccent),
                        const SizedBox(width: 3),
                        Text(
                          dateStr ?? '',
                          style: GoogleFonts.outfit(color: context.colors.textSecondary, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                  if (subtask.dueTime != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : context.colors.textPrimary.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded, size: 9, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text(
                            subtask.dueTime!,
                            style: GoogleFonts.outfit(color: context.colors.textSecondary, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: countdownColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      countdown,
                      style: GoogleFonts.outfit(
                        color: countdownColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_rounded, color: context.colors.textSecondary, size: 18),
              onPressed: () => _openSubtaskEditor(index: index),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
              onPressed: () => _removeSubtask(index),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtaskEditorCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : context.colors.textPrimary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _editingSubtaskIndex != null ? 'Edit Subtask' : 'New Subtask',
            style: GoogleFonts.outfit(
              color: context.colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subtaskTitleController,
            style: GoogleFonts.outfit(color: context.colors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'e.g. Design Landing Page',
              hintStyle: GoogleFonts.outfit(color: context.colors.textMuted),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : context.colors.textPrimary.withValues(alpha: 0.015),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _subtaskDueDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: isDark 
                              ? const ColorScheme.dark(
                                  primary: Color(0xFF3B82F6),
                                  onPrimary: Colors.white,
                                  surface: Color(0xFF131722),
                                  onSurface: Colors.white,
                                )
                              : ColorScheme.light(
                                  primary: const Color(0xFF3B82F6),
                                  onPrimary: Colors.white,
                                  surface: context.colors.bg2,
                                  onSurface: context.colors.textPrimary,
                                ),
                          dialogBackgroundColor: isDark 
                              ? const Color(0xFF131722)
                              : context.colors.bg2,
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) {
                      setState(() => _subtaskDueDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.03) : context.colors.textPrimary.withValues(alpha: 0.015),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : context.colors.textPrimary.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: Colors.blueAccent, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _subtaskDueDate == null
                                ? 'Target Date'
                                : DateFormat('dd MMM yyyy').format(_subtaskDueDate!),
                            style: GoogleFonts.outfit(
                              color: _subtaskDueDate == null ? context.colors.textMuted : context.colors.textPrimary,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: isDark 
                              ? const ColorScheme.dark(
                                  primary: Color(0xFF3B82F6),
                                  onPrimary: Colors.white,
                                  surface: Color(0xFF131722),
                                  onSurface: Colors.white,
                                )
                              : ColorScheme.light(
                                  primary: const Color(0xFF3B82F6),
                                  onPrimary: Colors.white,
                                  surface: context.colors.bg2,
                                  onSurface: context.colors.textPrimary,
                                ),
                          dialogBackgroundColor: isDark 
                              ? const Color(0xFF131722)
                              : context.colors.bg2,
                        ),
                        child: child!,
                      ),
                    );
                    if (time != null) {
                      setState(() => _subtaskDueTime = time.format(context));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.03) : context.colors.textPrimary.withValues(alpha: 0.015),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : context.colors.textPrimary.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: Colors.amber, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _subtaskDueTime ?? 'Target Time',
                            style: GoogleFonts.outfit(
                              color: _subtaskDueTime == null ? context.colors.textMuted : context.colors.textPrimary,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_subtaskDueTime != null)
                          GestureDetector(
                            onTap: () {
                              setState(() => _subtaskDueTime = null);
                            },
                            child: Icon(Icons.close_rounded, color: context.colors.textMuted, size: 14),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active_outlined, color: Colors.greenAccent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Notify me before deadline',
                    style: GoogleFonts.outfit(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _subtaskReminder,
                onChanged: (val) => setState(() => _subtaskReminder = val),
                activeColor: Colors.blueAccent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _cancelSubtaskEditor,
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(color: context.colors.textSecondary, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _saveSubtask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Save Subtask',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.82),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131722) : context.colors.bg2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 8, top: 16, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.existingTask != null ? 'Edit Task' : 'New Task',
                        style: GoogleFonts.outfit(
                          color: context.colors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _pinned
                              ? Icons.push_pin_rounded
                              : Icons.push_pin_outlined,
                          color: _pinned ? Colors.amber : context.colors.textMuted,
                        ),
                        onPressed: _isReadOnly ? null : () => setState(() => _pinned = !_pinned),
                      ),
                    ],
                  ),
                ),

                // Scrollable form content — keyboard-safe
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 8,
                      bottom: 20 + bottomInset,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AbsorbPointer(
                          absorbing: _isReadOnly,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Title ──
                              TextField(
                                controller: _titleController,
                                style: GoogleFonts.outfit(
                                  color: context.colors.textPrimary,
                                  fontSize: 15,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'What needs to be done? *',
                                  hintStyle: GoogleFonts.outfit(
                                    color: context.colors.textMuted,
                                    fontSize: 14,
                                  ),
                                  filled: true,
                                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : context.colors.textPrimary.withValues(alpha: 0.03),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // ── Description ──
                              TextField(
                                controller: _descController,
                                maxLines: 2,
                                style: GoogleFonts.outfit(
                                  color: context.colors.textPrimary,
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Description (optional)',
                                  hintStyle: GoogleFonts.outfit(
                                    color: context.colors.textMuted,
                                    fontSize: 13,
                                  ),
                                  filled: true,
                                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : context.colors.textPrimary.withValues(alpha: 0.03),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── Progress (only when no subtasks) ──
                              if (_subtasks.isEmpty) ...[
                                Text(
                                  'Progress',
                                  style: GoogleFonts.outfit(
                                    color: context.colors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                          activeTrackColor: const Color(0xFF3B82F6),
                                          inactiveTrackColor: isDark 
                                              ? Colors.white.withValues(alpha: 0.1)
                                              : context.colors.textPrimary.withValues(alpha: 0.1),
                                          thumbColor: context.colors.textPrimary,
                                          trackHeight: 4,
                                        ),
                                        child: Slider(
                                          value: _manualProgress,
                                          min: 0,
                                          max: 100,
                                          divisions: 100,
                                          onChanged: (value) =>
                                              setState(() => _manualProgress = value),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 48,
                                      child: Text(
                                        '${_manualProgress.toInt()}%',
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.outfit(
                                          color: context.colors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],

                              // ── Category ──
                              Text(
                                'Category',
                                style: GoogleFonts.outfit(
                                  color: context.colors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  ..._allCategories.map((c) {
                                    final isSelected = c == _category;
                                    return GestureDetector(
                                      onTap: () => setState(() => _category = c),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.blueAccent
                                              : (isDark ? Colors.white.withValues(alpha: 0.05) : context.colors.textPrimary.withValues(alpha: 0.03)),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          c,
                                          style: GoogleFonts.outfit(
                                            color: isSelected
                                                ? Colors.white
                                                : context.colors.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // ── Priority ──
                              Text(
                                'Priority',
                                style: GoogleFonts.outfit(
                                  color: context.colors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: TaskPriority.values.map((p) {
                                  final isSelected = p == _priority;
                                  final String label = p
                                      .toString()
                                      .split('.')
                                      .last
                                      .toUpperCase();
                                  Color pColor;
                                  if (p == TaskPriority.high)
                                    pColor = Colors.redAccent;
                                  else if (p == TaskPriority.medium)
                                    pColor = Colors.orangeAccent;
                                  else
                                    pColor = Colors.greenAccent;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _priority = p),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? pColor.withValues(alpha: 0.2)
                                              : (isDark ? Colors.white.withValues(alpha: 0.05) : context.colors.textPrimary.withValues(alpha: 0.03)),
                                          border: Border.all(
                                            color: isSelected
                                                ? pColor
                                                : Colors.transparent,
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            label,
                                            style: GoogleFonts.outfit(
                                              color: isSelected
                                                  ? pColor
                                                  : context.colors.textSecondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),

                              // ── Due Date ──
                              Text(
                                'Due Date',
                                style: GoogleFonts.outfit(
                                  color: context.colors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  final selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _dueDate ?? DateTime.now(),
                                    firstDate: DateTime.now().subtract(
                                      const Duration(days: 365),
                                    ),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 3650),
                                    ),
                                    builder: (context, child) => Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: isDark 
                                            ? const ColorScheme.dark(
                                                primary: Color(0xFF3B82F6),
                                                onPrimary: Colors.white,
                                                surface: Color(0xFF131722),
                                                onSurface: Colors.white,
                                              )
                                            : ColorScheme.light(
                                                primary: const Color(0xFF3B82F6),
                                                onPrimary: Colors.white,
                                                surface: context.colors.bg2,
                                                onSurface: context.colors.textPrimary,
                                              ),
                                        dialogBackgroundColor: isDark 
                                            ? const Color(0xFF131722)
                                            : context.colors.bg2,
                                      ),
                                      child: child!,
                                    ),
                                  );
                                  if (selectedDate != null)
                                    setState(() => _dueDate = selectedDate);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.05) : context.colors.textPrimary.withValues(alpha: 0.03),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        color: Color(0xFF3B82F6),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _dueDate != null
                                              ? DateFormat(
                                                  'EEEE, MMMM d, yyyy',
                                                ).format(_dueDate!)
                                              : 'No due date set (Optional)',
                                          style: GoogleFonts.outfit(
                                            color: _dueDate != null
                                                ? context.colors.textPrimary
                                                : context.colors.textMuted,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      if (_dueDate != null)
                                        GestureDetector(
                                          onTap: () =>
                                              setState(() => _dueDate = null),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: Icon(
                                              Icons.clear_rounded,
                                              color: context.colors.textSecondary,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // ── Subtasks Section ──
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtasks',
                                    style: GoogleFonts.outfit(
                                      color: context.colors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (_subtasks.isNotEmpty)
                                    Text(
                                      '${_subtasks.where((s) => s.completed).length}/${_subtasks.length} done',
                                      style: GoogleFonts.outfit(
                                        color: context.colors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_showSubtaskEditor) _buildSubtaskEditorCard(),

                              if (_subtasks.isEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Break your task into smaller achievable steps.',
                                    style: GoogleFonts.outfit(
                                      color: context.colors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ] else
                                ReorderableListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _subtasks.length,
                                  itemBuilder: (context, index) => _buildSubtaskItem(index),
                                  onReorder: (oldIndex, newIndex) {
                                    setState(() {
                                      if (newIndex > oldIndex) {
                                        newIndex -= 1;
                                      }
                                      final item = _subtasks.removeAt(oldIndex);
                                      _subtasks.insert(newIndex, item);
                                      for (int i = 0; i < _subtasks.length; i++) {
                                        _subtasks[i] = _subtasks[i].copyWith(sortOrder: i);
                                      }
                                    });
                                  },
                                ),

                              const SizedBox(height: 8),
                              if (!_showSubtaskEditor)
                                SizedBox(
                                  width: double.infinity,
                                  height: 38,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _openSubtaskEditor(),
                                    icon: Icon(
                                      Icons.add,
                                      color: context.colors.textPrimary,
                                      size: 16,
                                    ),
                                    label: Text(
                                      'Add Subtask',
                                      style: GoogleFonts.outfit(
                                        color: context.colors.textPrimary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: isDark 
                                            ? Colors.white.withValues(alpha: 0.2) 
                                            : context.colors.textPrimary.withValues(alpha: 0.15),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // ── Save / Delete (or Preview Warning for Guest) ──
                        if (_isReadOnly) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                width: 0.8,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline_rounded,
                                      color: Color(0xFFF59E0B),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'This task is in Preview Mode. Sign in to edit or manage your own tasks.',
                                        style: GoogleFonts.outfit(
                                          color: context.colors.textSecondary,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    PremiumAuthSheet.show(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF59E0B),
                                    foregroundColor: Colors.white,
                                    fixedSize: const Size.fromHeight(44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Create My Workspace',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _saveTask,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'Save Task',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (widget.existingTask != null) ...[
                              const SizedBox(height: 6),
                              SizedBox(
                                width: double.infinity,
                                height: 34,
                                child: TextButton(
                                  onPressed: () {
                                    ref
                                        .read(tasksProvider.notifier)
                                        .deleteTask(widget.existingTask!.id);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Delete Task',
                                    style: GoogleFonts.outfit(
                                      color: Colors.redAccent,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
}
