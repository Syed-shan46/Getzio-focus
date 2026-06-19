import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/todo_model.dart';
import '../providers/todo_providers.dart';
import 'animated_checkbox.dart';

/// Premium glassmorphism task card with expandable subtasks.
class TaskCard extends ConsumerStatefulWidget {
  final TodoModel todo;
  final int index;

  const TaskCard({super.key, required this.todo, required this.index});

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (widget.index * 60).clamp(0, 200)),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todo = widget.todo;
    final completedSubs = todo.completedSubtaskCount;
    final totalSubs = todo.totalSubtaskCount;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dismissible(
          key: Key(todo.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error.withValues(alpha: 0.8),
              size: 24,
            ),
          ),
          onDismissed: (_) {
            HapticFeedback.mediumImpact();
            ref.read(todosProvider.notifier).deleteTodo(todo.id);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  decoration: GlassDecoration.card(),
                  child: Column(
                    children: [
                      // ── Main Row ──
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _expanded = !_expanded);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Checkbox
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: AnimatedCheckbox(
                                  checked: todo.isCompleted,
                                  onChanged: (_) {
                                    ref
                                        .read(todosProvider.notifier)
                                        .toggleTodo(todo.id);
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),

                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      style: AppTypography.titleMedium(
                                        color: todo.isCompleted
                                            ? AppColors.textMuted
                                            : AppColors.textPrimary,
                                      ).copyWith(
                                        decoration: todo.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        decorationColor: AppColors.textMuted,
                                      ),
                                      child: Text(todo.title),
                                    ),

                                    // Subtask count
                                    if (totalSubs > 0) ...[
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        '$totalSubs subtask${totalSubs == 1 ? '' : 's'} · $completedSubs completed',
                                        style: AppTypography.caption(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Expand indicator
                              AnimatedRotation(
                                turns: _expanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 250),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: totalSubs > 0
                                      ? AppColors.textMuted
                                      : AppColors.textMuted.withValues(alpha: 0.3),
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Expanded Subtasks ──
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: _expanded
                            ? _buildSubtaskPanel(todo)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtaskPanel(TodoModel todo) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtask list
          ...todo.subTodos.map((sub) => _buildSubtaskRow(todo.id, sub)),

          // Add subtask
          const SizedBox(height: AppSpacing.xs),
          _AddSubtaskInput(
            onSubmit: (title) {
              ref.read(todosProvider.notifier).addSubTodo(todo.id, title);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubtaskRow(String todoId, SubTodoModel sub) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AnimatedCheckbox(
            checked: sub.isCompleted,
            size: 20,
            onChanged: (_) {
              ref.read(todosProvider.notifier).toggleSubTodo(todoId, sub.id);
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.bodyMedium(
                color: sub.isCompleted
                    ? AppColors.textMuted
                    : AppColors.textSecondary,
              ).copyWith(
                decoration:
                    sub.isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.textMuted,
              ),
              child: Text(sub.title),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(todosProvider.notifier).deleteSubTodo(todoId, sub.id);
            },
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Inline Add Subtask Input ─────────────────────────────────────────────

class _AddSubtaskInput extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  const _AddSubtaskInput({required this.onSubmit});

  @override
  State<_AddSubtaskInput> createState() => _AddSubtaskInputState();
}

class _AddSubtaskInputState extends State<_AddSubtaskInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSubmit(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.add_rounded, size: 18, color: AppColors.accentBlue),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: TextField(
            controller: _controller,
            style: AppTypography.bodyMedium(color: AppColors.textSecondary),
            decoration: InputDecoration(
              hintText: 'Add subtask...',
              hintStyle: AppTypography.bodyMedium(color: AppColors.textMuted),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
      ],
    );
  }
}
