import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/task_model.dart';
import '../providers/tasks_provider.dart';

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

  final List<String> _categories = [
    'Personal', 'Work', 'Business', 'Study', 'Health', 
    'Fitness', 'Finance', 'Shopping', 'Custom'
  ];

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _category = task?.category ?? 'Personal';
    _priority = task?.priority ?? TaskPriority.medium;
    _dueDate = task?.dueDate;
    _pinned = task?.pinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) return;

    final task = widget.existingTask?.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          category: _category,
          priority: _priority,
          dueDate: _dueDate,
          pinned: _pinned,
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
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 24),
                  
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
                  const SizedBox(height: 32),

                  // Save Button
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
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
      ),
    );
  }
}
