import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../domain/models/task_model.dart';
import '../providers/tasks_provider.dart';

class TaskBottomSheet extends ConsumerStatefulWidget {
  final TaskModel? existingTask;

  const TaskBottomSheet({super.key, this.existingTask});

  @override
  ConsumerState<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends ConsumerState<TaskBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _category;
  late TaskPriority _priority;
  DateTime? _dueDate;
  bool _pinned = false;
  double _manualProgress = 0;
  List<SubtaskModel> _subtasks = [];

  final List<String> _categories = [
    'Personal', 'Work', 'Business', 'Study', 'Health', 
    'Fitness', 'Finance', 'Shopping', 'Custom'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
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
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) return;

    // Fix sort order before saving
    for (int i = 0; i < _subtasks.length; i++) {
      _subtasks[i] = _subtasks[i].copyWith(sortOrder: i);
    }

    final task = widget.existingTask?.copyWith(
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

  void _addSubtask() {
    setState(() {
      _subtasks.add(SubtaskModel(
        id: const Uuid().v4(),
        title: 'New Subtask',
        sortOrder: _subtasks.length,
      ));
    });
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
    });
  }

  void _updateSubtaskTitle(int index, String newTitle) {
    setState(() {
      _subtasks[index] = _subtasks[index].copyWith(title: newTitle);
    });
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          TextField(
            controller: _titleController,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'What needs to be done? *',
              hintStyle: GoogleFonts.outfit(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: _descController,
            maxLines: 2,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Description (optional)',
              hintStyle: GoogleFonts.outfit(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Conditional Progress Slider
          if (_subtasks.isEmpty) ...[
            Text(
              'Progress',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color(0xFF3B82F6),
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                      thumbColor: Colors.white,
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _manualProgress,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (value) {
                        setState(() {
                          _manualProgress = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${_manualProgress.toInt()}%',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Category
          Text(
            'Category',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((c) {
              final isSelected = c == _category;
              return GestureDetector(
                onTap: () => setState(() => _category = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blueAccent : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    c,
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Priority
          Text(
            'Priority',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: TaskPriority.values.map((p) {
              final isSelected = p == _priority;
              final String label = p.toString().split('.').last.toUpperCase();
              Color pColor;
              if (p == TaskPriority.high) pColor = Colors.redAccent;
              else if (p == TaskPriority.medium) pColor = Colors.orangeAccent;
              else pColor = Colors.greenAccent;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? pColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                      border: Border.all(
                        color: isSelected ? pColor : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: GoogleFonts.outfit(
                          color: isSelected ? pColor : Colors.white70,
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
        ],
      ),
    );
  }

  Widget _buildSubtasksTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        if (_subtasks.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'No subtasks yet.\nBreak your task into smaller steps.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white38),
              ),
            ),
          )
        else
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _subtasks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _subtasks.removeAt(oldIndex);
                  _subtasks.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final subtask = _subtasks[index];
                return Container(
                  key: ValueKey(subtask.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _toggleSubtask(index);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: subtask.completed ? Colors.greenAccent : Colors.white54,
                            width: 1.5,
                          ),
                          color: subtask.completed ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.transparent,
                        ),
                        child: subtask.completed
                            ? const Icon(Icons.check, size: 16, color: Colors.greenAccent)
                            : null,
                      ),
                    ),
                    title: TextFormField(
                      initialValue: subtask.title,
                      style: GoogleFonts.outfit(
                        color: subtask.completed ? Colors.white54 : Colors.white,
                        decoration: subtask.completed ? TextDecoration.lineThrough : null,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) => _updateSubtaskTitle(index, val),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => _removeSubtask(index),
                        ),
                        ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle, color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        
        // Add Subtask Button
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _addSubtask,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Subtask',
                style: GoogleFonts.outfit(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF131722),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.existingTask != null ? 'Edit Task' : 'New Task',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                        color: _pinned ? Colors.amber : Colors.white54,
                      ),
                      onPressed: () {
                        setState(() => _pinned = !_pinned);
                      },
                    ),
                  ],
                ),
                
                // Tabs
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF3B82F6),
                  labelColor: const Color(0xFF3B82F6),
                  unselectedLabelColor: Colors.white54,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Subtasks'),
                  ],
                ),
                
                // Tab Views
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildSubtasksTab(),
                    ],
                  ),
                ),
                
                // Save/Delete Buttons
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: TextButton(
                      onPressed: () {
                        ref.read(tasksProvider.notifier).deleteTask(widget.existingTask!.id);
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
            ),
          ),
        ),
      ),
    );
  }
}
