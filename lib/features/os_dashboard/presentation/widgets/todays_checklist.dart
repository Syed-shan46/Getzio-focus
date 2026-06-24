import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../onboarding/domain/models/onboarding_models.dart';
import '../providers/os_providers.dart';

class _CategoryTab {
  final String label;
  final String? category;
  final IconData icon;
  final Color color;

  const _CategoryTab({
    required this.label,
    this.category,
    required this.icon,
    required this.color,
  });
}

class TodaysChecklist extends ConsumerStatefulWidget {
  final bool showTitle;
  const TodaysChecklist({super.key, this.showTitle = true});

  @override
  ConsumerState<TodaysChecklist> createState() => _TodaysChecklistState();
}

class _TodaysChecklistState extends ConsumerState<TodaysChecklist> {
  int _selectedTabIndex = 0;

  static const _tabs = [
    _CategoryTab(label: 'All', icon: Icons.explore_rounded, color: Colors.white),
    _CategoryTab(label: 'Morning', category: 'Morning', icon: Icons.wb_sunny_rounded, color: Color(0xFFFFA726)),
    _CategoryTab(label: 'Health', category: 'Health', icon: Icons.favorite_rounded, color: Color(0xFFEF5350)),
    _CategoryTab(label: 'Growth', category: 'Personal Development', icon: Icons.auto_stories_rounded, color: AppColors.accentBlue),
    _CategoryTab(label: 'Home', category: 'Home', icon: Icons.home_rounded, color: Color(0xFF66BB6A)),
  ];

  void _showEditHabitsSheet(BuildContext context, WidgetRef ref, List<UserHabit> selectedHabits) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EditHabitsBottomSheet(initialSelected: selectedHabits);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(osStateProvider);
    final selectedHabits = state.selectedHabits;
    final completedHabitIds = state.completedHabitIdsToday;

