import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CountdownBuilderModal extends StatefulWidget {
  final Function(Map<String, dynamic> metadata) onSubmit;

  const CountdownBuilderModal({super.key, required this.onSubmit});

  static void show(BuildContext context, {required Function(Map<String, dynamic> metadata) onSubmit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CountdownBuilderModal(onSubmit: onSubmit),
    );
  }

  @override
  State<CountdownBuilderModal> createState() => _CountdownBuilderModalState();
}

class _CountdownBuilderModalState extends State<CountdownBuilderModal> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool _addToShelf = false;

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    
    int days = 0;
    if (_selectedDate != null) {
      days = _selectedDate!.difference(DateTime.now()).inDays;
      if (days < 0) days = 0;
    }
    
    widget.onSubmit({
      'title': _titleController.text.trim(),
      'days': days,
      'targetDate': _selectedDate?.toIso8601String(),
      'isOnShelf': _addToShelf,
    });
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
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
              Text('Countdown', style: AppTypography.displayMedium(color: Colors.white).copyWith(fontSize: 24), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              TextField(
                controller: _titleController,
                style: AppTypography.titleMedium(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Event Name (e.g. Hawaii Trip)',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: Colors.pinkAccent),
                      const SizedBox(width: 16),
                      Text(
                        _selectedDate == null ? 'Select Target Date' : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                        style: AppTypography.titleMedium(color: _selectedDate == null ? Colors.white54 : Colors.white),
                      ),
                    ],
                  ),
                ),
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
                    activeColor: Colors.pinkAccent,
                    onChanged: (val) => setState(() => _addToShelf = val),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Start Countdown', style: AppTypography.titleMedium(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
