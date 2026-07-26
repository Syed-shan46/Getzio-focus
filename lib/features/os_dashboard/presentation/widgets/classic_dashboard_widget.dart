import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/theme/app_theme.dart';
import 'package:getzio_todo_app/shared/widgets/design_system.dart';
import '../../../../shared/providers/app_providers.dart';
import '../providers/os_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/save_workspace_sheet.dart';
import '../../../auth/domain/models/auth_user_model.dart';

import '../../../auth/presentation/widgets/premium_auth_sheet.dart';
import '../../../auth/presentation/screens/phone_login_screen.dart';
import '../../../auth/domain/services/guest_migration_service.dart';
import '../../../../core/storage/sync_manager.dart';
import '../../../vision_room/presentation/screens/vision_room_screen.dart';
import '../../../affirmations/presentation/providers/affirmations_provider.dart';
import '../../../affirmations/presentation/widgets/affirmation_bottom_sheet.dart';
import '../../../affirmations/presentation/screens/reader_view_screen.dart';
import 'workspace_customization.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';
import '../screens/daily_motivation_screen.dart';
import '../screens/os_dashboard_screen.dart';
import '../../../vision_room/presentation/providers/canvas_providers.dart';
import '../../../vision_room/domain/models/vision_item.dart';
import '../../../routine/presentation/screens/daily_routine_screen.dart';
import '../../../vision_room/domain/models/smart_object_models.dart';
import '../../../vision_room/presentation/widgets/smart_object_sheets.dart';

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
      backgroundColor: context.colors.bg1,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const TasksScreen(), // Tasks
          const DailyMotivationScreen(isTab: true), // Affirmations
          const OSDashboardScreen(isTab: true), // Room (Living Space)
          const DailyRoutineScreen(), // Routines
          _ProfileTab(), // Profile
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final needsThemeBg = _currentIndex != 2;

    final Color navBgColor = needsThemeBg
        ? context.colors.bg1.withValues(alpha: 0.85)
        : Colors.transparent;
    final Color borderColor = needsThemeBg
        ? context.colors.textPrimary.withValues(alpha: 0.08)
        : Colors.transparent;
    final List<BoxShadow> navBoxShadow = needsThemeBg
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ]
        : [];
    final double blurSigma = needsThemeBg ? 15.0 : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: navBgColor,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        boxShadow: navBoxShadow,
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.check_circle_rounded, 'Tasks'),
                  _buildNavItem(1, Icons.auto_awesome_rounded, 'Affirm'),
                  _buildNavItem(2, Icons.door_sliding_rounded, 'Room'),
                  _buildNavItem(3, Icons.repeat_rounded, 'Routines'),
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
    final isRoom = _currentIndex == 2;

    // Adaptive colors
    final activeColor = isRoom ? Colors.white : const Color(0xFFF97316);

    final inactiveColor = isRoom
        ? Colors.white.withValues(alpha: 0.6)
        : context.colors.textPrimary.withValues(alpha: 0.35);

    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: isActive ? activeColor : inactiveColor),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
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
                                  const Icon(
                                    Icons.cloud_off_rounded,
                                    size: 10,
                                    color: Colors.amber,
                                  ),
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
                        icon: const Icon(
                          Icons.tune_rounded,
                          color: Colors.white70,
                        ),
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
          const Text('☁️', style: TextStyle(fontSize: 32)),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
            style: const TextStyle(color: Colors.white54, fontSize: 11.5),
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
          const Text('🖼️', style: TextStyle(fontSize: 22)),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${state.completedHabitIdsToday.length}/${state.selectedHabits.length} Done',
                  style: TextStyle(
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
                final isCompleted = state.completedHabitIdsToday.contains(
                  habit.id,
                );
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2,
                    ),
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
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
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
                final current =
                    (goal['currentProgress'] as num?)?.toDouble() ?? 30.0;
                final target = (goal['target'] as num?)?.toDouble() ?? 100.0;
                final progress = (current / target).clamp(0.0, 1.0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.01),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.03),
                    ),
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
                            style: TextStyle(
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
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.accentBlue,
                          ),
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

  Widget _buildTrackersGrid(
    WidgetRef ref,
    OSState state,
    OSStateNotifier notifier,
  ) {
    final hiveDb = ref.read(hiveDatabaseProvider);
    final readingPrefs =
        hiveDb.getReadingPreferences() ??
        {'bookTarget': 12, 'dailyReadingMinutes': 20};
    final healthPrefs =
        hiveDb.getHealthPreferences() ??
        {'waterTarget': 2000, 'sleepTarget': 8};
    final financePrefs =
        hiveDb.getFinancePreferences() ?? {'monthlySavings': 10000};

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
                  Icon(
                    Icons.health_and_safety_rounded,
                    color: AppColors.accentEmerald,
                    size: 20,
                  ),
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
                valueStr:
                    '15 / ${readingPrefs['dailyReadingMinutes'] ?? 20} Pages',
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
                  const Icon(
                    Icons.savings_rounded,
                    color: Colors.orangeAccent,
                    size: 20,
                  ),
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
      decoration: BoxDecoration(color: context.colors.bg1),
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
                      icon: Icon(
                        Icons.add_rounded,
                        color: AppColors.accentBlue,
                        size: 22,
                      ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _affStat(
                      'Total',
                      '${affirmations.length}',
                      Icons.format_quote_rounded,
                    ),
                    Container(width: 1, height: 24, color: Colors.white10),
                    _affStat(
                      'Practiced',
                      '${affState.completedTodayCount}',
                      Icons.check_circle_outline_rounded,
                    ),
                    Container(width: 1, height: 24, color: Colors.white10),
                    _affStat(
                      'Favorites',
                      '${affirmations.where((a) => a.isFavorite).length}',
                      Icons.favorite_rounded,
                    ),
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
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 48,
                            color: AppColors.accentBlue.withValues(alpha: 0.3),
                          ),
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
                                builder: (_) =>
                                    ReaderViewScreen(affirmation: aff),
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
                                    ? AppColors.accentBlue.withValues(
                                        alpha: 0.15,
                                      )
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
                                    color: _affThemeColor(
                                      aff.colorTheme,
                                    ).withValues(alpha: 0.1),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          if (aff.isPinned)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 6,
                                              ),
                                              child: Icon(
                                                Icons.push_pin_rounded,
                                                size: 12,
                                                color: AppColors.accentBlue
                                                    .withValues(alpha: 0.6),
                                              ),
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
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
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
                                  Icon(
                                    Icons.favorite_rounded,
                                    size: 16,
                                    color: Colors.redAccent.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: Colors.white24,
                                ),
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
        Icon(
          icon,
          size: 16,
          color: AppColors.accentBlue.withValues(alpha: 0.5),
        ),
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
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: context.colors.bg1),
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
                  color: context.colors.textPrimary.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              if (isLoggedIn && user != null) ...[
                _buildUserProfileCard(context, user),
                const SizedBox(height: 24),
              ],
              _buildCloudSyncCard(context, ref, isLoggedIn),
              const SizedBox(height: 24),

              // Settings Section
              Text(
                'SETTINGS',
                style: GoogleFonts.outfit(
                  color: context.colors.textPrimary.withValues(alpha: 0.4),
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
              if (!isLoggedIn)
                _buildSettingsTile(
                  context,
                  'Sign In',
                  Icons.login_rounded,
                  AppColors.accentBlue,
                  () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PhoneLoginScreen(),
                      ),
                    );
                  },
                ),
              if (isLoggedIn) ...[
                _buildSettingsTile(
                  context,
                  'Sign Out',
                  Icons.logout_rounded,
                  Colors.redAccent,
                  () {
                    HapticFeedback.mediumImpact();
                    _showSignOutDialog(context, ref);
                  },
                ),
                const SizedBox(height: 8),
                _buildSettingsTile(
                  context,
                  'Delete Account',
                  Icons.delete_forever_rounded,
                  context.colors.error,
                  () {
                    HapticFeedback.mediumImpact();
                    _confirmAccountDeletion(context, ref);
                  },
                ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmAccountDeletion(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.colors.bg2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.colors.glassBorder, width: 0.5),
          ),
          title: Text(
            'Delete Account',
            style: TextStyle(
              color: context.colors.error,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Are you sure you want to permanently delete your account and all associated tasks? This action is immediate and cannot be undone.',
            style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog
                try {
                  await ref.read(authProvider.notifier).deleteAccount();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Your account has been deleted.',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: context.colors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to delete account: ${e.toString().replaceFirst('Exception: ', '')}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: context.colors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: context.colors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.textPrimary.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.textPrimary.withValues(alpha: 0.04),
        ),
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
                color: context.colors.textSecondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: context.colors.textPrimary,
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
          color: context.colors.textPrimary.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.textPrimary.withValues(alpha: 0.04),
          ),
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
                  color: color == Colors.redAccent
                      ? Colors.redAccent
                      : context.colors.textSecondary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: context.colors.textPrimary.withValues(alpha: 0.2),
            ),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.bg1, context.colors.bg2],
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
                  color: context.colors.textPrimary.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your Journey',
                style: GoogleFonts.playfairDisplay(
                  color: context.colors.textPrimary,
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
                  border: Border.all(
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                  ),
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
                            color: context.colors.textMuted,
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
                        backgroundColor: context.colors.textPrimary.withValues(
                          alpha: 0.05,
                        ),
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.accentBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${1000 - (state.xp % 1000)} XP to next level',
                      style: TextStyle(
                        color: context.colors.textPrimary.withValues(
                          alpha: 0.35,
                        ),
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
                  color: context.colors.textPrimary.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildMilestone(
                context,
                '7-Day Streak',
                state.bestStreak >= 7
                    ? 'Achieved'
                    : '${7 - state.currentStreak} days left',
                Icons.local_fire_department_rounded,
                Colors.orange,
                state.bestStreak >= 7,
              ),
              _buildMilestone(
                context,
                '30-Day Streak',
                state.bestStreak >= 30
                    ? 'Achieved'
                    : '${30 - state.currentStreak} days left',
                Icons.whatshot_rounded,
                Colors.deepOrange,
                state.bestStreak >= 30,
              ),
              _buildMilestone(
                context,
                'First 1000 XP',
                state.xp >= 1000
                    ? 'Achieved'
                    : '${1000 - state.xp} XP remaining',
                Icons.stars_rounded,
                Colors.amber,
                state.xp >= 1000,
              ),
              _buildMilestone(
                context,
                'Level 5 Mastery',
                state.level >= 5
                    ? 'Achieved'
                    : 'Currently Level ${state.level}',
                Icons.workspace_premium_rounded,
                AppColors.accentBlue,
                state.level >= 5,
              ),
              _buildMilestone(
                context,
                'All Habits Done',
                state.disciplineScore >= 100
                    ? 'Achieved today!'
                    : '${state.disciplineScore.toInt()}% complete',
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
                    color: context.colors.textPrimary.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ...selectedGoals.map((goal) {
                  final title = goal['title'] as String? ?? 'Goal';
                  final category = goal['category'] as String? ?? 'General';
                  final current =
                      (goal['currentProgress'] as num?)?.toDouble() ?? 30.0;
                  final target = (goal['target'] as num?)?.toDouble() ?? 100.0;
                  final progress = (current / target).clamp(0.0, 1.0);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.textPrimary.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: context.colors.textPrimary.withValues(
                          alpha: 0.04,
                        ),
                      ),
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
                                color: AppColors.accentBlue.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.flag_rounded,
                                size: 18,
                                color: AppColors.accentBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: GoogleFonts.outfit(
                                      color: context.colors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    category,
                                    style: TextStyle(
                                      color: context.colors.textPrimary
                                          .withValues(alpha: 0.35),
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
                            backgroundColor: context.colors.textPrimary
                                .withValues(alpha: 0.04),
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.accentBlue,
                            ),
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
    BuildContext context,
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
                      : context.colors.textPrimary.withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: achieved
                        ? color
                        : context.colors.textPrimary.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  achieved ? Icons.check_rounded : icon,
                  size: 14,
                  color: achieved ? color : context.colors.textMuted,
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
                    : context.colors.textPrimary.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: achieved
                      ? color.withValues(alpha: 0.1)
                      : context.colors.textPrimary.withValues(alpha: 0.04),
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
                            color: achieved
                                ? context.colors.textPrimary
                                : context.colors.textSecondary,
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
                                : context.colors.textPrimary.withValues(
                                    alpha: 0.35,
                                  ),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (achieved)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
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

class _GoalsTab extends ConsumerStatefulWidget {
  const _GoalsTab();

  @override
  ConsumerState<_GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends ConsumerState<_GoalsTab> {
  String _selectedFilter = 'All';

  static final List<VisionItem> _sampleGoals = [
    VisionItem(
      id: 'sample_goal_1',
      type: VisionItemType.goal.name,
      content: 'Master Mobile Development',
      colorValue: const Color(0xFF3B82F6).toARGB32(),
      countdownDate: DateTime.now().add(const Duration(days: 150)),
      secondaryContent: 'Career & Skills',
      metadata: {
        'title': 'Master Mobile Development',
        'description':
            'Become a senior developer by mastering Flutter, Riverpod, and clean architecture.',
        'status': 'In Progress',
        'category': 'Career',
        'milestones': [
          {
            'id': 'sm_1',
            'title': 'Learn Advanced State Management',
            'description':
                'Master Riverpod providers, ref.watch, family, and notifier patterns.',
            'isCompleted': true,
            'order': 0,
          },
          {
            'id': 'sm_2',
            'title': 'Build Production Quality App',
            'description':
                'Release a complete App on App Store with local storage and syncing.',
            'isCompleted': false,
            'order': 1,
          },
        ],
      },
    ),
    VisionItem(
      id: 'sample_goal_2',
      type: VisionItemType.goal.name,
      content: 'Financial Independence',
      colorValue: const Color(0xFF10B981).toARGB32(),
      countdownDate: DateTime.now().add(const Duration(days: 300)),
      secondaryContent: 'Personal Finance',
      metadata: {
        'title': 'Financial Independence',
        'description': 'Build a diverse portfolio and save emergency funds.',
        'status': 'Completed',
        'category': 'Finance',
        'milestones': [
          {
            'id': 'sf_1',
            'title': 'Save 6-Month Emergency Fund',
            'description':
                'Keep emergency funds in a high-yield savings account.',
            'isCompleted': true,
            'order': 0,
          },
        ],
      },
    ),
    VisionItem(
      id: 'sample_goal_3',
      type: VisionItemType.goal.name,
      content: 'Run a Half Marathon',
      colorValue: const Color(0xFFEF4444).toARGB32(),
      countdownDate: DateTime.now().add(const Duration(days: 90)),
      secondaryContent: 'Health & Fitness',
      metadata: {
        'title': 'Run a Half Marathon',
        'description':
            'Train consistently to finish the local 21km race under 2 hours.',
        'status': 'On Hold',
        'category': 'Health',
        'milestones': [
          {
            'id': 'sh_1',
            'title': 'Weekly 15km Runs',
            'description':
                'Build endurance and steady pace during weekend long runs.',
            'isCompleted': false,
            'order': 0,
          },
        ],
      },
    ),
    VisionItem(
      id: 'sample_goal_4',
      type: VisionItemType.goal.name,
      content: 'Learn French Language',
      colorValue: const Color(0xFF8B5CF6).toARGB32(),
      countdownDate: DateTime.now().add(const Duration(days: 200)),
      secondaryContent: 'Education & Culture',
      metadata: {
        'title': 'Learn French Language',
        'description':
            'Practice daily vocabulary and conversation to reach B2 level.',
        'status': 'Not Started',
        'category': 'Education',
        'milestones': [
          {
            'id': 'sl_1',
            'title': 'Complete A1 Grammar course',
            'description': 'Study verbs, nouns, and core sentence structures.',
            'isCompleted': false,
            'order': 0,
          },
        ],
      },
    ),
  ];

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.textPrimary.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: context.colors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.outfit(
              color: context.colors.textPrimary.withValues(alpha: 0.5),
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatTargetDate(DateTime? date) {
    if (date == null) return 'Continuous';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getGoalStatus(VisionItem goal) {
    final progress = goal.smartProgressPercent;
    final metadata = goal.metadata ?? {};
    if (metadata['status'] != null) {
      return metadata['status'] as String;
    }

    // Dynamically calculate status if not specified
    if (progress == 100) return 'Completed';
    if (progress == 0) return 'Not Started';

    final title =
        (goal.content.isNotEmpty
                ? goal.content
                : (metadata['title'] as String? ?? ''))
            .toLowerCase();
    if (title.contains('hold') || title.contains('creative')) return 'On Hold';
    if (title.contains('travel') || title.contains('fitness'))
      return 'Not Started';
    if (title.contains('financial') || title.contains('freedom'))
      return 'In Progress';

    return 'On Track';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on track':
      case 'completed':
        return const Color(0xFF10B981);
      case 'in progress':
        return const Color(0xFFF59E0B);
      case 'not started':
        return const Color(0xFF3B82F6);
      case 'on hold':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF10B981);
    }
  }

  IconData _getGoalIcon(String title, Map metadata) {
    final lowercaseTitle = title.toLowerCase();
    if (lowercaseTitle.contains('launch') ||
        lowercaseTitle.contains('rocket') ||
        lowercaseTitle.contains('getzio')) {
      return Icons.rocket_launch_rounded;
    } else if (lowercaseTitle.contains('financial') ||
        lowercaseTitle.contains('freedom') ||
        lowercaseTitle.contains('money') ||
        lowercaseTitle.contains('wealth') ||
        lowercaseTitle.contains('save') ||
        lowercaseTitle.contains('finance') ||
        lowercaseTitle.contains('freedom')) {
      return Icons.savings_rounded;
    } else if (lowercaseTitle.contains('book') ||
        lowercaseTitle.contains('read') ||
        lowercaseTitle.contains('study') ||
        lowercaseTitle.contains('learn')) {
      return Icons.menu_book_rounded;
    } else if (lowercaseTitle.contains('fitness') ||
        lowercaseTitle.contains('gym') ||
        lowercaseTitle.contains('workout') ||
        lowercaseTitle.contains('health') ||
        lowercaseTitle.contains('transform')) {
      return Icons.fitness_center_rounded;
    } else if (lowercaseTitle.contains('flutter') ||
        lowercaseTitle.contains('code') ||
        lowercaseTitle.contains('master') ||
        lowercaseTitle.contains('program') ||
        lowercaseTitle.contains('develop')) {
      return Icons.code_rounded;
    } else if (lowercaseTitle.contains('habit') ||
        lowercaseTitle.contains('grow') ||
        lowercaseTitle.contains('daily') ||
        lowercaseTitle.contains('leaf') ||
        lowercaseTitle.contains('plant')) {
      return Icons.eco_rounded;
    } else if (lowercaseTitle.contains('travel') ||
        lowercaseTitle.contains('world') ||
        lowercaseTitle.contains('trip') ||
        lowercaseTitle.contains('flight') ||
        lowercaseTitle.contains('plane')) {
      return Icons.flight_rounded;
    } else if (lowercaseTitle.contains('creative') ||
        lowercaseTitle.contains('mastery') ||
        lowercaseTitle.contains('paint') ||
        lowercaseTitle.contains('art') ||
        lowercaseTitle.contains('palette')) {
      return Icons.palette_rounded;
    }

    final category = (metadata['category'] as String? ?? '').toLowerCase();
    if (category.contains('health')) return Icons.fitness_center_rounded;
    if (category.contains('finance')) return Icons.savings_rounded;
    if (category.contains('career') || category.contains('work'))
      return Icons.work_rounded;
    if (category.contains('education') || category.contains('learn'))
      return Icons.school_rounded;

    return Icons.flag_rounded;
  }

  bool _matchesFilter(String status, String filter) {
    if (filter == 'All') return true;
    if (filter == 'Active') {
      return status == 'On Track' ||
          status == 'In Progress' ||
          status == 'Not Started';
    }
    return status.toLowerCase() == filter.toLowerCase();
  }

  Widget _buildFilterTab({
    required String label,
    required int count,
    required Widget icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 82,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.accentBlue.withValues(alpha: 0.15)
              : context.colors.bg2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.colors.accentBlue.withValues(alpha: 0.5)
                : context.colors.glassBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                icon,
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colors.accentBlue
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1),
            Text(
              '$count',
              style: GoogleFonts.outfit(
                color: context.colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, VisionItem goal) {
    final metadata = goal.metadata ?? {};
    final title = goal.content.isNotEmpty
        ? goal.content
        : (metadata['title'] as String? ?? 'My Goal');
    final description = metadata['description'] as String? ?? 'No description';
    final progressPercent = goal.smartProgressPercent;

    final colorValue =
        metadata['color'] as int? ?? Colors.blueAccent.toARGB32();
    final themeColor = Color(colorValue);

    final status = _getGoalStatus(goal);
    final statusColor = _getStatusColor(status);
    final formattedDate = _formatTargetDate(goal.countdownDate);
    final goalIcon = _getGoalIcon(title, metadata);

    return GestureDetector(
      onTap: () {
        SmartObjectSheetRouter.open(context, goal);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: context.colors.bg2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.textPrimary.withOpacity(0.04),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Left Icon with themed circle background
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: themeColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(goalIcon, color: themeColor, size: 16),
            ),
            SizedBox(width: 12),

            // Title, description and target info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: context.colors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (goal.id.startsWith('sample_goal_')) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SAMPLE',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.outfit(
                      color: context.colors.textPrimary.withOpacity(0.4),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 9,
                        color: context.colors.textPrimary.withOpacity(0.3),
                      ),
                      Text(
                        'Target: $formattedDate',
                        style: GoogleFonts.outfit(
                          color: context.colors.textPrimary.withOpacity(0.3),
                          fontSize: 9.5,
                        ),
                      ),
                      Text(
                        '|',
                        style: GoogleFonts.outfit(
                          color: context.colors.textPrimary.withOpacity(0.15),
                          fontSize: 9.5,
                        ),
                      ),
                      // Status indicator dot
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        status,
                        style: GoogleFonts.outfit(
                          color: context.colors.textPrimary.withOpacity(0.3),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),

            // Circular Progress on the right
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    value: progressPercent / 100.0,
                    backgroundColor: context.colors.textPrimary.withOpacity(
                      0.05,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    strokeWidth: 3,
                  ),
                ),
                Text(
                  '$progressPercent%',
                  style: GoogleFonts.outfit(
                    color: context.colors.textPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(width: 8),

            // Right chevron
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.textPrimary.withOpacity(0.2),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasStateProvider);
    final realGoals = canvasState.items
        .where((item) => item.type == VisionItemType.goal.name)
        .toList();

    final isUsingSamples = false;
    final goals = realGoals;

    final allCount = goals.length;
    final activeCount = goals.where((g) {
      final s = _getGoalStatus(g);
      return s == 'On Track' || s == 'In Progress' || s == 'Not Started';
    }).length;
    final inProgressCount = goals
        .where((g) => _getGoalStatus(g) == 'In Progress')
        .length;
    final completedCount = goals
        .where((g) => _getGoalStatus(g) == 'Completed')
        .length;
    final onHoldCount = goals
        .where((g) => _getGoalStatus(g) == 'On Hold')
        .length;

    final filteredGoals = goals.where((g) {
      final status = _getGoalStatus(g);
      return _matchesFilter(status, _selectedFilter);
    }).toList();

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(color: context.colors.bg1),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MY GOALS',
                            style: GoogleFonts.outfit(
                              color: context.colors.textPrimary.withOpacity(
                                0.4,
                              ),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Target & Ambitions',
                            style: GoogleFonts.playfairDisplay(
                              color: context.colors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Horizontal Filter Scroll View
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
                  child: Row(
                    children: [
                      _buildFilterTab(
                        label: 'All',
                        count: allCount,
                        icon: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: context.colors.accentBlue.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.grid_view_rounded,
                            size: 14,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        isSelected: _selectedFilter == 'All',
                        onTap: () => setState(() => _selectedFilter = 'All'),
                      ),
                      SizedBox(width: 10),
                      _buildFilterTab(
                        label: 'Active',
                        count: activeCount,
                        icon: Icon(
                          Icons.play_circle_fill_rounded,
                          color: Color(0xFF10B981),
                          size: 15,
                        ),
                        isSelected: _selectedFilter == 'Active',
                        onTap: () => setState(() => _selectedFilter = 'Active'),
                      ),
                      SizedBox(width: 10),
                      _buildFilterTab(
                        label: 'In Progress',
                        count: inProgressCount,
                        icon: Icon(
                          Icons.timelapse_rounded,
                          color: Color(0xFFF59E0B),
                          size: 15,
                        ),
                        isSelected: _selectedFilter == 'In Progress',
                        onTap: () =>
                            setState(() => _selectedFilter = 'In Progress'),
                      ),
                      SizedBox(width: 10),
                      _buildFilterTab(
                        label: 'Completed',
                        count: completedCount,
                        icon: Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF8B5CF6),
                          size: 15,
                        ),
                        isSelected: _selectedFilter == 'Completed',
                        onTap: () =>
                            setState(() => _selectedFilter = 'Completed'),
                      ),
                      SizedBox(width: 10),
                      _buildFilterTab(
                        label: 'On Hold',
                        count: onHoldCount,
                        icon: Icon(
                          Icons.pause_circle_filled_rounded,
                          color: Color(0xFF3B82F6),
                          size: 15,
                        ),
                        isSelected: _selectedFilter == 'On Hold',
                        onTap: () =>
                            setState(() => _selectedFilter = 'On Hold'),
                      ),
                    ],
                  ),
                ),

                // Goals list
                Expanded(
                  child: filteredGoals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag_rounded,
                                size: 48,
                                color: context.colors.textMuted.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No goals in this category',
                                style: GoogleFonts.outfit(
                                  color: context.colors.textMuted,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Go to the Room tab to place your first goal',
                                style: TextStyle(
                                  color: context.colors.textPrimary.withOpacity(
                                    0.3,
                                  ),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            8,
                            20,
                            120,
                          ), // Padding bottom for banner
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredGoals.length,
                          itemBuilder: (context, index) {
                            return _buildGoalCard(
                              context,
                              filteredGoals[index],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

extension on _ProfileTab {
  Widget _buildUserProfileCard(BuildContext context, AuthUserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF1F5F9),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.amberAccent.withValues(alpha: 0.1)
                  : Colors.amberAccent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.amberAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isNotEmpty ? user.name : 'Focus Member',
                  style: GoogleFonts.outfit(
                    color: context.colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.mobile,
                  style: GoogleFonts.outfit(
                    color: context.colors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudSyncCard(
    BuildContext context,
    WidgetRef ref,
    bool isLoggedIn,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final syncStatus = ref.watch(cloudSyncStatusProvider);
    final pendingCount = syncStatus.pendingCount;

    String timeAgo(DateTime? dt) {
      if (dt == null) return 'Never';
      try {
        final diff = DateTime.now().difference(dt);
        if (diff.inSeconds < 30) {
          return 'Just now';
        } else if (diff.inMinutes < 1) {
          return 'Less than a minute ago';
        } else if (diff.inMinutes < 60) {
          final mins = diff.inMinutes;
          return '$mins minute${mins > 1 ? "s" : ""} ago';
        } else if (diff.inHours < 24) {
          final hrs = diff.inHours;
          return '$hrs hour${hrs > 1 ? "s" : ""} ago';
        } else {
          final format = DateFormat('MMM d, h:mm a');
          return format.format(dt);
        }
      } catch (_) {
        return 'Never';
      }
    }

    final String title = isLoggedIn ? 'Cloud Sync' : 'Local Workspace';
    final String description = isLoggedIn
        ? 'Last synced: ${timeAgo(syncStatus.lastSyncTime)}'
        : 'Your data is safely stored on this device.';

    final String statusText;
    final Color statusColor;
    final Color statusBg;

    switch (syncStatus.status) {
      case 'syncing':
        statusText = 'Syncing...';
        statusColor = const Color(0xFF3B82F6);
        statusBg = const Color(0xFF3B82F6).withValues(alpha: 0.15);
        break;
      case 'synced':
        statusText = 'Synced';
        statusColor = const Color(0xFF10B981);
        statusBg = const Color(0xFF10B981).withValues(alpha: 0.15);
        break;
      case 'failed':
        statusText = 'Sync Failed';
        statusColor = const Color(0xFFEF4444);
        statusBg = const Color(0xFFEF4444).withValues(alpha: 0.15);
        break;
      case 'offline':
        statusText = 'Offline';
        statusColor = const Color(0xFF64748B);
        statusBg = const Color(0xFF64748B).withValues(alpha: 0.15);
        break;
      case 'pending':
      default:
        statusText = '$pendingCount Pending';
        statusColor = const Color(0xFFF97316);
        statusBg = const Color(0xFFF97316).withValues(alpha: 0.15);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.bg2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: context.colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: GoogleFonts.outfit(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.outfit(
              color: context.colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          if (isLoggedIn) ...[
            _buildSyncDetailRow(
              context,
              'Last Sync',
              syncStatus.lastSyncTime != null
                  ? DateFormat('MMM d, h:mm a').format(syncStatus.lastSyncTime!)
                  : 'Never',
            ),
            if (pendingCount > 0) ...[
              const SizedBox(height: 6),
              _buildSyncDetailRow(context, 'Pending Changes', '$pendingCount'),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  final connectivityResult = await Connectivity()
                      .checkConnectivity();
                  final isOnline =
                      connectivityResult.isNotEmpty &&
                      connectivityResult.any(
                        (r) => r != ConnectivityResult.none,
                      );
                  if (!isOnline) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(
                                Icons.wifi_off_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'You are offline. Connect to internet to sync.',
                              ),
                            ],
                          ),
                          backgroundColor: Colors.grey[850],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                    return;
                  }
                  ref.read(syncQueueServiceProvider).processQueue();
                },
                icon: const Icon(Icons.sync_rounded, size: 14),
                label: const Text('Sync Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Save to Cloud',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: context.colors.textSecondary,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: context.colors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sign Out',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to sign out? This will remove your account data from this device. (Your cloud database will not be affected).',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await ref
                        .read(authProvider.notifier)
                        .logout(keepLocalData: false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    fixedSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Yes, Sign Out',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
                    side: BorderSide(
                      color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                    fixedSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'No, Go Back',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _restoreData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: FutureBuilder(
              future: GuestDataMigrationService.reloadFromBackend(ref),
              builder: (futureContext, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Restoring Workspace...',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Downloading your data from the cloud...',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Restore Failed',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(futureContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.green,
                        size: 40,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Workspace Restored',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'All your backup data has been successfully restored to this device.',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(futureContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Continue'),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
