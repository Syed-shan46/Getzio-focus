import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/onboarding_models.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/premium_chip.dart';

/// Screen 2 — "What are you working towards?"
/// Multi-select goal chips with custom goal creation bottom sheet.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  static final List<UserGoal> _defaultGoals = [
    UserGoal(id: 'g1', title: 'Launch My Startup'),
    UserGoal(id: 'g2', title: 'Save ₹100,000'),
    UserGoal(id: 'g3', title: 'Read 20 Books'),
    UserGoal(id: 'g4', title: 'Wake Up at 6 AM'),
    UserGoal(id: 'g5', title: 'Lose Weight'),
    UserGoal(id: 'g6', title: 'Gain Muscle'),
    UserGoal(id: 'g7', title: 'Build Better Habits'),
    UserGoal(id: 'g8', title: 'Complete My Degree'),
    UserGoal(id: 'g9', title: 'Become Financially Free'),
    UserGoal(id: 'g10', title: 'Learn Flutter'),
    UserGoal(id: 'g11', title: 'Start Investing'),
    UserGoal(id: 'g12', title: 'Run 5 KM'),
    UserGoal(id: 'g13', title: 'Build a Reading Habit'),
    UserGoal(id: 'g14', title: 'Grow My Business'),
    UserGoal(id: 'g15', title: 'Improve Focus'),
    UserGoal(id: 'g16', title: 'Reduce Screen Time'),
    UserGoal(id: 'g17', title: 'Learn English'),
    UserGoal(id: 'g18', title: 'Travel Abroad'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGoals = ref.watch(onboardingProvider).selectedGoals;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Headline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'What are you\nworking towards?',
              style: AppTypography.displayLarge(color: Colors.white).copyWith(
                fontSize: 34,
                height: 1.12,
                letterSpacing: -0.8,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'Select your goals or create your own.',
              style: AppTypography.bodyMedium(
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Flowing goal chips
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._defaultGoals.map((goal) {
                    final isSelected = selectedGoals.any((g) => g.id == goal.id);
                    return PremiumChip(
                      emoji: _goalEmoji(goal.id),
                      title: goal.title,
                      isSelected: isSelected,
                      activeColor: AppColors.accentEmerald,
                      onTap: () {
                        ref.read(onboardingProvider.notifier).toggleGoal(goal);
                      },
                    );
                  }),

                  // Create Custom Goal chip
                  GestureDetector(
                    onTap: () => _showCreateGoalSheet(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accentBlue.withValues(alpha: 0.3),
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                        color: AppColors.accentBlue.withValues(alpha: 0.06),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: AppColors.accentBlue.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Create Custom Goal',
                            style: AppTypography.bodyMedium(
                              color: AppColors.accentBlue.withValues(alpha: 0.7),
                            ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  String _goalEmoji(String id) {
    const map = {
      'g1': '🚀', 'g2': '💰', 'g3': '📚', 'g4': '⏰',
      'g5': '🏋️', 'g6': '💪', 'g7': '🎯', 'g8': '🎓',
      'g9': '🏦', 'g10': '💻', 'g11': '📈', 'g12': '🏃',
      'g13': '📖', 'g14': '📊', 'g15': '🧠', 'g16': '📵',
      'g17': '🗣️', 'g18': '✈️',
    };
    return map[id] ?? '✨';
  }

  void _showCreateGoalSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateGoalSheet(),
    ).then((result) {
      if (result != null && result is UserGoal) {
        ref.read(onboardingProvider.notifier).addCustomGoal(result);
      }
    });
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Custom Goal Creation Bottom Sheet
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _CreateGoalSheet extends StatefulWidget {
  const _CreateGoalSheet();

  @override
  State<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<_CreateGoalSheet> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  String _selectedPriority = 'Medium';
  String _selectedEmoji = '🎯';

  final List<String> _emojis = [
    '🎯', '🚀', '💰', '📚', '💪', '🏃', '💻', '🎓',
    '📈', '🧠', '🎨', '🏡', '✈️', '❤️', '🌱', '⭐',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1220),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pull bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Create Custom Goal',
              style: AppTypography.titleLarge(color: Colors.white)
                  .copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Goal Name
            _buildField('Goal Name', _nameController, 'e.g., Launch my SaaS product'),
            const SizedBox(height: 14),

            // Target
            _buildField('Target (optional)', _targetController, 'e.g., ₹500,000 revenue'),
            const SizedBox(height: 20),

            // Icon Selection
            Text(
              'ICON',
              style: AppTypography.captionSmall(
                color: Colors.white.withValues(alpha: 0.4),
              ).copyWith(letterSpacing: 1),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojis.map((emoji) {
                final isSelected = _selectedEmoji == emoji;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedEmoji = emoji);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentBlue.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accentBlue.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Priority
            Text(
              'PRIORITY',
              style: AppTypography.captionSmall(
                color: Colors.white.withValues(alpha: 0.4),
              ).copyWith(letterSpacing: 1),
            ),
            const SizedBox(height: 10),
            Row(
              children: ['Low', 'Medium', 'High'].map((p) {
                final isSelected = _selectedPriority == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedPriority = p);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        right: p != 'High' ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _priorityColor(p).withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? _priorityColor(p).withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          p,
                          style: AppTypography.bodyMedium(
                            color: isSelected
                                ? _priorityColor(p)
                                : Colors.white.withValues(alpha: 0.5),
                          ).copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // Save button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _nameController.text.trim().isEmpty
                    ? null
                    : () {
                        final goal = UserGoal(
                          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                          title: _nameController.text.trim(),
                        );
                        Navigator.pop(context, goal);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentEmerald,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.06),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Add Goal',
                  style: AppTypography.titleMedium(color: Colors.black)
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: AppTypography.bodyMedium(color: Colors.white).copyWith(fontSize: 15),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.captionSmall(
          color: Colors.white.withValues(alpha: 0.4),
        ).copyWith(letterSpacing: 0.5),
        hintText: hint,
        hintStyle: AppTypography.bodyMedium(
          color: Colors.white.withValues(alpha: 0.15),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.accentBlue.withValues(alpha: 0.4),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'Low':
        return AppColors.accentEmerald;
      case 'High':
        return const Color(0xFFEF4444);
      default:
        return AppColors.accentBlue;
    }
  }
}
