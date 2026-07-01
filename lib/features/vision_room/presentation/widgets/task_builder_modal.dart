import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'due_date_progress_selector.dart';

class TaskBuilderModal extends StatefulWidget {
  final Function(Map<String, dynamic> metadata) onSubmit;

  const TaskBuilderModal({super.key, required this.onSubmit});

  static void show(BuildContext context, {required Function(Map<String, dynamic> metadata) onSubmit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskBuilderModal(onSubmit: onSubmit),
    );
  }

  @override
  State<TaskBuilderModal> createState() => _TaskBuilderModalState();
}

class _TaskBuilderModalState extends State<TaskBuilderModal> {
  final _titleController = TextEditingController();
  String _priority = 'High';
  double _progress = 0;
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool _addToShelf = false;

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    widget.onSubmit({
      'title': _titleController.text.trim(),
      'priority': _priority,
      'progress': _progress,
      'dueDate': _dueDate?.toIso8601String(),
      'isOnShelf': _addToShelf,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Create Task', style: AppTypography.displayMedium(color: Colors.white).copyWith(fontSize: 24), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              TextField(
                controller: _titleController,
                style: AppTypography.titleMedium(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Task Title',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Text('Priority', style: AppTypography.caption(color: Colors.white54)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['Low', 'Medium', 'High'].map((p) {
                  final isSelected = p == _priority;
                  return GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orangeAccent.withValues(alpha: 0.2) : Colors.transparent,
                        border: Border.all(color: isSelected ? Colors.orangeAccent : Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(p, style: AppTypography.bodyMedium(color: isSelected ? Colors.orangeAccent : Colors.white70)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              DueDateAndProgressSelector(
                selectedDate: _dueDate,
                currentProgress: _progress,
                accentColor: Colors.orangeAccent,
                onDateChanged: (d) => setState(() => _dueDate = d),
                onProgressChanged: (p) => setState(() => _progress = p),
              ),
              const SizedBox(height: 24),

              // Add to Shelf Option
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.archive_outlined, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Add to Wooden Shelf',
                        style: AppTypography.titleMedium(color: Colors.white70).copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                  Switch(
                    value: _addToShelf,
                    activeColor: Colors.orangeAccent,
                    onChanged: (val) => setState(() => _addToShelf = val),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (_titleController.text.trim().isEmpty) return;
                        widget.onSubmit({
                          'title': _titleController.text.trim(),
                          'priority': _priority,
                          'progress': _progress,
                          'dueDate': _dueDate?.toIso8601String(),
                          'isOnShelf': _addToShelf,
                        });
                        // Reset form for next task, keep _addToShelf preference
                        setState(() {
                          _titleController.clear();
                          _priority = 'High';
                          _progress = 0;
                          _dueDate = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.accentBlue, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Add More', style: AppTypography.titleMedium(color: AppColors.accentBlue)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Done', style: AppTypography.titleMedium(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
