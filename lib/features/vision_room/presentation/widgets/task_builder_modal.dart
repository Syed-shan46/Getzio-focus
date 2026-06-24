import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    widget.onSubmit({
      'title': _titleController.text.trim(),
      'priority': _priority,
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Add Task', style: AppTypography.titleMedium(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
