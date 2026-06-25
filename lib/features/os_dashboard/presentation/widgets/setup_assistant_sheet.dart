import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/app_providers.dart';
import '../providers/os_providers.dart';
import '../../../onboarding/domain/models/onboarding_models.dart';

class SetupAssistantSheet extends ConsumerStatefulWidget {
  const SetupAssistantSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SetupAssistantSheet(),
    );
  }

  @override
  ConsumerState<SetupAssistantSheet> createState() => _SetupAssistantSheetState();
}

class _SetupAssistantSheetState extends ConsumerState<SetupAssistantSheet> {
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Step 1: Habits selections
  final List<UserHabit> _selectedHabits = [];
  final List<UserHabit> _allPredefinedHabits = [
    UserHabit(id: 'sa_h1', title: '☀ Wake Up On Time', category: 'Morning', difficulty: 'Medium'),
    UserHabit(id: 'sa_h2', title: '📵 No Phone (First Hour)', category: 'Morning', difficulty: 'Hard'),
    UserHabit(id: 'sa_h3', title: '🏋 Workout', category: 'Health', difficulty: 'Hard'),
    UserHabit(id: 'sa_h4', title: '🚰 Drink Water (3L)', category: 'Health', difficulty: 'Medium'),
    UserHabit(id: 'sa_h5', title: '🎯 Complete Top 3 Tasks', category: 'Productivity', difficulty: 'Medium'),
    UserHabit(id: 'sa_h6', title: '📖 Read 20 Pages', category: 'Productivity', difficulty: 'Medium'),
    UserHabit(id: 'sa_h7', title: '💰 Track Daily Expenses', category: 'Finance', difficulty: 'Medium'),
    UserHabit(id: 'sa_h8', title: '🧘 Daily Reflection', category: 'Evening', difficulty: 'Easy'),
  ];

  // Step 2: Goals
  final _goalController = TextEditingController();
  final List<String> _goals = [];

