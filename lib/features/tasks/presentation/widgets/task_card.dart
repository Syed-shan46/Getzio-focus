import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../domain/models/task_model.dart';
import '../providers/tasks_provider.dart';
import 'package:getzio_todo_app/core/theme/app_theme.dart';

class TaskCard extends ConsumerStatefulWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final Function(bool?) onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
  });

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _expanded = false;

  String _getCountdownText(SubtaskModel subtask) {
    if (subtask.dueDate == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      subtask.dueDate!.year,
      subtask.dueDate!.month,
      subtask.dueDate!.day,
    );

    DateTime? targetDateTime;
    if (subtask.dueTime != null) {
      try {
        final timeFormat = DateFormat('h:mm a');
        final time = timeFormat.parse(subtask.dueTime!);
        targetDateTime = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          time.hour,
          time.minute,
        );
      } catch (e) {
        targetDateTime = targetDate;
      }
    } else {
      targetDateTime = targetDate;
    }

    if (subtask.completed) return 'Completed';

    if (targetDate.isBefore(today)) {
      final diff = today.difference(targetDate).inDays;
      return diff == 1 ? 'Overdue by 1 Day' : 'Overdue by $diff Days';
    } else if (targetDate.isAtSameMomentAs(today)) {
      if (targetDateTime != targetDate) {
        final diff = targetDateTime.difference(now);
        if (diff.isNegative) {
          return 'Overdue by ${diff.inHours.abs()}h ${diff.inMinutes.abs() % 60}m';
        } else if (diff.inHours > 0) {
          return '${diff.inHours}h ${diff.inMinutes % 60}m left';
        } else {
          return '${diff.inMinutes} mins left';
        }
      }
      return 'Today';
    } else if (targetDate.isAtSameMomentAs(
      today.add(const Duration(days: 1)),
    )) {
      return 'Tomorrow';
    } else {
      final diff = targetDate.difference(today).inDays;
      return '$diff Days Left';
    }
  }

  Color _getCountdownColor(SubtaskModel subtask) {
    if (subtask.completed) return Colors.grey;
    if (subtask.dueDate == null) return Colors.white54;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      subtask.dueDate!.year,
      subtask.dueDate!.month,
      subtask.dueDate!.day,
    );

    DateTime? targetDateTime;
    if (subtask.dueTime != null) {
      try {
        final timeFormat = DateFormat('h:mm a');
        final time = timeFormat.parse(subtask.dueTime!);
        targetDateTime = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          time.hour,
          time.minute,
        );
      } catch (e) {
        targetDateTime = targetDate;
      }
    } else {
      targetDateTime = targetDate;
    }

    if (targetDate.isBefore(today)) return Colors.redAccent;
    if (targetDate.isAtSameMomentAs(today)) {
      if (targetDateTime != targetDate) {
        final diff = targetDateTime.difference(now);
        if (diff.isNegative) return Colors.redAccent;
        if (diff.inHours < 3) return Colors.redAccent;
      }
      return Colors.amber;
    }
    final diff = targetDate.difference(today).inDays;
    if (diff > 3) return Colors.greenAccent;
    return Colors.white70;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return const Color(0xFF8B5CF6); // Purple
      case 'personal':
        return const Color(0xFF10B981); // Green
      case 'learning':
      case 'study':
        return const Color(0xFF3B82F6); // Blue
      case 'vision room':
        return const Color(0xFFA855F7); // Violet
      case 'affirmations':
        return const Color(0xFFEC4899); // Pink
      case 'goals':
        return const Color(0xFFF59E0B); // Amber
      case 'productivity':
        return const Color(0xFF6366F1); // Indigo
      case 'finance':
        return const Color(0xFF14B8A6); // Teal
      case 'health':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFFF97316); // Orange
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.effectiveCompleted;
    final categoryColor = _getCategoryColor(widget.task.category);

    return GestureDetector(
      onTap: () {
        debugPrint(
          "TaskCard: Outer card tapped! subtasks count: ${widget.task.subtasks.length}",
        );
        if (widget.task.subtasks.isNotEmpty) {
          HapticFeedback.selectionClick();
          setState(() {
            _expanded = !_expanded;
          });
        } else {
          HapticFeedback.lightImpact();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.colors.bg2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.textPrimary.withValues(alpha: 0.04),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Left Colored Strip
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: categoryColor),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main Content Row
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checkbox
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            widget.onToggleComplete(!isCompleted);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 2, right: 10),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isCompleted
                                    ? Colors.amber
                                    : Colors.white24,
                                width: 1.5,
                              ),
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.amber,
                                  )
                                : null,
                          ),
                        ),

                        // Text Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.task.title,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Badges & Time Row
                              Row(
                                children: [
                                  // Category Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      widget.task.category,
                                      style: GoogleFonts.outfit(
                                        color: categoryColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Due Date
                                  if (widget.task.dueDate != null) ...[
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      size: 10,
                                      color: Colors.white54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${DateFormat('MMM d').format(widget.task.dueDate!)}${widget.task.dueTime != null ? ', ${widget.task.dueTime}' : ''}',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],

                                  // Estimated Duration
                                  if (widget.task.estimatedMinutes != null) ...[
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 10,
                                      color: Colors.white54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.task.estimatedMinutes}m',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Bottom Row (Checklist & Priority)
                              Row(
                                children: [
                                  if (widget.task.subtasks.isNotEmpty) ...[
                                    const Icon(
                                      Icons.check_box_outlined,
                                      size: 14,
                                      color: Colors.white54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.task.subtasks.where((c) => c.completed).length}/${widget.task.subtasks.length}',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '•',
                                        style: TextStyle(color: Colors.white24),
                                      ),
                                    ),
                                  ],

                                  if (widget.task.priority ==
                                      TaskPriority.high) ...[
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'High Priority',
                                      style: GoogleFonts.outfit(
                                        color: Colors.redAccent,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Right Icons Column
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    debugPrint("TaskCard: Star icon tapped!");
                                    HapticFeedback.lightImpact();
                                    ref
                                        .read(tasksProvider.notifier)
                                        .updateTask(
                                          widget.task.copyWith(
                                            pinned: !widget.task.pinned,
                                          ),
                                        );
                                  },
                                  child: Icon(
                                    widget.task.pinned
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: widget.task.pinned
                                        ? Colors.amber
                                        : Colors.white54,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    debugPrint("TaskCard: Edit icon tapped!");
                                    HapticFeedback.lightImpact();
                                    widget.onTap();
                                  },
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white54,
                                    size: 18,
                                  ),
                                ),
                                if (widget.task.subtasks.isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _expanded = !_expanded;
                                      });
                                    },
                                    child: AnimatedRotation(
                                      turns: _expanded ? 0.5 : 0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                            Icon(
                              Icons.alarm,
                              color: categoryColor.withValues(alpha: 0.8),
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Subtask Panel
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: _expanded && widget.task.subtasks.isNotEmpty
                        ? _buildSubtaskPanel(context, categoryColor)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtaskPanel(BuildContext context, Color categoryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 42, right: 16, bottom: 12, top: 4),
      child: Column(
        children: widget.task.subtasks.asMap().entries.map((entry) {
          final idx = entry.key;
          final subtask = entry.value;
          final isLast = idx == widget.task.subtasks.length - 1;
          final countdown = _getCountdownText(subtask);
          final color = _getCountdownColor(subtask);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          final updatedSubtasks = List<SubtaskModel>.from(
                            widget.task.subtasks,
                          );
                          updatedSubtasks[idx] = subtask.copyWith(
                            completed: !subtask.completed,
                          );
                          ref
                              .read(tasksProvider.notifier)
                              .updateTask(
                                widget.task.copyWith(subtasks: updatedSubtasks),
                              );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: subtask.completed
                                ? Colors.amber.withValues(alpha: 0.1)
                                : Colors.transparent,
                            border: Border.all(
                              color: subtask.completed
                                  ? Colors.amber
                                  : Colors.white24,
                              width: 1.5,
                            ),
                          ),
                          child: subtask.completed
                              ? const Center(
                                  child: Icon(
                                    Icons.check,
                                    size: 10,
                                    color: Colors.amber,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          final updatedSubtasks = List<SubtaskModel>.from(
                            widget.task.subtasks,
                          );
                          updatedSubtasks[idx] = subtask.copyWith(
                            completed: !subtask.completed,
                          );
                          ref
                              .read(tasksProvider.notifier)
                              .updateTask(
                                widget.task.copyWith(subtasks: updatedSubtasks),
                              );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: GoogleFonts.outfit(
                                color: subtask.completed
                                    ? Colors.white30
                                    : Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                decoration: subtask.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: Colors.white24,
                              ),
                              child: Text('• ${subtask.title}'),
                            ),
                            if (countdown.isNotEmpty && !subtask.completed)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  countdown,
                                  style: GoogleFonts.outfit(
                                    color: color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  color: Colors.white.withValues(alpha: 0.05),
                  height: 1,
                  thickness: 1,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
