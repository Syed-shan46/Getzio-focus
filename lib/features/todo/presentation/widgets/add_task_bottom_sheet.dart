
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/todo_providers.dart';

/// Premium glassmorphism bottom sheet for adding tasks.
class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _titleController = TextEditingController();
  final _subtaskControllers = <TextEditingController>[];
  final _titleFocus = FocusNode();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _addSubtaskField();
    Future.microtask(() => _titleFocus.requestFocus());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocus.dispose();
    for (var c in _subtaskControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addSubtaskField() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _removeSubtaskField(int index) {
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    final subtasks = _subtaskControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    await ref.read(todosProvider.notifier).addTodo(
          title: title,
          subtaskTitles: subtasks,
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
        child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(15, 20, 35, 0.85),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
              border: Border.all(color: AppColors.glassBorder, width: 0.5),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppColors.glassBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title
                  Text('New Task', style: AppTypography.titleLarge()),
                  const SizedBox(height: AppSpacing.lg),

                  // Task title field
                  _buildTextField(
                    controller: _titleController,
                    focusNode: _titleFocus,
                    hint: 'What needs to be done?',
                    style: AppTypography.bodyLarge(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Subtasks section
                  Text(
                    'SUBTASKS',
                    style: AppTypography.captionSmall(
                      color: AppColors.textMuted,
                    ).copyWith(letterSpacing: 1.2),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Subtask fields
                  ...List.generate(_subtaskControllers.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.glassBorder,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _buildTextField(
                              controller: _subtaskControllers[i],
                              hint: 'Subtask ${i + 1}',
                              style: AppTypography.bodyMedium(
                                color: AppColors.textSecondary,
                              ),
                              onSubmitted: (_) {
                                if (i == _subtaskControllers.length - 1) {
                                  _addSubtaskField();
                                }
                              },
                            ),
                          ),
                          if (_subtaskControllers.length > 1)
                            GestureDetector(
                              onTap: () => _removeSubtaskField(i),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                  // Add another subtask
                  GestureDetector(
                    onTap: _addSubtaskField,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: AppColors.accentBlue,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Add another subtask',
                            style: AppTypography.bodyMedium(
                              color: AppColors.accentBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Buttons
                  Row(
                    children: [
                      // Cancel
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.glass,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: AppColors.glassBorder,
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: AppTypography.bodyMedium(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),

                      // Save
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _saving ? null : _save,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentBlue.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Save',
                                      style: AppTypography.bodyLarge(
                                        color: Colors.white,
                                      ).copyWith(fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
    required TextStyle style,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: style,
      cursorColor: AppColors.accentBlue,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: style.copyWith(color: AppColors.textMuted),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
