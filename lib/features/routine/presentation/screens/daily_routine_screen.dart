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

class _DailyRoutineScreenState extends ConsumerState<DailyRoutineScreen> with TickerProviderStateMixin {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Ambient glows offset coordinates
  final Offset _glow1 = const Offset(-100, -50);
  final Offset _glow2 = const Offset(200, 300);

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
      {'title': 'Complete My Most Important Task', 'subtitle': 'Beat procrastination'},
      {'title': 'Deep Work Session', 'subtitle': 'Focused distraction-free time'},
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
    ]
  };

  void _showCreateRoutineSheet(BuildContext context) {
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF12141C).withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Routine',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFBF7F0), // Warm Cream
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  style: GoogleFonts.outfit(color: const Color(0xFFF5EFEB)),
                  decoration: InputDecoration(
                    hintText: 'Example: Learn Flutter',
                    hintStyle: GoogleFonts.outfit(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFEAD2AC)), // Soft Gold
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.outfit(
                            color: Colors.white38,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final title = nameController.text.trim();
                          if (title.isNotEmpty) {
                            ref.read(routineProvider.notifier).addRoutine(title);
                            Navigator.pop(context);
                            _showPremiumToast(context, 'Custom routine added');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAD2AC), // Soft Gold
                          foregroundColor: const Color(0xFF0F1115),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFFEAD2AC).withOpacity(0.3),
                        ),
                        child: Text(
                          'Save',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                  color: const Color(0xFF12141C).withOpacity(0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
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
                      child: ListView(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        children: [
                          ..._suggestedCategories.entries.map((entry) {
                            final categoryTitle = entry.key;
                            final list = entry.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20, bottom: 10, left: 4),
                                  child: Text(
                                    categoryTitle,
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFEAD2AC), // Soft Gold
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                ...list.map((item) {
                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      ref.read(routineProvider.notifier).addRoutine(
                                        item['title']!,
                                        item['subtitle'],
                                      );
                                      Navigator.pop(context);
                                      _showPremiumToast(context, '${item['title']} added');
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.02),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['title']!,
                                                  style: GoogleFonts.outfit(
                                                    color: const Color(0xFFFBF7F0),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                if (item['subtitle'] != null) ...[
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
                                            Icons.add_circle_outline_rounded,
                                            color: const Color(0xFFEAD2AC).withOpacity(0.7),
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
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showCreateRoutineSheet(context);
                            },
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: Text(
                              'Create Custom Routine',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.04),
                              foregroundColor: const Color(0xFFEAD2AC),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: const Color(0xFFEAD2AC).withOpacity(0.2)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
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
          side: BorderSide(color: const Color(0xFFEAD2AC).withOpacity(0.2)),
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
              side: BorderSide(color: Colors.white.withOpacity(0.08)),
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
                  style: GoogleFonts.outfit(color: Colors.white38, fontWeight: FontWeight.bold),
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
                  style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final routines = ref.watch(routineProvider);
    final todayStr = _dateFormat.format(DateTime.now());

    final completedCount = routines.where((r) => r.completedDates.contains(todayStr)).length;
    final totalCount = routines.length;
    final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;

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

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115), // Dark Luxury
      body: Stack(
        children: [
          // Ambient Glow Light 1
          Positioned(
            left: _glow1.dx,
            top: _glow1.dy,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEAD2AC).withOpacity(0.03), // Soft Gold
                    blurRadius: 100,
                    spreadRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          // Ambient Glow Light 2
          Positioned(
            right: _glow2.dx,
            top: _glow2.dy,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFBF7F0).withOpacity(0.02), // Soft Cream
                    blurRadius: 120,
                    spreadRadius: 120,
                  ),
                ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Text & Circular Progress
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Morning, Syed 👋',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFBF7F0).withOpacity(0.6), // Warm Cream opaque
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Today's Progress",
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFBF7F0),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  // Glowing Circular Progress Ring
                                  SizedBox(
                                    width: 52,
                                    height: 52,
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0, end: progress),
                                      duration: const Duration(milliseconds: 1000),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, val, child) {
                                        return CustomPaint(
                                          painter: _ProgressRingPainter(
                                            progress: val,
                                            baseColor: Colors.white.withOpacity(0.06),
                                            progressColor: const Color(0xFFEAD2AC), // Soft Gold
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${(val * 100).toInt()}%',
                                              style: GoogleFonts.outfit(
                                                color: const Color(0xFFFBF7F0),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$completedCount of $totalCount routines',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFFBF7F0),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'completed today',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white38,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right Side Artwork Card (Hero Illustration)
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.95, end: 1.0),
                          duration: const Duration(seconds: 4),
                          curve: Curves.easeInOutSine,
                          builder: (context, val, child) {
                            return Transform.scale(
                              scale: val,
                              child: Container(
                                width: 115,
                                height: 115,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(23),
                                  child: Image.asset(
                                    'assets/images/cozy_scandinavian_sunrise.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Main Routine List
                if (routines.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFEAD2AC).withOpacity(0.05),
                              border: Border.all(color: const Color(0xFFEAD2AC).withOpacity(0.15)),
                            ),
                            child: const Icon(
                              Icons.spa_rounded,
                              size: 48,
                              color: Color(0xFFEAD2AC),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Build your perfect day.',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFBF7F0),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Create routines that help you become the person you want to be.',
                            style: GoogleFonts.outfit(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () => _showSuggestedLibrarySheet(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEAD2AC),
                              foregroundColor: const Color(0xFF0F1115),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFFEAD2AC).withOpacity(0.3),
                            ),
                            child: Text(
                              'Create First Routine',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = routines[index];
                          final isCompleted = item.completedDates.contains(todayStr);

                          return AnimatedOpacity(
                            opacity: isCompleted ? 0.55 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: GestureDetector(
                              onLongPress: () => _showDeleteConfirmDialog(context, item),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(isCompleted ? 0.02 : 0.04),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(isCompleted ? 0.04 : 0.08),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Custom Rounded Checkbox
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.mediumImpact();
                                        ref.read(routineProvider.notifier).toggleRoutineCompletion(
                                          item.id,
                                          todayStr,
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isCompleted ? const Color(0xFFEAD2AC) : Colors.transparent,
                                          border: Border.all(
                                            color: isCompleted ? const Color(0xFFEAD2AC) : Colors.white24,
                                            width: 2,
                                          ),
                                        ),
                                        child: isCompleted
                                            ? const Icon(
                                                Icons.check_rounded,
                                                color: Color(0xFF0F1115),
                                                size: 18,
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Text Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFFFBF7F0),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                          if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              item.subtitle!,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white38,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: routines.length,
                      ),
                    ),
                  ),
                  // Suggested Routines Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 12),
                      child: Text(
                        'Suggested Routines',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFBF7F0),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 50,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: quickChips.length,
                        itemBuilder: (context, index) {
                          final chip = quickChips[index];
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(routineProvider.notifier).addRoutine(
                                '${chip['emoji']} ${chip['title']}',
                              );
                              _showPremiumToast(context, '${chip['title']} added');
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFEAD2AC).withOpacity(0.12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    chip['emoji']!,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    chip['title']!,
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFFBF7F0).withOpacity(0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: routines.isEmpty
          ? null
          : Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEAD2AC).withOpacity(0.15),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _showSuggestedLibrarySheet(context),
                backgroundColor: const Color(0xFF161A22).withOpacity(0.85),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: const Color(0xFFEAD2AC).withOpacity(0.2)),
                ),
                icon: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFFEAD2AC),
                  size: 24,
                ),
                label: Text(
                  'New Routine',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFBF7F0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
      ..color = progressColor.withOpacity(0.25)
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
