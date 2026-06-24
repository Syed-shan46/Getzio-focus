import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/premium_chip.dart';
import '../widgets/section_header.dart';

/// Screen 3 — "What do you want to read?"
/// Category chips + Reading Target + Reading Time segmented pills.
class ReadingScreen extends ConsumerWidget {
  const ReadingScreen({super.key});

  static const List<Map<String, String>> _categories = [
    {'id': 'business', 'title': 'Business', 'emoji': '💼'},
    {'id': 'self_growth', 'title': 'Self Growth', 'emoji': '🌱'},
    {'id': 'psychology', 'title': 'Psychology', 'emoji': '🧠'},
    {'id': 'finance', 'title': 'Finance', 'emoji': '💰'},
    {'id': 'islamic', 'title': 'Islamic Books', 'emoji': '📿'},
    {'id': 'productivity', 'title': 'Productivity', 'emoji': '⚡'},
    {'id': 'technology', 'title': 'Technology', 'emoji': '🔧'},
    {'id': 'programming', 'title': 'Programming', 'emoji': '💻'},
    {'id': 'leadership', 'title': 'Leadership', 'emoji': '👑'},
    {'id': 'sales', 'title': 'Sales', 'emoji': '🤝'},
    {'id': 'communication', 'title': 'Communication', 'emoji': '🗣️'},
    {'id': 'biography', 'title': 'Biography', 'emoji': '📜'},
    {'id': 'entrepreneurship', 'title': 'Entrepreneurship', 'emoji': '🚀'},
    {'id': 'marketing', 'title': 'Marketing', 'emoji': '📢'},
    {'id': 'design', 'title': 'Design', 'emoji': '🎨'},
    {'id': 'health', 'title': 'Health', 'emoji': '❤️'},
    {'id': 'habits', 'title': 'Habits', 'emoji': '🔄'},
    {'id': 'history', 'title': 'History', 'emoji': '🏛️'},
    {'id': 'science', 'title': 'Science', 'emoji': '🔬'},
    {'id': 'philosophy', 'title': 'Philosophy', 'emoji': '💡'},
  ];

  static const List<int> _bookTargets = [5, 10, 20, 30, 50];
  static const List<int> _readingTimes = [10, 20, 30, 45, 60];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingPrefs = ref.watch(onboardingProvider).readingPrefs;

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
              'What do you\nwant to read?',
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
              'Pick genres that excite you.',
              style: AppTypography.bodyMedium(
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chips
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSelected =
                            readingPrefs.categories.contains(cat['id']);
                        return PremiumChip(
                          emoji: cat['emoji']!,
                          title: cat['title']!,
                          isSelected: isSelected,
                          activeColor: const Color(0xFFE8A838),
                          onTap: () {
                            ref
                                .read(onboardingProvider.notifier)
                                .toggleReadingCategory(cat['id']!);
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  // Reading Target section
                  const SectionHeader(title: 'READING TARGET'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _bookTargets.map((target) {
                        final isSelected = readingPrefs.bookTarget == target;
                        return PremiumPill(
                          label: '$target Books',
                          isSelected: isSelected,
                          activeColor: const Color(0xFFE8A838),
                          onTap: () {
                            ref
                                .read(onboardingProvider.notifier)
                                .setBookTarget(target);
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  // Reading Time section
                  const SectionHeader(title: 'DAILY READING TIME'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _readingTimes.map((minutes) {
                        final isSelected =
                            readingPrefs.dailyReadingMinutes == minutes;
                        return PremiumPill(
                          label: '$minutes Min',
                          isSelected: isSelected,
                          activeColor: const Color(0xFFE8A838),
                          onTap: () {
                            ref
                                .read(onboardingProvider.notifier)
                                .setReadingMinutes(minutes);
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
