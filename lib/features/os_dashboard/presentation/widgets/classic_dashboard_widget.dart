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
import '../../../auth/presentation/widgets/premium_auth_sheet.dart';
import '../../../vision_room/presentation/screens/vision_room_screen.dart';
import '../../../affirmations/presentation/providers/affirmations_provider.dart';
import '../../../affirmations/presentation/widgets/affirmation_bottom_sheet.dart';
import '../../../affirmations/presentation/screens/reader_view_screen.dart';
import 'workspace_customization.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';

class ClassicDashboardWidget extends ConsumerStatefulWidget {
  const ClassicDashboardWidget({super.key});

  @override
  ConsumerState<ClassicDashboardWidget> createState() =>
      _ClassicDashboardWidgetState();
}

class _ClassicDashboardWidgetState
    extends ConsumerState<ClassicDashboardWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A13),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const VisionRoomScreen(), // Room
          _GoalsTab(),              // Goals (Placeholder)
          const TasksScreen(),      // Tasks
          _AffirmationsTab(),       // Affirmations
          _ProfileTab(),            // Profile
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1020),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.door_sliding_rounded, 'Room'),
                  _buildNavItem(1, Icons.flag_rounded, 'Goals'),
                  _buildNavItem(2, Icons.check_circle_rounded, 'Tasks'),
                  _buildNavItem(3, Icons.auto_awesome_rounded, 'Affirm'),
                  _buildNavItem(4, Icons.person_rounded, 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accentBlue.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                icon,
                size: isActive ? 24 : 22,
                color: isActive
                    ? AppColors.accentBlue
                    : Colors.white.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: GoogleFonts.outfit(
                color: isActive
                    ? AppColors.accentBlue
                    : Colors.white.withValues(alpha: 0.35),
                fontSize: isActive ? 10.5 : 9.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1: Home (original ClassicDashboardWidget content)
// ─────────────────────────────────────────────────────────────────────────────
class _HomeTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(osStateProvider);
    final notifier = ref.read(osStateProvider.notifier);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.hasValue && authState.value != null;
    final userName = isLoggedIn ? (authState.value?.name ?? 'User') : 'Guest';

    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d').format(now);

    return Container(
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

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2: Affirmations
// ─────────────────────────────────────────────────────────────────────────────
class _AffirmationsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affState = ref.watch(affirmationsProvider);
    final affirmations = affState.affirmations;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1524), Color(0xFF070A13)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AFFIRMATIONS',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Speak Your Truth',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.accentBlue.withValues(alpha: 0.25),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add_rounded, color: AppColors.accentBlue, size: 22),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        AffirmationBottomSheet.show(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Stats bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _affStat('Total', '${affirmations.length}', Icons.format_quote_rounded),
                    Container(width: 1, height: 24, color: Colors.white10),
                    _affStat('Practiced', '${affState.completedTodayCount}', Icons.check_circle_outline_rounded),
                    Container(width: 1, height: 24, color: Colors.white10),
                    _affStat('Favorites', '${affirmations.where((a) => a.isFavorite).length}', Icons.favorite_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: affirmations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 48,
                              color: AppColors.accentBlue.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'No affirmations yet',
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap + to create your first affirmation',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: affirmations.length,
                      itemBuilder: (context, index) {
                        final aff = affirmations[index];
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReaderViewScreen(affirmation: aff),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: aff.isPinned
                                    ? AppColors.accentBlue.withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.04),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Emoji / Icon
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _affThemeColor(aff.colorTheme).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    aff.emoji ?? '✨',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          if (aff.isPinned)
                                            Padding(
                                              padding: const EdgeInsets.only(right: 6),
                                              child: Icon(Icons.push_pin_rounded,
                                                  size: 12,
                                                  color: AppColors.accentBlue.withValues(alpha: 0.6)),
                                            ),
                                          Expanded(
                                            child: Text(
                                              aff.title,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '"${aff.text}"',
                                        style: GoogleFonts.playfairDisplay(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (aff.isFavorite)
                                  Icon(Icons.favorite_rounded,
                                      size: 16, color: Colors.redAccent.withValues(alpha: 0.6)),
                                const Icon(Icons.chevron_right_rounded,
                                    size: 20, color: Colors.white24),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _affStat(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.accentBlue.withValues(alpha: 0.5)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _affThemeColor(String theme) {
    switch (theme) {
      case 'Ocean Blue':
        return Colors.blue;
      case 'Sunrise Orange':
        return Colors.orange;
      case 'Forest Green':
        return Colors.green;
      case 'Lavender':
        return Colors.purple;
      case 'Coffee Brown':
        return Colors.brown;
      case 'Midnight Black':
        return Colors.blueGrey;
      case 'Dark Glass':
        return Colors.cyan;
      default:
        return AppColors.accentBlue;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 4: Profile
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.hasValue && authState.value != null;
    final user = authState.valueOrNull;
    final state = ref.watch(osStateProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1524), Color(0xFF070A13)],
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
              // Header
              Text(
                'PROFILE',
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Avatar & Name Section
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentBlue.withValues(alpha: 0.3),
                            AppColors.accentBlue.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: AppColors.accentBlue.withValues(alpha: 0.25),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isLoggedIn
                            ? (user?.name ?? 'U').substring(0, 1).toUpperCase()
                            : '?',
                        style: GoogleFonts.outfit(
                          color: AppColors.accentBlue,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isLoggedIn ? (user?.name ?? 'User') : 'Guest User',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoggedIn ? (user?.mobile ?? '') : 'Not signed in',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13,
                      ),
                    ),
                    if (!isLoggedIn) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          PremiumAuthSheet.show(context);
                        },
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: Text(
                          'Sign In',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Stats Section
              _buildProfileStatRow('Level', '${state.level}', Icons.workspace_premium_rounded, Colors.amber),
              _buildProfileStatRow('XP', '${state.xp}', Icons.stars_rounded, AppColors.accentBlue),
              _buildProfileStatRow('Current Streak', '${state.currentStreak} days', Icons.local_fire_department_rounded, Colors.orange),
              _buildProfileStatRow('Best Streak', '${state.bestStreak} days', Icons.emoji_events_rounded, Colors.amber),
              _buildProfileStatRow('Identity', state.activeIdentity, Icons.fingerprint_rounded, AppColors.accentEmerald),
              const SizedBox(height: 24),

              // Settings Section
              Text(
                'SETTINGS',
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsTile(
                context,
                'Workspace Customization',
                Icons.tune_rounded,
                AppColors.accentBlue,
                () => WorkspaceCustomizationSheet.show(context),
              ),
              if (isLoggedIn)
                _buildSettingsTile(
                  context,
                  'Sign Out',
                  Icons.logout_rounded,
                  Colors.redAccent,
                  () {
                    HapticFeedback.mediumImpact();
                    ref.read(authProvider.notifier).logout();
                  },
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStatRow(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color == Colors.redAccent ? Colors.redAccent : Colors.white70,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: Colors.white.withValues(alpha: 0.2)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 5: Roadmap
// ─────────────────────────────────────────────────────────────────────────────
class _RoadmapTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(osStateProvider);
    final hiveDb = ref.read(hiveDatabaseProvider);
    final selectedGoals = hiveDb.getSelectedGoals();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1524), Color(0xFF070A13)],
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
              // Header
              Text(
                'ROADMAP',
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your Journey',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Level Progress
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentBlue.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LEVEL ${state.level}',
                          style: GoogleFonts.outfit(
                            color: AppColors.accentBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '${state.xp} XP',
                          style: GoogleFonts.outfit(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (state.xp % 1000) / 1000,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        valueColor: const AlwaysStoppedAnimation(AppColors.accentBlue),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${1000 - (state.xp % 1000)} XP to next level',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Milestone Timeline
              Text(
                'MILESTONES',
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildMilestone(
                '7-Day Streak',
                state.bestStreak >= 7 ? 'Achieved' : '${7 - state.currentStreak} days left',
                Icons.local_fire_department_rounded,
                Colors.orange,
                state.bestStreak >= 7,
              ),
              _buildMilestone(
                '30-Day Streak',
                state.bestStreak >= 30 ? 'Achieved' : '${30 - state.currentStreak} days left',
                Icons.whatshot_rounded,
                Colors.deepOrange,
                state.bestStreak >= 30,
              ),
              _buildMilestone(
                'First 1000 XP',
                state.xp >= 1000 ? 'Achieved' : '${1000 - state.xp} XP remaining',
                Icons.stars_rounded,
                Colors.amber,
                state.xp >= 1000,
              ),
              _buildMilestone(
                'Level 5 Mastery',
                state.level >= 5 ? 'Achieved' : 'Currently Level ${state.level}',
                Icons.workspace_premium_rounded,
                AppColors.accentBlue,
                state.level >= 5,
              ),
              _buildMilestone(
                'All Habits Done',
                state.disciplineScore >= 100 ? 'Achieved today!' : '${state.disciplineScore.toInt()}% complete',
                Icons.check_circle_rounded,
                AppColors.accentEmerald,
                state.disciplineScore >= 100,
              ),
              const SizedBox(height: 24),

              // Goals Roadmap
              if (selectedGoals.isNotEmpty) ...[
                Text(
                  'GOAL PROGRESS',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ...selectedGoals.map((goal) {
                  final title = goal['title'] as String? ?? 'Goal';
                  final category = goal['category'] as String? ?? 'General';
                  final current = (goal['currentProgress'] as num?)?.toDouble() ?? 30.0;
                  final target = (goal['target'] as num?)?.toDouble() ?? 100.0;
                  final progress = (current / target).clamp(0.0, 1.0);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.flag_rounded, size: 18, color: AppColors.accentBlue),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    category,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.35),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: GoogleFonts.outfit(
                                color: AppColors.accentBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.white.withValues(alpha: 0.04),
                            valueColor: const AlwaysStoppedAnimation(AppColors.accentBlue),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestone(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool achieved,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Timeline dot + line
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: achieved
                      ? color.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: achieved ? color : Colors.white.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  achieved ? Icons.check_rounded : icon,
                  size: 14,
                  color: achieved ? color : Colors.white30,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: achieved
                    ? color.withValues(alpha: 0.04)
                    : Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: achieved
                      ? color.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.04),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: achieved ? Colors.white : Colors.white70,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: achieved
                                ? color.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.35),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (achieved)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '✓',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW TAB: Goals (Placeholder)
// ─────────────────────────────────────────────────────────────────────────────

class _GoalsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF070A13),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flag_rounded, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'Goals Module',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
