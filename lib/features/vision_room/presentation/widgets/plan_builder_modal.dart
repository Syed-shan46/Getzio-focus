import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PlanBuilderModal extends StatefulWidget {
  final Function(Map<String, dynamic> metadata) onSubmit;

  const PlanBuilderModal({super.key, required this.onSubmit});

  static void show(BuildContext context, {required Function(Map<String, dynamic> metadata) onSubmit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlanBuilderModal(onSubmit: onSubmit),
    );
  }

  @override
  State<PlanBuilderModal> createState() => _PlanBuilderModalState();
}

class _PlanBuilderModalState extends State<PlanBuilderModal> {
  final _titleController = TextEditingController();
  final List<TextEditingController> _objectiveControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    for (var c in _objectiveControllers) { c.dispose(); }
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    
    final objectives = _objectiveControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
        
    widget.onSubmit({
      'title': _titleController.text.trim(),
      'objectives': objectives.isEmpty ? ['Task 1', 'Task 2'] : objectives,
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
              Text('Create Plan', style: AppTypography.displayMedium(color: Colors.white).copyWith(fontSize: 24), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              TextField(
                controller: _titleController,
                style: AppTypography.titleMedium(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Plan Title (e.g. Q3 Launch)',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Text('Objectives', style: AppTypography.caption(color: Colors.white54)),
              const SizedBox(height: 8),
              ...List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _objectiveControllers[index],
                    style: AppTypography.bodyMedium(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Objective ${index + 1}',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentEmerald,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Add Plan', style: AppTypography.titleMedium(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
