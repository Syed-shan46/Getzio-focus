import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/routine_providers.dart';
import '../../domain/models/routine_item.dart';

class DailyRoutineScreen extends ConsumerStatefulWidget {
  const DailyRoutineScreen({super.key});

  @override
  ConsumerState<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends ConsumerState<DailyRoutineScreen> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Suggested routines categories
  final Map<String, List<Map<String, String>>> _suggestedCategories = {
    '🌅 Morning': [
      {'title': 'Wake Up Early', 'subtitle': 'Start the day productively'},
      {'title': 'Make Your Bed', 'subtitle': 'Quick daily win'},
      {'title': 'Drink Water', 'subtitle': 'Rehydrate your body'},
      {'title': 'Morning Stretch', 'subtitle': 'Awaken your muscles'},
      {'title': 'Morning Walk', 'subtitle': 'Fresh air and light'},
      {'title': 'Morning Prayer / Meditation', 'subtitle': 'Find inner peace'},
      {'title': 'Avoid Phone After Waking', 'subtitle': 'Keep mind calm'},
    ],
    '💪 Health & Fitness': [
      {'title': 'Exercise', 'subtitle': 'Keep your body strong'},
      {'title': 'Walk', 'subtitle': 'Daily step goal'},
      {'title': 'Run', 'subtitle': 'Cardio training'},
      {'title': 'Yoga', 'subtitle': 'Flexibility and breathing'},
      {'title': 'Stretch', 'subtitle': 'Relax muscles'},
      {'title': 'Drink Enough Water', 'subtitle': 'Optimal hydration'},
      {'title': 'Eat Healthy', 'subtitle': 'Nourish your body'},
      {'title': 'Eat Fruits', 'subtitle': 'Vitamins and energy'},
      {'title': 'Take Vitamins', 'subtitle': 'Nutritional support'},
      {'title': 'Sleep Before 10:30 PM', 'subtitle': 'Consistent rest'},
    ],
    '📚 Learning': [
      {'title': 'Read a Book', 'subtitle': 'Gain new knowledge'},
      {'title': 'Learn English', 'subtitle': 'Improve vocabulary'},
      {'title': 'Practice English Speaking', 'subtitle': 'Gain confidence'},
      {'title': 'Learn Coding', 'subtitle': 'Write clean code'},
      {'title': 'Watch an Educational Video', 'subtitle': 'Quick learning'},
      {'title': 'Learn a New Skill', 'subtitle': 'Expand capabilities'},
      {'title': 'Practice Writing', 'subtitle': 'Clarify thoughts'},
    ],
    '🎯 Productivity': [
      {'title': 'Plan My Day', 'subtitle': 'Organize schedules'},
      {
        'title': 'Complete My Most Important Task',
        'subtitle': 'Beat procrastination',
      },
      {
        'title': 'Deep Work Session',
        'subtitle': 'Focused distraction-free time',
      },
      {'title': 'Review Goals', 'subtitle': 'Stay on track'},
      {'title': 'Clean Workspace', 'subtitle': 'Clear desk, clear mind'},
      {'title': 'Organize Desk', 'subtitle': 'Tidy environment'},
      {'title': 'Check Email', 'subtitle': 'Process inbox'},
    ],
    '🧘 Mindfulness': [
      {'title': 'Meditation', 'subtitle': 'Calm the mind'},
      {'title': 'Deep Breathing', 'subtitle': 'Relieve stress'},
      {'title': 'Gratitude Journal', 'subtitle': 'List three things'},
      {'title': 'Daily Affirmations', 'subtitle': 'Positive self-talk'},
      {'title': 'Reflect on Today', 'subtitle': 'Evening self-reflection'},
      {'title': 'No Social Media', 'subtitle': 'Digital detox'},
    ],
    '💰 Finance': [
      {'title': 'Track Expenses', 'subtitle': 'Monitor spending'},
      {'title': 'Save Money', 'subtitle': 'Build wealth'},
      {'title': 'Review Budget', 'subtitle': 'Stay within limits'},
      {'title': 'Check Investments', 'subtitle': 'Long term tracking'},
      {'title': 'Avoid Unnecessary Spending', 'subtitle': 'Frugal mind'},
    ],
    '❤️ Personal': [
      {'title': 'Call Parents', 'subtitle': 'Stay connected'},
      {'title': 'Spend Time with Family', 'subtitle': 'Prioritize loved ones'},
      {'title': 'Talk to Friends', 'subtitle': 'Social wellness'},
      {'title': 'Help Someone', 'subtitle': 'Act of kindness'},
      {'title': 'Read Spiritual Texts', 'subtitle': 'Inner growth'},
      {'title': 'Practice Kindness', 'subtitle': 'Spread positivity'},
    ],
    '🌙 Evening': [
      {'title': 'Prepare Tomorrow\'s Plan', 'subtitle': 'Set morning targets'},
      {'title': 'Review Today\'s Progress', 'subtitle': 'Reflect on wins'},
      {'title': 'Read Before Bed', 'subtitle': 'Relaxing reading'},
      {'title': 'Sleep on Time', 'subtitle': 'Consistent bedtime'},
      {'title': 'Digital Detox', 'subtitle': 'No screens 1 hour before sleep'},
      {'title': 'Organize Tomorrow\'s Tasks', 'subtitle': 'Ready for tomorrow'},
    ],
  };

