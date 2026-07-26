import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/focus_timer_controller.dart';

class FocusModeSelector extends ConsumerStatefulWidget {
  const FocusModeSelector({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const FocusModeSelector(),
    );
  }

  @override
  ConsumerState<FocusModeSelector> createState() => _FocusModeSelectorState();
}

class _FocusModeSelectorState extends ConsumerState<FocusModeSelector> {
  String _selectedMode = 'Pomodoro';
  int _customMinutes = 25;
  final TextEditingController _titleController = TextEditingController(text: 'Deep Focus');

  final List<Map<String, dynamic>> _modes = [
    {'name': 'Pomodoro', 'icon': Icons.timer, 'minutes': 25},
    {'name': 'Deep Work', 'icon': Icons.psychology, 'minutes': 50},
    {'name': 'Reading', 'icon': Icons.menu_book, 'minutes': 30},
    {'name': 'Study', 'icon': Icons.school, 'minutes': 45},
    {'name': 'Custom', 'icon': Icons.tune, 'minutes': 25},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _startSession() {
    final int duration = _selectedMode == 'Custom' 
        ? _customMinutes * 60 
        : (_modes.firstWhere((m) => m['name'] == _selectedMode)['minutes'] as int) * 60;

    ref.read(focusTimerControllerProvider.notifier).startSession(
      mode: _selectedMode,
      durationSeconds: duration,
      title: _titleController.text.trim().isEmpty ? 'Focus Session' : _titleController.text.trim(),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? const Color(0xFF0F172A).withValues(alpha: 0.75) 
                  : Colors.white.withValues(alpha: 0.75),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Start Focus Session',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                TextField(
                  controller: _titleController,
                  style: GoogleFonts.outfit(),
                  decoration: InputDecoration(
                    labelText: 'Session Intent (e.g. Finish UI Design)',
                    labelStyle: GoogleFonts.outfit(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                Text(
                  'Select Mode',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _modes.map((mode) {
                    final isSelected = _selectedMode == mode['name'];
                    return ChoiceChip(
                      label: Text(
                        mode['name'],
                        style: GoogleFonts.outfit(
                          color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedMode = mode['name']);
                        }
                      },
                      selectedColor: const Color(0xFF4A8FA8),
                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                if (_selectedMode == 'Custom') ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'Duration',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$_customMinutes min',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: const Color(0xFF4A8FA8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _customMinutes.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    activeColor: const Color(0xFF4A8FA8),
                    onChanged: (val) {
                      setState(() => _customMinutes = val.toInt());
                    },
                  ),
                ],
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _startSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A8FA8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Start Focusing',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
