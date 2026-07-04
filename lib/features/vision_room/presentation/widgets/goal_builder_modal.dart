import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'due_date_progress_selector.dart';

class GoalBuilderModal extends StatefulWidget {
  final Function(Map<String, dynamic> metadata) onSubmit;

  const GoalBuilderModal({super.key, required this.onSubmit});

  static void show(BuildContext context, {required Function(Map<String, dynamic> metadata) onSubmit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalBuilderModal(onSubmit: onSubmit),
    );
  }

  @override
  State<GoalBuilderModal> createState() => _GoalBuilderModalState();
}

class _GoalBuilderModalState extends State<GoalBuilderModal> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  double _progress = 0;
  DateTime? _dueDate;
  String _priority = 'Medium';
  Color _selectedColor = Colors.blueAccent;
  final List<TextEditingController> _milestoneControllers = [
    TextEditingController(),
  ];

  final List<Color> _themeColors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _milestoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    final milestones = _milestoneControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    widget.onSubmit({
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'progress': _progress,
      'dueDate': _dueDate?.toIso8601String(),
      'priority': _priority,
      'color': _selectedColor.toARGB32(),
      'isOnShelf': false,
      'milestones': milestones.asMap().entries.map((entry) {
        final i = entry.key;
        final title = entry.value;
        return {
          'id': 'milestone_${DateTime.now().millisecondsSinceEpoch}_$i',
          'title': title,
          'description': '',
          'isCompleted': false,
          'order': i,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'subtasks': <dynamic>[],
        };
      }).toList(),
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
              Text(
                'Create Goal Card',
                style: AppTypography.displayMedium(color: Colors.white).copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Title Field
              TextField(
                controller: _titleController,
                style: AppTypography.titleMedium(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Goal Title (e.g. Launch Startup)',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                style: AppTypography.bodyMedium(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Description or Motivation',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),

              // Due Date & Progress Selector
              DueDateAndProgressSelector(
                selectedDate: _dueDate,
                currentProgress: _progress,
                accentColor: _selectedColor,
                onDateChanged: (d) => setState(() => _dueDate = d),
                onProgressChanged: (p) => setState(() => _progress = p),
              ),
              const SizedBox(height: 20),

              // Priority
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
                        color: isSelected ? _selectedColor.withValues(alpha: 0.2) : Colors.transparent,
                        border: Border.all(color: isSelected ? _selectedColor : Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(p, style: AppTypography.bodyMedium(color: isSelected ? _selectedColor : Colors.white70)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Milestones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Milestones', style: AppTypography.caption(color: Colors.white54)),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _milestoneControllers.add(TextEditingController());
                      });
                    },
                    icon: Icon(Icons.add_rounded, size: 16, color: _selectedColor),
                    label: Text(
                      'Add',
                      style: TextStyle(
                        color: _selectedColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._milestoneControllers.asMap().entries.map((entry) {
                final idx = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: AppTypography.bodyMedium(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Milestone ${idx + 1} (e.g. Design Prototype)',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                            filled: true,
                            fillColor: Colors.black.withValues(alpha: 0.25),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      if (_milestoneControllers.length > 1) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _milestoneControllers.removeAt(idx);
                              controller.dispose();
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Color Theme
              Text('Color Theme', style: AppTypography.caption(color: Colors.white54)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _themeColors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),



              // Submit
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Add Goal to Board', style: AppTypography.titleMedium(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
