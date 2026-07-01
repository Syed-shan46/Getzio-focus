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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return const Color(0xFF8B5CF6); // Purple
      case 'personal':
        return const Color(0xFF10B981); // Green
      case 'learning':
      case 'study':
        return const Color(0xFF3B82F6); // Blue
      default:
        return const Color(0xFFF97316); // Orange
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.effectiveCompleted;
    final categoryColor = _getCategoryColor(task.category);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF131722),
          borderRadius: BorderRadius.circular(16),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Colored Strip
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              
              // Main Content
              Expanded(
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
                          margin: const EdgeInsets.only(top: 2, right: 16),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted ? Colors.amber : Colors.white24,
                              width: 1.5,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check, size: 18, color: Colors.amber)
                              : null,
                        ),
                      ),
                      
                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // Badges & Time Row
                            Row(
                              children: [
                                // Category Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    task.category,
                                    style: GoogleFonts.outfit(
                                      color: categoryColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Due Date
                                if (task.dueDate != null) ...[
                                  const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white54),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${DateFormat('MMM d').format(task.dueDate!)}${task.dueTime != null ? ', ${task.dueTime}' : ''}',
                                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                
                                // Estimated Duration
                                if (task.estimatedMinutes != null) ...[
                                  const Icon(Icons.access_time_rounded, size: 12, color: Colors.white54),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${task.estimatedMinutes}m',
                                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ],
                            ),
                            
                            const SizedBox(height: 10),
                            
                            // Bottom Row (Checklist & Priority)
                            Row(
                              children: [
                                if (task.subtasks.isNotEmpty) ...[
                                  const Icon(Icons.check_box_outlined, size: 14, color: Colors.white54),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${task.subtasks.where((c) => c.completed).length}/${task.subtasks.length}',
                                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('•', style: TextStyle(color: Colors.white24)),
                                  ),
                                ],
                                
                                if (task.priority == TaskPriority.high) ...[
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
                                    style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 12),
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
                              Icon(
                                task.pinned ? Icons.star_rounded : Icons.star_border_rounded,
                                color: task.pinned ? Colors.amber : Colors.white54,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.more_horiz_rounded, color: Colors.white54, size: 20),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
