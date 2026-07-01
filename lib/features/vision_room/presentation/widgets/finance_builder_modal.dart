import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FinanceBuilderModal extends StatefulWidget {
  final Function(Map<String, dynamic> metadata) onSubmit;

  const FinanceBuilderModal({super.key, required this.onSubmit});

  static void show(BuildContext context, {required Function(Map<String, dynamic> metadata) onSubmit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FinanceBuilderModal(onSubmit: onSubmit),
    );
  }

  @override
  State<FinanceBuilderModal> createState() => _FinanceBuilderModalState();
}

class _FinanceBuilderModalState extends State<FinanceBuilderModal> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  double _progress = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool _addToShelf = false;

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    widget.onSubmit({
      'title': _titleController.text.trim(),
      'amount': _amountController.text.trim().isEmpty ? '\$0' : _amountController.text.trim(),
      'progress': _progress,
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
              Text('Finance Goal', style: AppTypography.displayMedium(color: Colors.white).copyWith(fontSize: 24), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              TextField(
                controller: _titleController,
                style: AppTypography.titleMedium(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Goal (e.g. Dream House)',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: AppTypography.titleMedium(color: Colors.tealAccent),
                decoration: InputDecoration(
                  hintText: 'Target Amount (e.g. \$10,000)',
                  hintStyle: TextStyle(color: Colors.tealAccent.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Text('Current Progress: ${_progress.toInt()}%', style: AppTypography.caption(color: Colors.white54)),
              Slider(
                value: _progress,
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: Colors.tealAccent,
                inactiveColor: Colors.white.withValues(alpha: 0.1),
                onChanged: (val) => setState(() => _progress = val),
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
                    activeColor: Colors.tealAccent,
                    onChanged: (val) => setState(() => _addToShelf = val),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Add to Board', style: AppTypography.titleMedium(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
