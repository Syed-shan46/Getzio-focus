import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

class FinanceBuilderModal extends ConsumerStatefulWidget {
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
  ConsumerState<FinanceBuilderModal> createState() => _FinanceBuilderModalState();
}

class _FinanceBuilderModalState extends ConsumerState<FinanceBuilderModal> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _motivationController = TextEditingController();
  final _monthlyController = TextEditingController();
  
  double _progress = 0;
  DateTime? _targetDate;


  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _motivationController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final targetAmount = double.tryParse(amountText) ?? 1000.0;
    final currentAmount = targetAmount * (_progress / 100.0);

    widget.onSubmit({
      'title': _titleController.text.trim(),
      'amount': _amountController.text.trim().isEmpty ? '\$0' : _amountController.text.trim(),
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'progress': _progress,
      'description': _descriptionController.text.trim(),
      'motivation': _motivationController.text.trim(),
      'monthlyAmount': _monthlyController.text.trim().isEmpty ? '\$0/mo' : _monthlyController.text.trim(),
      'targetDate': _targetDate?.toIso8601String(),
      'isOnShelf': false,
    });
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.black,
              surface: Color(0xFF0F172A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTypography.titleMedium(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
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
              Text('Premium Finance Goal', style: AppTypography.displayMedium(color: Colors.white).copyWith(fontSize: 24), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              
              _buildTextField(_titleController, 'Goal (e.g. Bmw s100rr)'),
              const SizedBox(height: 12),
              
              _buildTextField(_descriptionController, 'Short Description or Quote'),
              const SizedBox(height: 12),
              
              _buildTextField(_amountController, 'Target Amount (e.g. \$10,000)', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              
              _buildTextField(_motivationController, 'Deep Motivation (Why do you want this?)', maxLines: 3),
              const SizedBox(height: 12),
              
              _buildTextField(_monthlyController, 'Monthly Savings Plan (e.g. \$100/mo)', keyboardType: TextInputType.text),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Target Date:', style: AppTypography.titleMedium(color: Colors.white70)),
                  TextButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month, color: Color(0xFFD4AF37)),
                    label: Text(
                      _targetDate != null 
                        ? '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}' 
                        : 'Select Date',
                      style: AppTypography.titleMedium(color: const Color(0xFFD4AF37)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Text('Current Progress: ${_progress.toInt()}%', style: AppTypography.caption(color: Colors.white54)),
              Slider(
                value: _progress,
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: const Color(0xFFD4AF37),
                inactiveColor: Colors.white.withValues(alpha: 0.1),
                onChanged: (val) => setState(() => _progress = val),
              ),
              const SizedBox(height: 16),


              
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Create Goal',
                  style: AppTypography.titleMedium(color: Colors.black).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

