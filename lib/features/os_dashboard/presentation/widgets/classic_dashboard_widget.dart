import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/app_providers.dart';
import '../providers/os_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/save_workspace_sheet.dart';
import '../../../vision_room/presentation/screens/vision_room_screen.dart';
import 'workspace_customization.dart';

class ClassicDashboardWidget extends ConsumerWidget {
  const ClassicDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(osStateProvider);
    final notifier = ref.read(osStateProvider.notifier);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.hasValue && authState.value != null;
    final userName = isLoggedIn ? (authState.value?.name ?? 'User') : 'Guest';

    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFF070A13),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F1524),
              Color(0xFF070A13),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (!isLoggedIn) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.cloud_off_rounded, size: 10, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Stored on this device only',
                                      style: GoogleFonts.outfit(
                                        color: Colors.amber,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Quick Customize Button
                        IconButton(
                          icon: const Icon(Icons.tune_rounded, color: Colors.white70),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            WorkspaceCustomizationSheet.show(context);
                          },
                        ),
                        const SizedBox(width: 8),
                        // Vision Room quick access
                        IconButton(
                          icon: const Icon(Icons.door_sliding_rounded, color: AppColors.accentBlue),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const VisionRoomScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Cloud Save Promo Card (if Guest)
                if (!isLoggedIn) ...[
                  _buildCloudSavePromo(context),
                  const SizedBox(height: 20),
                ],

                // 3. Stats Row
                _buildStatsGrid(state),
                const SizedBox(height: 24),

                // 4. Daily Quote Frame
                _buildDailyQuoteCard(state),
                const SizedBox(height: 24),

                // 5. Today's Habits Checklist
                _buildHabitsSection(state, notifier),
                const SizedBox(height: 24),

                // 6. Active Goals
                _buildGoalsSection(ref),
                const SizedBox(height: 24),

                // 7. Reading, Health & Finance Trackers
                _buildTrackersGrid(ref, state, notifier),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloudSavePromo(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentBlue.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentBlue.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Text(
            '☁️',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workspace Unsecured',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Your data is stored only on this device. Sign in to cloud sync.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              SaveWorkspaceSheet.show(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(
              'Sync',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(OSState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
              width: cardW,
              title: 'Discipline',
              value: '${state.disciplineScore.toInt()}%',
              subtitle: 'Today\'s habits done',
              icon: Icons.auto_awesome_rounded,
              color: AppColors.accentBlue,
            ),
            _buildStatCard(
              width: cardW,
              title: 'XP Points',
              value: '${state.xp}',
              subtitle: 'Level ${state.level}',
              icon: Icons.workspace_premium_rounded,
              color: Colors.amber,
            ),
            _buildStatCard(
              width: cardW,
              title: 'Streak',
              value: '${state.currentStreak} Days',
              subtitle: 'Best streak: ${state.bestStreak}d',
              icon: Icons.local_fire_department_rounded,
              color: Colors.orange,
            ),
            _buildStatCard(
              width: cardW,
              title: 'Identity',
              value: state.activeIdentity.split(' ').last,
              subtitle: state.activeIdentity.split(' ').first,
              icon: Icons.fingerprint_rounded,
              color: AppColors.accentEmerald,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(icon, color: color.withValues(alpha: 0.7), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuoteCard(OSState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        children: [
          const Text(
            '🖼️',
            style: TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            '"${state.dailyQuote}"',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14.5,
              fontStyle: FontStyle.italic,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— ${state.dailyQuoteAuthor}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.accentBlue.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsSection(OSState state, OSStateNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY\'S HABITS',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${state.completedHabitIdsToday.length}/${state.selectedHabits.length} Done',
                  style: const TextStyle(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.selectedHabits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No habits selected. Use customize settings to choose your habits.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 12.5,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.selectedHabits.length,
              itemBuilder: (context, idx) {
                final habit = state.selectedHabits[idx];
                final isCompleted = state.completedHabitIdsToday.contains(habit.id);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? AppColors.accentBlue.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.01),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCompleted 
                          ? AppColors.accentBlue.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.03),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    dense: true,
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _getHabitCategoryEmoji(habit.category),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    title: Text(
                      habit.title,
                      style: TextStyle(
                        color: isCompleted ? Colors.white70 : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      habit.category,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                      ),
                    ),
                    trailing: Checkbox(
                      value: isCompleted,
                      activeColor: AppColors.accentBlue,
                      checkColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      side: const BorderSide(color: Colors.white30, width: 1.5),
                      onChanged: (val) {
                        HapticFeedback.mediumImpact();
                        notifier.toggleHabitCompletion(habit.id);
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _getHabitCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'health':
      case 'fitness':
      case 'workout':
        return '💪';
      case 'finance':
      case 'money':
        return '💰';
      case 'reading':
      case 'learning':
      case 'mind':
        return '📚';
      case 'morning':
        return '🌅';
      case 'evening':
        return '🌌';
      case 'home':
        return '🧹';
      default:
        return '✅';
    }
  }

  Widget _buildGoalsSection(WidgetRef ref) {
    final hiveDb = ref.read(hiveDatabaseProvider);
    final selectedGoals = hiveDb.getSelectedGoals();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ACTIVE GOALS',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          if (selectedGoals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No active goals. You can set them in settings or vision board.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 12.5,
                ),
              ),
            )
          else
            Column(
              children: selectedGoals.map((goal) {
                final title = goal['title'] as String? ?? 'Goal';
                final category = goal['category'] as String? ?? 'General';
                final current = (goal['currentProgress'] as num?)?.toDouble() ?? 30.0;
                final target = (goal['target'] as num?)?.toDouble() ?? 100.0;
                final progress = (current / target).clamp(0.0, 1.0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.01),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: AppColors.accentBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation(AppColors.accentBlue),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTrackersGrid(WidgetRef ref, OSState state, OSStateNotifier notifier) {
    final hiveDb = ref.read(hiveDatabaseProvider);
    final readingPrefs = hiveDb.getReadingPreferences() ?? {'bookTarget': 12, 'dailyReadingMinutes': 20};
    final healthPrefs = hiveDb.getHealthPreferences() ?? {'waterTarget': 2000, 'sleepTarget': 8};
    final financePrefs = hiveDb.getFinancePreferences() ?? {'monthlySavings': 10000};

    final int waterTarget = healthPrefs['waterTarget'] ?? 2000;
    final int sleepTarget = healthPrefs['sleepTarget'] ?? 8;
    final int savingsTarget = financePrefs['monthlySavings'] ?? 10000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'TRACKERS',
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 16),

        // Health Tracker Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.health_and_safety_rounded, color: AppColors.accentEmerald, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Health & Lifestyle',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Water log slider
              _buildTrackerSlider(
                title: 'Water Logged',
                valueStr: '1250 / $waterTarget ml',
                progress: 1250 / waterTarget,
                accentColor: AppColors.accentBlue,
              ),
              const SizedBox(height: 14),
              // Sleep hours
              _buildTrackerSlider(
                title: 'Sleep Target',
                valueStr: '7.5 / $sleepTarget Hours',
                progress: 7.5 / sleepTarget,
                accentColor: Colors.purpleAccent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Reading Tracker Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.book_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Reading & Learning',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTrackerSlider(
                title: 'Daily Pages Read',
                valueStr: '15 / ${readingPrefs['dailyReadingMinutes'] ?? 20} Pages',
                progress: 15 / (readingPrefs['dailyReadingMinutes'] ?? 20),
                accentColor: Colors.amber,
              ),
              const SizedBox(height: 6),
              Text(
                'Yearly Target: ${readingPrefs['bookTarget'] ?? 12} Books',
                style: const TextStyle(color: Colors.white30, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Finance Tracker Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.savings_rounded, color: Colors.orangeAccent, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Financial Savings',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTrackerSlider(
                title: 'Monthly Savings Target',
                valueStr: '₹4,500 / ₹$savingsTarget',
                progress: 4500 / savingsTarget,
                accentColor: Colors.orangeAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrackerSlider({
    required String title,
    required String valueStr,
    required double progress,
    required Color accentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              valueStr,
              style: TextStyle(
                color: accentColor,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: Colors.white.withValues(alpha: 0.04),
            valueColor: AlwaysStoppedAnimation(accentColor),
          ),
        ),
      ],
    );
  }
}
