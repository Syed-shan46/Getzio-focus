import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../domain/models/task_model.dart';

class TaskCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isCompleted = task.effectiveCompleted;
    final isOverdue = task.status == TaskStatus.overdue && !isCompleted;

    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = Colors.redAccent;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.orangeAccent;
        break;
      case TaskPriority.low:
        priorityColor = Colors.greenAccent;
        break;
    }

    final double progressPercent = task.effectiveProgress / 100.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? Colors.green.withValues(alpha: 0.3)
                : isOverdue
                    ? Colors.red.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onToggleComplete(!isCompleted);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 2, right: 12),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? Colors.greenAccent : Colors.white54,
                          width: 1.5,
                        ),
                        color: isCompleted ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.transparent,
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.greenAccent)
                          : null,
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (task.pinned) ...[
                              const Icon(Icons.push_pin_rounded, size: 14, color: Colors.amber),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                task.title,
                                style: GoogleFonts.outfit(
                                  color: isCompleted ? Colors.white54 : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: priorityColor,
                              ),
                            ),
                          ],
                        ),
                        
                        if (task.category.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            task.category,
                            style: GoogleFonts.outfit(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],

                        // Progress Bar Section
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progressPercent,
                                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isCompleted ? Colors.greenAccent : const Color(0xFF3B82F6),
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${task.effectiveProgress.toInt()}%',
                              style: GoogleFonts.outfit(
                                color: isCompleted ? Colors.greenAccent : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Bottom row: Due Date, Subtasks, Duration
                        Row(
                          children: [
                            if (task.dueDate != null) ...[
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: isOverdue ? Colors.redAccent : Colors.white54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${DateFormat('MMM d').format(task.dueDate!)}${task.dueTime != null ? ', ${task.dueTime}' : ''}',
                                style: GoogleFonts.outfit(
                                  color: isOverdue ? Colors.redAccent : Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            
                            if (task.subtasks.isNotEmpty) ...[
                              const Icon(Icons.account_tree_rounded, size: 14, color: Colors.white54),
                              const SizedBox(width: 4),
                              Text(
                                '${task.subtasks.where((c) => c.completed).length} / ${task.subtasks.length} Completed',
                                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11),
                              ),
                              const SizedBox(width: 12),
                            ],
                            
                            if (task.estimatedMinutes != null) ...[
                              const Icon(Icons.timer_outlined, size: 14, color: Colors.white54),
                              const SizedBox(width: 4),
                              Text(
                                '${task.estimatedMinutes}m',
                                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