  void _showSuggestedLibrarySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF12141C).withValues(alpha: 0.95),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Routine Library',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFBF7F0), // Warm Cream
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final currentRoutines = ref.watch(routineProvider);

                          return ListView(
                            controller: controller,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            children: [
                              ..._suggestedCategories.entries.map((entry) {
                                final categoryTitle = entry.key;
                                final list = entry.value;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 20,
                                        bottom: 10,
                                        left: 4,
                                      ),
                                      child: Text(
                                        categoryTitle,
                                        style: GoogleFonts.outfit(
                                          color: const Color(
                                            0xFFEAD2AC,
                                          ), // Soft Gold
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    ...list.map((item) {
                                      final itemTitleClean = item['title']!
                                          .replaceAll(RegExp(r'^[^\w\s]+'), '')
                                          .trim()
                                          .toLowerCase();

                                      RoutineItem? existingItem;
                                      for (final r in currentRoutines) {
                                        final rTitleClean = r.title
                                            .replaceAll(RegExp(r'^[^\w\s]+'), '')
                                            .trim()
                                            .toLowerCase();
                                        if (rTitleClean == itemTitleClean ||
                                            r.title.toLowerCase().contains(itemTitleClean)) {
                                          existingItem = r;
                                          break;
                                        }
                                      }

                                      final isAdded = existingItem != null;

                                      return GestureDetector(
                                        onTap: () {
                                          HapticFeedback.mediumImpact();
                                          if (isAdded) {
                                            ref
                                                .read(routineProvider.notifier)
                                                .deleteRoutine(existingItem!.id);
                                            _showPremiumToast(
                                              context,
                                              '${item['title']} removed',
                                            );
                                          } else {
                                            ref
                                                .read(routineProvider.notifier)
                                                .addRoutine(
                                                  item['title']!,
                                                  item['subtitle'],
                                                );
                                            _showPremiumToast(
                                              context,
                                              '${item['title']} added',
                                            );
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: isAdded
                                                ? const Color(0xFFEAD2AC).withValues(alpha: 0.08)
                                                : Colors.white.withValues(
                                                    alpha: 0.02,
                                                  ),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isAdded
                                                  ? const Color(0xFFEAD2AC).withValues(alpha: 0.3)
                                                  : Colors.white.withValues(
                                                      alpha: 0.05,
                                                    ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item['title']!,
                                                      style: GoogleFonts.outfit(
                                                        color: const Color(
                                                          0xFFFBF7F0,
                                                        ),
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    if (item['subtitle'] !=
                                                        null) ...[
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        item['subtitle']!,
                                                        style: GoogleFonts.outfit(
                                                          color: Colors.white38,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                isAdded
                                                    ? Icons.check_circle_rounded
                                                    : Icons.add_circle_outline_rounded,
                                                color: isAdded
                                                    ? const Color(0xFFEAD2AC)
                                                    : const Color(
                                                        0xFFEAD2AC,
                                                      ).withValues(alpha: 0.7),
                                                size: 22,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                );
                              }),
                              const SizedBox(height: 24),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showPremiumToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFFEAD2AC), size: 20),
            const SizedBox(width: 12),
            Text(
              message,
              style: GoogleFonts.outfit(
                color: const Color(0xFFFBF7F0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF161A22),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFFEAD2AC).withValues(alpha: 0.2),
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, RoutineItem routine) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: const Color(0xFF12141C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            title: Text(
              'Remove Routine',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFBF7F0),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to remove "${routine.title}"?',
              style: GoogleFonts.outfit(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(routineProvider.notifier).deleteRoutine(routine.id);
                  Navigator.pop(context);
                  _showPremiumToast(context, 'Routine deleted');
                },
                child: Text(
                  'Delete',
                  style: GoogleFonts.outfit(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper mapping routine titles to matching icons and theme colors
  Map<String, dynamic> _getRoutineIconAndColor(String title) {
    final t = title.toLowerCase();
    if (t.contains('wake')) {
      return {
        'icon': Icons.wb_sunny_rounded,
        'bg': const Color(0xFFEAB308).withValues(alpha: 0.15),
        'fg': const Color(0xFFF59E0B),
      };
    } else if (t.contains('water') ||
        t.contains('hydration') ||
        t.contains('drink')) {
      return {
        'icon': Icons.water_drop_rounded,
        'bg': const Color(0xFF3B82F6).withValues(alpha: 0.15),
        'fg': const Color(0xFF60A5FA),
      };
    } else if (t.contains('run') ||
        t.contains('walk') ||
        t.contains('exercise') ||
        t.contains('gym') ||
        t.contains('stretch') ||
        t.contains('workout') ||
        t.contains('yoga')) {
      return {
        'icon': Icons.directions_run_rounded,
        'bg': const Color(0xFF8B5CF6).withValues(alpha: 0.15),
        'fg': const Color(0xFFA78BFA),
      };
    } else if (t.contains('word') ||
        t.contains('learn') ||
        t.contains('skill') ||
        t.contains('study') ||
        t.contains('coding') ||
        t.contains('flutter')) {
      return {
        'icon': Icons.menu_book_rounded,
        'bg': const Color(0xFF10B981).withValues(alpha: 0.15),
        'fg': const Color(0xFF34D399),
      };
    } else if (t.contains('speak') ||
        t.contains('practice') ||
        t.contains('talk')) {
      return {
        'icon': Icons.mic_rounded,
        'bg': const Color(0xFFF97316).withValues(alpha: 0.15),
        'fg': const Color(0xFFFB923C),
      };
    } else if (t.contains('sleep') ||
        t.contains('bed') ||
        t.contains('night') ||
        t.contains('detox')) {
      return {
        'icon': Icons.dark_mode_rounded,
        'bg': const Color(0xFF6366F1).withValues(alpha: 0.15),
        'fg': const Color(0xFF818CF8),
      };
    } else if (t.contains('read') || t.contains('book')) {
      return {
        'icon': Icons.menu_book_rounded,
        'bg': const Color(0xFFD97706).withValues(alpha: 0.15),
        'fg': const Color(0xFFFBBF24),
      };
    }
    // Default fallback
    return {
      'icon': Icons.spa_rounded,
      'bg': const Color(0xFFEAD2AC).withValues(alpha: 0.15),
      'fg': const Color(0xFFEAD2AC),
    };
  }

  @override
  Widget build(BuildContext context) {
    final routines = ref.watch(routineProvider);
    final todayStr = _dateFormat.format(DateTime.now());

    final completedCount = routines
        .where((r) => r.completedDates.contains(todayStr))
        .length;
    final totalCount = routines.length;
    final progressVal = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    // Sort routines: active uncompleted routines first, completed routines at bottom
    final sortedRoutines = [...routines]
      ..sort((a, b) {
        final aDone = a.completedDates.contains(todayStr);
        final bDone = b.completedDates.contains(todayStr);
        if (aDone && !bDone) return 1;
        if (!aDone && bDone) return -1;
        return 0;
      });

    // Quick chips routines
    final List<Map<String, String>> quickChips = [
      {'emoji': '💧', 'title': 'Drink Water'},
      {'emoji': '🏃', 'title': 'Exercise'},
      {'emoji': '📚', 'title': 'Read Books'},
      {'emoji': '🗣', 'title': 'Practice English'},
      {'emoji': '💻', 'title': 'Coding'},
      {'emoji': '🙏', 'title': 'Prayer'},
      {'emoji': '🧘', 'title': 'Meditation'},
      {'emoji': '🚶', 'title': 'Walk'},
      {'emoji': '🛏', 'title': 'Sleep Early'},
      {'emoji': '🍎', 'title': 'Eat Healthy'},
    ];

    // Responsive app screen padding
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 32.0 : 16.0;

    // Theme based checks
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenBgColor = isDark ? const Color(0xFF0F1115) : context.colors.bg1;
    final cardBgColor = isDark
        ? const Color(0xFF161A22).withValues(alpha: 0.6)
        : context.colors.bg2;
    final headerTextColor = isDark
        ? const Color(0xFFFBF7F0)
        : context.colors.textPrimary;
    final labelColor = isDark
        ? const Color(0xFFEAD2AC)
        : context.colors.accentBlue;

    return Scaffold(
      backgroundColor: screenBgColor,
      body: Stack(
        children: [
          // Ambient Glow Light 1
          if (isDark)
            Positioned(
              left: -100,
              top: -50,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFFEAD2AC,
                      ).withValues(alpha: 0.03), // Soft Gold
                      blurRadius: 100,
                      spreadRadius: 100,
                    ),
                  ],
                ),
              ),
            ),
          // Ambient Glow Light 2
          if (isDark)
            Positioned(
              right: 200,
              top: 300,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFFFBF7F0,
                      ).withValues(alpha: 0.02), // Soft Cream
                      blurRadius: 120,
                      spreadRadius: 120,
                    ),
                  ],
                ),
              ),
            ),
          // Top Right Hero Room Overlay (routine_img.png)
          Positioned(
            top: 0,
            right: 0,
            width: MediaQuery.of(context).size.width * 0.55,
            height: 250,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.5],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.transparent, Colors.black],
                    stops: [0.0, 0.45],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/routine_img.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topRight,
                ),
              ),
            ),
          ),
          // Main Scrollable Area
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Hero Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: 20,
                      bottom: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning ☀️',
                          style: GoogleFonts.outfit(
                            color: labelColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Today is a\nnew opportunity.",
                          style: GoogleFonts.gelasio(
                            color: headerTextColor,
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            height: 1.18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Small actions, big changes.',
                          style: GoogleFonts.outfit(
                            color: headerTextColor.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Today's Progress Card
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Upper Label Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TODAY'S PROGRESS",
                              style: GoogleFonts.outfit(
                                color: labelColor.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              "Keep going! 🔥",
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFF97316),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Inner Content Row
                        Row(
                          children: [
                            // Circular Progress Ring
                            SizedBox(
                              width: 68,
                              height: 68,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: 0,
                                  end: progressVal,
                                ),
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeOutCubic,
                                builder: (context, val, child) {
                                  return CustomPaint(
                                    painter: _ProgressRingPainter(
                                      progress: val,
                                      baseColor: isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                      progressColor: labelColor,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${(val * 100).toInt()}%',
                                            style: GoogleFonts.outfit(
                                              color: headerTextColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Completed',
                                            style: GoogleFonts.outfit(
                                              color: headerTextColor.withValues(
                                                alpha: 0.4,
                                              ),
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Stats Info Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '"Discipline today, freedom tomorrow."',
                                    style: GoogleFonts.gelasio(
                                      color: headerTextColor,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _buildStatItem(
                                        Icons.star_rounded,
                                        '$completedCount',
                                        'Completed',
                                        labelColor,
                                      ),
                                      const SizedBox(width: 20),
                                      Container(
                                        width: 1,
                                        height: 20,
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.1,
                                              ),
                                      ),
                                      const SizedBox(width: 20),
                                      _buildStatItem(
                                        Icons.adjust_rounded,
                                        '$totalCount',
                                        'Total',
                                        labelColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Today's Routines Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              color: labelColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "TODAY'S ROUTINES",
                              style: GoogleFonts.outfit(
                                color: headerTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _showSuggestedLibrarySheet(context),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: labelColor,
                              boxShadow: [
                                BoxShadow(
                                  color: labelColor.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Color(0xFF0F1115),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Routines List
                if (routines.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 40,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: labelColor.withValues(alpha: 0.05),
                              border: Border.all(
                                color: labelColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Icon(
                              Icons.spa_rounded,
                              size: 40,
                              color: labelColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Build your perfect day.',
                            style: GoogleFonts.outfit(
                              color: headerTextColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create routines that help you become the person you want to be.',
                            style: GoogleFonts.outfit(
                              color: headerTextColor.withValues(alpha: 0.4),
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () =>
                                _showSuggestedLibrarySheet(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: labelColor,
                              foregroundColor: const Color(0xFF0F1115),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 6,
                              shadowColor: labelColor.withValues(alpha: 0.3),
                            ),
                            child: Text(
                              'Create First Routine',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = sortedRoutines[index];
                        final isCompleted = item.completedDates.contains(
                          todayStr,
                        );
                        final designStyle = _getRoutineIconAndColor(item.title);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? cardBgColor.withValues(alpha: 0.4)
                                : cardBgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.03),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Icon Box Container
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: designStyle['bg'] as Color,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(
                                  designStyle['icon'] as IconData,
                                  color: designStyle['fg'] as Color,
                                  size: 17,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Text Content block
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: GoogleFonts.outfit(
                                        color: isCompleted
                                            ? headerTextColor.withValues(
                                                alpha: 0.5,
                                              )
                                            : headerTextColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    if (item.subtitle != null &&
                                        item.subtitle!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle!,
                                        style: GoogleFonts.outfit(
                                          color: headerTextColor.withValues(
                                            alpha: 0.35,
                                          ),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Check Circle Outline or Checked Circle
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  ref
                                      .read(routineProvider.notifier)
                                      .toggleRoutineCompletion(
                                        item.id,
                                        todayStr,
                                      );
                                },
                                onLongPress: () =>
                                    _showDeleteConfirmDialog(context, item),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCompleted
                                        ? labelColor
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isCompleted
                                          ? labelColor
                                          : headerTextColor.withValues(
                                              alpha: 0.2,
                                            ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isCompleted
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Color(0xFF0F1115),
                                          size: 12,
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: sortedRoutines.length),
                    ),
                  ),
                // Suggested Routines Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 16,
                      left: horizontalPadding,
                      right: horizontalPadding,
                      bottom: 8,
                    ),
                    child: Text(
                      'Suggested Routines',
                      style: GoogleFonts.outfit(
                        color: headerTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding - 4,
                      ),
                      itemCount: quickChips.length,
                      itemBuilder: (context, index) {
                        final chip = quickChips[index];
                        final chipTitleClean = chip['title']!
                            .replaceAll(RegExp(r'^[^\w\s]+'), '')
                            .trim()
                            .toLowerCase();

                        RoutineItem? existingChipRoutine;
                        for (final r in routines) {
                          final rTitleClean = r.title
                              .replaceAll(RegExp(r'^[^\w\s]+'), '')
                              .trim()
                              .toLowerCase();
                          if (rTitleClean == chipTitleClean ||
                              r.title.toLowerCase().contains(chipTitleClean)) {
                            existingChipRoutine = r;
                            break;
                          }
                        }

                        final isChipAdded = existingChipRoutine != null;

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            if (isChipAdded) {
                              ref
                                  .read(routineProvider.notifier)
                                  .deleteRoutine(existingChipRoutine!.id);
                              _showPremiumToast(
                                context,
                                '${chip['title']} removed',
                              );
                            } else {
                              ref
                                  .read(routineProvider.notifier)
                                  .addRoutine(
                                    '${chip['emoji']} ${chip['title']}',
                                  );
                              _showPremiumToast(
                                context,
                                '${chip['title']} added',
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isChipAdded
                                  ? labelColor.withValues(alpha: 0.18)
                                  : cardBgColor.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isChipAdded
                                    ? labelColor.withValues(alpha: 0.5)
                                    : labelColor.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  chip['emoji']!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  chip['title']!,
                                  style: GoogleFonts.outfit(
                                    color: headerTextColor.withValues(
                                      alpha: 0.9,
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  isChipAdded
                                      ? Icons.check_rounded
                                      : Icons.add_rounded,
                                  color: isChipAdded
                                      ? labelColor
                                      : headerTextColor.withValues(alpha: 0.4),
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String val, String sub, Color accent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerTextColor = isDark
        ? const Color(0xFFFBF7F0)
        : context.colors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent, size: 14),
            const SizedBox(width: 4),
            Text(
              val,
              style: GoogleFonts.outfit(
                color: headerTextColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          style: GoogleFonts.outfit(
            color: headerTextColor.withValues(alpha: 0.4),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// 🎨 Circular Progress Painter
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final Color progressColor;

  _ProgressRingPainter({
    required this.progress,
    required this.baseColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 5.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw base background ring
    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, basePaint);

    if (progress <= 0) return;

    // Draw glow shadow for progress
    final shadowPaint = Paint()
      ..color = progressColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      shadowPaint,
    );

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