    final activeCategory = _tabs[_selectedTabIndex].category;
    final filteredHabits = activeCategory == null
        ? selectedHabits
        : selectedHabits.where((h) => h.category == activeCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showTitle)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12, right: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Today's Checklist",
                    style: AppTypography.titleMedium(color: Colors.white).copyWith(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showEditHabitsSheet(context, ref, selectedHabits),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded, color: AppColors.accentBlue, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: AppTypography.captionSmall(color: AppColors.accentBlue).copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 8),
              child: GestureDetector(
                onTap: () => _showEditHabitsSheet(context, ref, selectedHabits),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, color: AppColors.accentBlue, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        'Edit',
                        style: AppTypography.captionSmall(color: AppColors.accentBlue).copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // ── Category Tabs ──
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: _tabs.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final tab = _tabs[index];
              final isSelected = _selectedTabIndex == index;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedTabIndex = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? tab.color.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? tab.color.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.06),
                      width: isSelected ? 1.2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tab.icon, size: 15, color: isSelected ? tab.color : Colors.white38),
                      const SizedBox(width: 6),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? tab.color : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        if (filteredHabits.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: GlassDecoration.card(),
            child: Column(
              children: [
                Icon(
                  _tabs[_selectedTabIndex].icon,
                  color: Colors.white30,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  activeCategory == null ? 'No habits selected' : 'No $activeCategory habits',
                  style: AppTypography.titleMedium(color: Colors.white70).copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  activeCategory == null
                      ? 'Tap "Edit" above to configure your schedule.'
                      : 'Select some $activeCategory habits to see them here.',
                  style: AppTypography.caption(color: Colors.white30),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: filteredHabits.map((habit) {
              final isCompleted = completedHabitIds.contains(habit.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ChecklistItemWidget(
                  habit: habit,
                  isCompleted: isCompleted,
                  onToggle: () {
                    ref.read(osStateProvider.notifier).toggleHabitCompletion(habit.id);
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INTERACTIVE CHECKLIST ITEM WIDGET (SMALL CARD)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ChecklistItemWidget extends StatefulWidget {
  final UserHabit habit;
  final bool isCompleted;
  final VoidCallback onToggle;

  const ChecklistItemWidget({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  State<ChecklistItemWidget> createState() => _ChecklistItemWidgetState();
}

class _ChecklistItemWidgetState extends State<ChecklistItemWidget> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _particleController;
  bool _isPlayingParticles = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _particleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isPlayingParticles = false;
        });
        _particleController.reset();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleController.reverse().then((_) => _scaleController.forward());
    HapticFeedback.lightImpact();

    if (!widget.isCompleted) {
      setState(() {
        _isPlayingParticles = true;
      });
      _particleController.forward(from: 0.0);
    }
    
    widget.onToggle();
  }

  Color _categoryColor() {
    switch (widget.habit.category) {
      case 'Morning':
        return const Color(0xFFFFA726);
      case 'Health':
        return const Color(0xFFEF5350);
      case 'Personal Development':
        return AppColors.accentBlue;
      case 'Home':
        return const Color(0xFF66BB6A);
      default:
        return AppColors.accentEmerald;
    }
  }

  IconData _categoryIcon() {
    switch (widget.habit.category) {
      case 'Morning':
        return Icons.wb_sunny_rounded;
      case 'Health':
        return Icons.favorite_rounded;
      case 'Personal Development':
        return Icons.auto_stories_rounded;
      case 'Home':
        return Icons.home_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor();
    final isCompleted = widget.isCompleted;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleController.value,
            child: child,
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isCompleted
                    ? catColor.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted
                      ? catColor.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.06),
                  width: isCompleted ? 1.2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Leading icon with category color
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? catColor.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _categoryIcon(),
                      color: isCompleted ? catColor : Colors.white38,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.habit.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium(
                            color: isCompleted ? Colors.white54 : Colors.white,
                          ).copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.habit.category,
                          style: AppTypography.captionSmall(
                            color: catColor.withValues(alpha: 0.7),
                          ).copyWith(fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  // Check button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? catColor : Colors.transparent,
                      border: Border.all(
                        color: isCompleted ? catColor : Colors.white24,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.black)
                        : null,
                  ),
                ],
              ),
            ),

            // Particle and floating XP layer
            if (_isPlayingParticles)
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: LocalConfettiPainter(
                            progress: _particleController.value,
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, child) {
                          final slideVal = (1.0 - _particleController.value) * 35.0;
                          final opacityVal = (1.0 - _particleController.value).clamp(0.0, 1.0);
                          return Positioned(
                            right: 8,
                            top: 4 - slideVal,
                            child: Opacity(
                              opacity: opacityVal,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.yellowAccent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '+10 XP',
                                  style: AppTypography.captionSmall(color: Colors.black).copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
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
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LOCAL CHECKLIST ITEM PARTICLE PAINTER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class LocalConfettiPainter extends CustomPainter {
  final double progress;
  final List<Particle> particles;

  LocalConfettiPainter({required this.progress})
      : particles = List.generate(12, (index) {
          final random = math.Random(index);
          final angle = random.nextDouble() * 2 * math.pi;
          final speed = 15.0 + random.nextDouble() * 30.0;
          final color = [
            Colors.orangeAccent,
            Colors.yellowAccent,
            AppColors.accentEmerald,
            AppColors.accentBlue,
            Colors.pinkAccent,
          ][random.nextInt(5)];
          final size = 2.0 + random.nextDouble() * 3.0;
          return Particle(angle: angle, speed: speed, color: color, size: size);
        });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width - 20, size.height / 2);
    final paint = Paint();

    for (var particle in particles) {
      final distance = particle.speed * progress;
      final x = center.dx + math.cos(particle.angle) * distance;
      final y = center.dy + math.sin(particle.angle) * distance;

      paint.color = particle.color.withValues(alpha: (1.0 - progress).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  final double angle;
  final double speed;
  final Color color;
  final double size;

  Particle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
  });
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EDIT HABITS MODAL BOTTOM SHEET
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class EditHabitsBottomSheet extends ConsumerStatefulWidget {
  final List<UserHabit> initialSelected;

  const EditHabitsBottomSheet({super.key, required this.initialSelected});

  @override
  ConsumerState<EditHabitsBottomSheet> createState() => _EditHabitsBottomSheetState();
}

class _EditHabitsBottomSheetState extends ConsumerState<EditHabitsBottomSheet> {
  final List<UserHabit> _localSelected = [];

  final List<UserHabit> _allPredefinedHabits = [
    // Morning
    UserHabit(id: 'm1', title: '☀ Wake Up On Time', category: 'Morning', difficulty: 'Medium'),
    UserHabit(id: 'm2', title: '🛏 Make Bed', category: 'Morning', difficulty: 'Easy'),
    UserHabit(id: 'm3', title: '🪥 Brush Teeth', category: 'Morning', difficulty: 'Easy'),
    UserHabit(id: 'm4', title: '🚿 Shower', category: 'Morning', difficulty: 'Easy'),
    UserHabit(id: 'm5', title: '💧 Drink Water', category: 'Morning', difficulty: 'Easy'),
    UserHabit(id: 'm6', title: '🕌 Prayer / Meditation', category: 'Morning', difficulty: 'Medium'),
    UserHabit(id: 'm7', title: '📖 Read', category: 'Morning', difficulty: 'Medium'),
    UserHabit(id: 'm8', title: '📵 No Phone', category: 'Morning', difficulty: 'Hard'),
    UserHabit(id: 'm9', title: '🌞 Morning Sunlight', category: 'Morning', difficulty: 'Easy'),
    UserHabit(id: 'm10', title: '🏃 Morning Walk', category: 'Morning', difficulty: 'Medium'),

    // Health
    UserHabit(id: 'h1', title: '🏋 Workout', category: 'Health', difficulty: 'Hard'),
    UserHabit(id: 'h2', title: '🚴 Cycling', category: 'Health', difficulty: 'Medium'),
    UserHabit(id: 'h3', title: '🏃 Running', category: 'Health', difficulty: 'Hard'),
    UserHabit(id: 'h4', title: '🚰 Water Goal', category: 'Health', difficulty: 'Medium'),
    UserHabit(id: 'h5', title: '🥗 Healthy Food', category: 'Health', difficulty: 'Medium'),
    UserHabit(id: 'h6', title: '🍎 Fruits', category: 'Health', difficulty: 'Easy'),
    UserHabit(id: 'h7', title: '🍬 Reduce Sugar', category: 'Health', difficulty: 'Hard'),
    UserHabit(id: 'h8', title: '🥤 No Soft Drinks', category: 'Health', difficulty: 'Hard'),
    UserHabit(id: 'h9', title: '😴 Sleep On Time', category: 'Health', difficulty: 'Medium'),

    // Personal Development
    UserHabit(id: 'p1', title: '📚 Learn Something', category: 'Personal Development', difficulty: 'Medium'),
    UserHabit(id: 'p2', title: '✍ Journal', category: 'Personal Development', difficulty: 'Easy'),
    UserHabit(id: 'p3', title: '🎯 Complete Top 3 Tasks', category: 'Personal Development', difficulty: 'Medium'),
    UserHabit(id: 'p4', title: '💻 Deep Work', category: 'Personal Development', difficulty: 'Hard'),
    UserHabit(id: 'p5', title: '📖 Read 20 Pages', category: 'Personal Development', difficulty: 'Medium'),
    UserHabit(id: 'p6', title: '🎓 Online Course', category: 'Personal Development', difficulty: 'Hard'),
    UserHabit(id: 'p7', title: '🧠 Practice Skill', category: 'Personal Development', difficulty: 'Medium'),

    // Home
    UserHabit(id: 'ho1', title: '🧹 Clean Room', category: 'Home', difficulty: 'Medium'),
    UserHabit(id: 'ho2', title: '🪴 Water Plants', category: 'Home', difficulty: 'Easy'),
    UserHabit(id: 'ho3', title: '🖥 Clean Workspace', category: 'Home', difficulty: 'Easy'),
    UserHabit(id: 'ho4', title: '🧺 Laundry', category: 'Home', difficulty: 'Medium'),
    UserHabit(id: 'ho5', title: '📂 Organize Desk', category: 'Home', difficulty: 'Easy'),
  ];

  @override
  void initState() {
    super.initState();
    _localSelected.addAll(widget.initialSelected);
  }

  void _toggleLocalHabit(UserHabit habit) {
    HapticFeedback.lightImpact();
    setState(() {
      final idx = _localSelected.indexWhere((h) => h.id == habit.id);
      if (idx >= 0) {
        _localSelected.removeAt(idx);
      } else {
        _localSelected.add(habit);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = _allPredefinedHabits.map((h) => h.category).toSet().toList();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
        ),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 16, bottom: 20),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Habits',
                          style: AppTypography.displayMedium(color: Colors.white).copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Select/deselect the habits you want to track.',
                          style: AppTypography.caption(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12, height: 1),

            // Predefined Categories List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final habitsInCategory = _allPredefinedHabits.where((h) => h.category == category).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 12),
                        child: Text(
                          category.toUpperCase(),
                          style: AppTypography.captionSmall(color: AppColors.accentBlue).copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      ...habitsInCategory.map((habit) {
                        final isSelected = _localSelected.any((h) => h.id == habit.id);
                        return GestureDetector(
                          onTap: () => _toggleLocalHabit(habit),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accentBlue.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.accentBlue.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                  color: isSelected ? AppColors.accentBlue : Colors.white30,
                                  size: 22,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    habit.title,
                                    style: AppTypography.bodyLarge(
                                      color: isSelected ? Colors.white : Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),

            // Bottom Actions (Save / Cancel)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Save changes to database and notifier
                        await ref.read(osStateProvider.notifier).updateSelectedHabits(_localSelected);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
}
