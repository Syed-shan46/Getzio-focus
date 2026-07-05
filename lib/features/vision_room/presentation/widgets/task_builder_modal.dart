import 'dart:ui';
import 'dart:async';
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
  final _subtaskController = TextEditingController();
  final List<String> _subtasks = [];
  
  String _priority = 'High';
  double _progress = 0;
  DateTime? _dueDate;
  
  int _tasksAddedCount = 0;
  bool _showFeedback = false;
  Timer? _feedbackTimer;

  @override
  void dispose() {
    _titleController.dispose();
    _subtaskController.dispose();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _triggerFeedback() {
    _feedbackTimer?.cancel();
    setState(() {
      _showFeedback = true;
    });
    _feedbackTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
        });
      }
    });
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasks.add(text);
        _subtaskController.clear();
      });
    }
  }

  void _submit() {
    final titleText = _titleController.text.trim();
    if (titleText.isEmpty) {
      if (_tasksAddedCount > 0) {
        Navigator.pop(context);
      }
      return;
    }
    
    // Automatically add draft subtask text if any
    final draftSubtask = _subtaskController.text.trim();
    if (draftSubtask.isNotEmpty) {
      _subtasks.add(draftSubtask);
      _subtaskController.clear();
    }

    widget.onSubmit({
      'title': titleText,
      'priority': _priority,
      'progress': _progress,
      'dueDate': _dueDate?.toIso8601String(),
      'isOnShelf': false,
      'checklist': _subtasks.asMap().entries.map((entry) => {
        'id': '${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
        'title': entry.value,
        'isCompleted': false,
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
              // Sliding drawer handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              
              // Title with optional task counter
              Text(
                _tasksAddedCount > 0 
                    ? 'Create Task ($_tasksAddedCount added)'
                    : 'Create Task', 
                style: AppTypography.displayMedium(color: Colors.white).copyWith(fontSize: 22), 
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Animated feedback banner
              AnimatedCrossAxis(
                show: _showFeedback,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Task added to vision board!',
                        style: TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

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
              const SizedBox(height: 20),
              
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
              const SizedBox(height: 20),

              // Subtasks input row
              Text('Subtasks / Checklist', style: AppTypography.caption(color: Colors.white54)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      style: AppTypography.bodyMedium(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add subtask (e.g. Design mockups)...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => _addSubtask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: context.colors.accentBlue,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    onPressed: _addSubtask,
                  ),
                ],
              ),

              // Checklist Section (only showing if not empty)
              if (_subtasks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: _subtasks.map((st) {
                      final idx = _subtasks.indexOf(st);
                      return Padding(
                        padding: EdgeInsets.only(bottom: idx == _subtasks.length - 1 ? 0 : 8),
                        child: Row(
                          children: [
                            const Icon(Icons.circle_outlined, color: Colors.white30, size: 14),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                st,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 16),
                              onPressed: () => setState(() => _subtasks.removeAt(idx)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final titleText = _titleController.text.trim();
                        if (titleText.isEmpty) return;

                        // Automatically add draft subtask text if any
                        final draftSubtask = _subtaskController.text.trim();
                        if (draftSubtask.isNotEmpty) {
                          _subtasks.add(draftSubtask);
                          _subtaskController.clear();
                        }

                        widget.onSubmit({
                          'title': titleText,
                          'priority': _priority,
                          'progress': _progress,
                          'dueDate': _dueDate?.toIso8601String(),
                          'isOnShelf': false,
                          'checklist': _subtasks.asMap().entries.map((entry) => {
                            'id': '${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
                            'title': entry.value,
                            'isCompleted': false,
                          }).toList(),
                        });
                        
                        _triggerFeedback();
                        setState(() {
                          _tasksAddedCount++;
                          _titleController.clear();
                          _subtasks.clear();
                          _priority = 'High';
                          _progress = 0;
                          _dueDate = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.colors.accentBlue, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Add More', style: AppTypography.titleMedium(color: context.colors.accentBlue)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.accentBlue,
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

class AnimatedCrossAxis extends StatelessWidget {
  final bool show;
  final Widget child;

  const AnimatedCrossAxis({super.key, required this.show, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: child,
      secondChild: const SizedBox.shrink(),
      crossFadeState: show ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 250),
    );
  }
}