  // Step 3: Lifestyle/Target Preferences
  String _wakeUpTime = '6:00 AM';
  int _waterTarget = 2000;
  int _sleepTarget = 8;
  int _exerciseTarget = 30;
  int _savingsTarget = 10000;
  int _readingTarget = 20;

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _saveAndSync();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _saveAndSync() async {
    final hiveDb = ref.read(hiveDatabaseProvider);

    // 1. Save Habits
    final Map<String, dynamic> localLogs = hiveDb.getHabitLogs();
    final List<Map<String, dynamic>> habitsToSave = _selectedHabits.map((h) => {
      'id': h.id,
      'localId': h.id,
      'title': h.title,
      'category': h.category,
      'difficulty': h.difficulty,
      'isEnabled': h.isEnabled,
      'syncStatus': 'pending',
    }).toList();
    if (habitsToSave.isNotEmpty) {
      await hiveDb.saveSelectedHabits(habitsToSave);
    }

    // 2. Save Goals
    final List<Map<String, dynamic>> goalsToSave = _goals.map((g) => {
      'id': 'g_${DateTime.now().millisecondsSinceEpoch}_${g.hashCode}',
      'localId': 'g_${DateTime.now().millisecondsSinceEpoch}_${g.hashCode}',
      'title': g,
      'category': 'Productivity',
      'target': 100,
      'currentProgress': 0,
      'status': 'in-progress',
      'priority': 'medium',
      'deadline': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'syncStatus': 'pending',
    }).toList();
    if (goalsToSave.isNotEmpty) {
      await hiveDb.saveSelectedGoals(goalsToSave);
      if (_goals.isNotEmpty) {
        await hiveDb.saveSelectedGoal(_goals.first);
      }
    }

    // 3. Save targets
    await hiveDb.saveWakeUpTime(_wakeUpTime);
    await hiveDb.saveReadingPreferences({
      'categories': ['Self-Improvement'],
      'bookTarget': 12,
      'dailyReadingMinutes': _readingTarget,
    });
    await hiveDb.saveHealthPreferences({
      'waterTarget': _waterTarget,
      'sleepTarget': _sleepTarget,
      'exerciseTarget': _exerciseTarget,
    });
    await hiveDb.saveFinancePreferences({
      'monthlySavings': _savingsTarget,
    });

    // 4. Force Reload OS State & Sync to Server
    HapticFeedback.heavyImpact();
    
    // Set Setup Assistant completion flag
    await hiveDb.saveSetupCompleted(true);

    // Call updateWorkspaceSettings which triggers UI reload and network sync
    await ref.read(osStateProvider.notifier).updateWorkspaceSettings();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Workspace configured successfully!'),
          backgroundColor: AppColors.accentBlue.withValues(alpha: 0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: BoxDecoration(
          color: const Color(0xFF070A13).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 14, bottom: 16),
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personalize Your Growth',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Step ${_currentStep + 1} of $_totalSteps',
                        style: const TextStyle(color: AppColors.accentBlue, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context); // Skip setup Assistant
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10, height: 1),

            // Body
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _buildHabitsStep(),
                  _buildGoalsStep(),
                  _buildLifestyleStep(),
                ],
              ),
            ),

            // Bottom Navigation Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: _prevStep,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Colors.white10),
                          ),
                        ),
                        child: const Text('Back', style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentStep == _totalSteps - 1 ? 'Save & Start' : 'Continue',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: SELECT HABITS
  Widget _buildHabitsStep() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Select your daily habits'.toUpperCase(),
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Choose which habits you want to track daily. These populate your checklist.',
          style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _allPredefinedHabits.map((habit) {
            final isSelected = _selectedHabits.any((h) => h.id == habit.id);
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (isSelected) {
                    _selectedHabits.removeWhere((h) => h.id == habit.id);
                  } else {
                    _selectedHabits.add(habit);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.accentBlue.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.accentBlue : Colors.white12,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSelected ? '✓' : '+',
                      style: TextStyle(
                        color: isSelected ? AppColors.accentBlue : Colors.white60,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      habit.title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // STEP 2: SET GOALS
  Widget _buildGoalsStep() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'What are your main goals?'.toUpperCase(),
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Type a primary goal you want to achieve over the next month.',
          style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _goalController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g., Build my portfolio website',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.accentBlue),
                  ),
                ),
                onSubmitted: (_) => _addGoal(),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: _addGoal,
              style: IconButton.styleFrom(backgroundColor: AppColors.accentBlue),
              icon: const Icon(Icons.add, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_goals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(
              'No goals added yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
            ),
          )
        else
          ..._goals.map((goal) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _goals.remove(goal);
                      });
                    },
                    child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _addGoal() {
    final text = _goalController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _goals.add(text);
        _goalController.clear();
      });
      HapticFeedback.lightImpact();
    }
  }

  // STEP 3: LIFESTYLE & TARGETS
  Widget _buildLifestyleStep() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Lifestyle & Habits Targets'.toUpperCase(),
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),

        // Wake up time dropdown
        _buildDropdownSelector(
          title: 'Wake Up Time',
          value: _wakeUpTime,
          items: ['5:00 AM', '5:30 AM', '6:00 AM', '6:30 AM', '7:00 AM', '7:30 AM', '8:00 AM'],
          onChanged: (val) {
            if (val != null) setState(() => _wakeUpTime = val);
          },
        ),
        const SizedBox(height: 20),

        // Sliders for targets
        _buildSliderSetting(
          title: 'Daily Water Target',
          value: _waterTarget.toDouble(),
          min: 1000,
          max: 4000,
          divisions: 12,
          suffix: 'ml',
          onChanged: (val) => setState(() => _waterTarget = val.toInt()),
        ),
        const SizedBox(height: 20),

        _buildSliderSetting(
          title: 'Daily Sleep Target',
          value: _sleepTarget.toDouble(),
          min: 5,
          max: 10,
          divisions: 5,
          suffix: 'Hours',
          onChanged: (val) => setState(() => _sleepTarget = val.toInt()),
        ),
        const SizedBox(height: 20),

        _buildSliderSetting(
          title: 'Daily Exercise Session',
          value: _exerciseTarget.toDouble(),
          min: 15,
          max: 90,
          divisions: 5,
          suffix: 'Minutes',
          onChanged: (val) => setState(() => _exerciseTarget = val.toInt()),
        ),
        const SizedBox(height: 20),

        _buildSliderSetting(
          title: 'Monthly Savings Target',
          value: _savingsTarget.toDouble(),
          min: 2000,
          max: 50000,
          divisions: 24,
          suffix: '₹',
          isPrefix: true,
          onChanged: (val) => setState(() => _savingsTarget = val.toInt()),
        ),
      ],
    );
  }

  Widget _buildDropdownSelector({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF0F172A),
              items: items.map((val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    bool isPrefix = false,
    required ValueChanged<double> onChanged,
  }) {
    final valueStr = isPrefix ? '$suffix${value.toInt()}' : '${value.toInt()} $suffix';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              valueStr,
              style: const TextStyle(color: AppColors.accentBlue, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider.adaptive(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.accentBlue,
          inactiveColor: Colors.white10,
          onChanged: (val) {
            HapticFeedback.selectionClick();
            onChanged(val);
          },
        ),
      ],
    );
  }
}
