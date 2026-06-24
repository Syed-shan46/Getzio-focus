import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/onboarding_models.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/premium_chip.dart';

/// Screen 4 — Select Daily Habits
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  static final Map<String, List<UserHabit>> predefinedHabits = {
    'Morning': [
      UserHabit(id: 'm1', title: '☀ Wake Up On Time', category: 'Morning', difficulty: 'Medium'),
      UserHabit(id: 'm2', title: '🛏 Make Bed', category: 'Morning', difficulty: 'Easy'),
      UserHabit(id: 'm3', title: '🕌 Prayer / Meditation', category: 'Morning', difficulty: 'Medium'),
      UserHabit(id: 'm4', title: '📵 No Phone (First Hour)', category: 'Morning', difficulty: 'Hard'),
      UserHabit(id: 'm5', title: '🌞 Morning Sunlight', category: 'Morning', difficulty: 'Easy'),
    ],
    'Health': [
      UserHabit(id: 'h1', title: '🏋 Workout', category: 'Health', difficulty: 'Hard'),
      UserHabit(id: 'h2', title: '🏃 Running', category: 'Health', difficulty: 'Hard'),
      UserHabit(id: 'h3', title: '🚰 Drink Water (3L)', category: 'Health', difficulty: 'Medium'),
      UserHabit(id: 'h4', title: '🥗 Healthy Meal', category: 'Health', difficulty: 'Medium'),
    ],
    'Productivity': [
      UserHabit(id: 'p1', title: '🎯 Complete Top 3 Tasks', category: 'Productivity', difficulty: 'Medium'),
      UserHabit(id: 'p2', title: '💻 Deep Work Session', category: 'Productivity', difficulty: 'Hard'),
      UserHabit(id: 'p3', title: '📖 Read 20 Pages', category: 'Productivity', difficulty: 'Medium'),
      UserHabit(id: 'p4', title: '🎓 Learn Something New', category: 'Productivity', difficulty: 'Medium'),
    ],
    'Home': [
      UserHabit(id: 'ho1', title: '🧹 Clean Room', category: 'Home', difficulty: 'Medium'),
      UserHabit(id: 'ho2', title: '🪴 Water Plants', category: 'Home', difficulty: 'Easy'),
      UserHabit(id: 'ho3', title: '🖥 Clean Workspace', category: 'Home', difficulty: 'Easy'),
      UserHabit(id: 'ho4', title: '📂 Organize Desk', category: 'Home', difficulty: 'Easy'),
    ],
    'Finance': [
      UserHabit(id: 'f1', title: '💰 Track Daily Expenses', category: 'Finance', difficulty: 'Medium'),
      UserHabit(id: 'f2', title: '📉 Check Budget', category: 'Finance', difficulty: 'Easy'),
      UserHabit(id: 'f3', title: '🪙 Save ₹100 Daily', category: 'Finance', difficulty: 'Medium'),
    ],
    'Evening': [
      UserHabit(id: 'e1', title: '📵 No Screens (1 Hr before sleep)', category: 'Evening', difficulty: 'Hard'),
      UserHabit(id: 'e2', title: '🧘 Daily Reflection', category: 'Evening', difficulty: 'Easy'),
      UserHabit(id: 'e3', title: '😴 Sleep by 11 PM', category: 'Evening', difficulty: 'Medium'),
    ],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedHabits = ref.watch(onboardingProvider).selectedHabits;

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
              'Select your\ndaily habits.',
              style: AppTypography.displayLarge(color: Colors.white).copyWith(
                fontSize: 34,
                height: 1.12,
                letterSpacing: -0.8,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'Choose only what matters to you. These will populate your daily living space checklist.',
              style: AppTypography.bodyMedium(
                color: Colors.white.withValues(alpha: 0.4),
              ).copyWith(height: 1.5),
            ),
          ),

          const SizedBox(height: 24),

          // Scrollable Sections
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              itemCount: predefinedHabits.keys.length,
              itemBuilder: (context, index) {
                final category = predefinedHabits.keys.elementAt(index);
                final habits = predefinedHabits[category]!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.toUpperCase(),
                        style: AppTypography.captionSmall(
                          color: AppColors.accentBlue,
                        ).copyWith(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: habits.map((habit) {
                          final isSelected = selectedHabits.any((h) => h.id == habit.id);
                          // Extract emoji if present, else empty
                          final titleWords = habit.title.split(' ');
                          String emoji = '';
                          String title = habit.title;
                          if (titleWords.isNotEmpty && titleWords.first.length <= 2) {
                            emoji = titleWords.first;
                            title = titleWords.sublist(1).join(' ');
                          }

                          return PremiumChip(
                            emoji: emoji,
                            title: title,
                            isSelected: isSelected,
                            onTap: () {
                              ref.read(onboardingProvider.notifier).toggleHabit(habit);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom navigation offset spacing
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
