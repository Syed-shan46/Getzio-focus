import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/app_providers.dart';
import '../providers/os_providers.dart';
import '../../../todo/domain/models/todo_model.dart';
import '../../../todo/presentation/providers/todo_providers.dart';
import '../../../auth/presentation/widgets/save_workspace_sheet.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ShelfCardData {
  final String id;
  final String moduleType;
  final String title;
  final String emoji;
  final String progressText;
  final String nextAction;
  final double progressValue; // 0.0 to 1.0
  final String? metricLabel;
  final bool isGold;

  const ShelfCardData({
    required this.id,
    required this.moduleType,
    required this.title,
    required this.emoji,
    required this.progressText,
    required this.nextAction,
    required this.progressValue,
    this.metricLabel,
    this.isGold = false,
  });
}

class PremiumShelfSection extends ConsumerStatefulWidget {
  final OSState state;
  final Function(String) onExpandModule;
  final int waterLoggedMl;
  final double sleepHours;
  final int stepsWalked;
  final bool workoutComplete;
  final int readPages;
  final int readPagesTarget;
  final String activeBook;
  final double savingsSaved;
  final double savingsTarget;
  final bool journalSaved;

  const PremiumShelfSection({
    super.key,
    required this.state,
    required this.onExpandModule,
    required this.waterLoggedMl,
    required this.sleepHours,
    required this.stepsWalked,
    required this.workoutComplete,
    required this.readPages,
    required this.readPagesTarget,
    required this.activeBook,
    required this.savingsSaved,
    required this.savingsTarget,
    required this.journalSaved,
  });

  @override
  ConsumerState<PremiumShelfSection> createState() => _PremiumShelfSectionState();
}

class _PremiumShelfSectionState extends ConsumerState<PremiumShelfSection> {
  late ScrollController _scrollController;
  int _liftedIndex = -1;
  bool _hasCentered = false;

  // Constants for card sizes
  final double cardWidth = 80.0;
  final double cardHeight = 110.0;
  final double spacing = 24.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Reset lifted index on scroll start
    _scrollController.addListener(() {
      if (_liftedIndex != -1) {
        setState(() {
          _liftedIndex = -1;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<ShelfCardData> _buildCardData(List<TodoModel> todos) {
    final List<ShelfCardData> cards = [];

    // Inject Cloud Save promo card for guests
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.hasValue && authState.value != null;
    if (!isLoggedIn) {
      cards.add(
        const ShelfCardData(
          id: 'cloud_save_promo',
          moduleType: 'cloud_save_promo',
          title: 'Cloud Save',
          emoji: '☁️',
          progressText: 'Save Progress',
          nextAction: 'Save Workspace',
          progressValue: 0.0,
          metricLabel: 'Prevent data loss',
          isGold: false,
        ),
      );
    }

    // Rotational suggested cards (they are always present, rotating by day, and some are gold)
    final day = DateTime.now().weekday;

    // Card 1: Today's Quote / Quote of the Day (Gold on Monday & Thursday)
    final isQuoteGold = (day == 1 || day == 4);
    cards.add(ShelfCardData(
      id: 'suggested_quote',
      moduleType: 'affirmations',
      title: isQuoteGold ? 'Quote of the Day' : 'Today\'s Quote',
      emoji: isQuoteGold ? '⭐' : '✨',
      progressText: 'Inspirational',
      nextAction: 'Read Mantras',
      progressValue: 1.0,
      metricLabel: 'Tap to read',
      isGold: isQuoteGold,
    ));

    // Card 2: Today's Focus
    cards.add(const ShelfCardData(
      id: 'suggested_focus',
      moduleType: 'focus',
      title: 'Today\'s Focus',
      emoji: '🎯',
      progressText: 'Ready',
      nextAction: 'View Tasks',
      progressValue: 0.0,
      metricLabel: 'Daily discipline',
      isGold: false,
    ));

    // Card 3: Vision Highlight / Milestone Reached (Gold on Wednesday & Saturday)
    final isVisionGold = (day == 3 || day == 6);
    cards.add(ShelfCardData(
      id: 'suggested_vision',
      moduleType: 'vision_room',
      title: isVisionGold ? 'Milestone Reached' : 'Vision Highlight',
      emoji: isVisionGold ? '🎉' : '🏡',
      progressText: 'Visualize',
      nextAction: 'Open Room',
      progressValue: 0.8,
      metricLabel: 'Unlock dreams',
      isGold: isVisionGold,
    ));

    // Card 4: Daily Reflection / Today's Inspiration
    final isReflectionGold = (day == 2 || day == 5);
    cards.add(ShelfCardData(
      id: 'suggested_reflection',
      moduleType: 'journal',
      title: isReflectionGold ? 'Today\'s Inspiration' : 'Daily Reflection',
      emoji: isReflectionGold ? '🌅' : '💬',
      progressText: 'Write Entry',
      nextAction: 'Open Journal',
      progressValue: 0.2,
      metricLabel: 'Self reflection',
      isGold: false, // Disabled gold theme per user request
    ));

    // Card 5: Progress Highlight / Weekly Achievement (Gold on Sunday)
    final isProgressGold = (day == 7);
    cards.add(ShelfCardData(
      id: 'suggested_progress',
      moduleType: 'achievements',
      title: isProgressGold ? 'Weekly Achievement' : 'Progress Highlight',
      emoji: isProgressGold ? '🏆' : '🌟',
      progressText: 'Level Up',
      nextAction: 'View Badges',
      progressValue: 0.6,
      metricLabel: 'Celebrate success',
      isGold: isProgressGold,
    ));

    // Card 6: Calm Reminder
    cards.add(const ShelfCardData(
      id: 'suggested_calm',
      moduleType: 'health',
      title: 'Calm Reminder',
      emoji: '🌅',
      progressText: 'Relax',
      nextAction: 'Breathing Block',
      progressValue: 0.5,
      metricLabel: 'Cozy session',
      isGold: false,
    ));

    // Dynamic Context-based Cards below:
    // 1. Overdue tasks (Incomplete, created before today)
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final overdueTasks = todos.where((t) => !t.isCompleted && t.createdAt.isBefore(todayStart)).toList();
    for (var todo in overdueTasks) {
      cards.add(
        ShelfCardData(
          id: 'overdue_${todo.id}',
          moduleType: 'routine',
          title: todo.title,
          emoji: '⚠️',
          progressText: 'Overdue',
          nextAction: 'Complete task',
          progressValue: 0.0,
          metricLabel: 'Due today',
          isGold: false,
        ),
      );
    }

    // 2. Recovery tasks (Yesterday's missed habits)
    for (var recoveryTask in widget.state.recoveryTasks) {
      cards.add(
        ShelfCardData(
          id: 'recovery_$recoveryTask',
          moduleType: 'routine',
          title: recoveryTask,
          emoji: '🩹',
          progressText: 'Recovery',
          nextAction: 'Complete recovery',
          progressValue: 0.0,
          metricLabel: 'Yesterday\'s habit',
          isGold: false,
        ),
      );
    }

    // 3. Today's habits (selected, not completed today)
    final incompleteHabits = widget.state.selectedHabits.where((habit) {
      return !widget.state.completedHabitIdsToday.contains(habit.id);
    }).toList();

    String getHabitEmoji(String cat) {
      switch (cat.toLowerCase()) {
        case 'fitness':
        case 'workout':
        case 'health':
          return '💪';
        case 'finance':
        case 'money':
          return '💰';
        case 'reading':
        case 'learning':
        case 'mind':
          return '📚';
        default:
          return '✅';
      }
    }

    for (var habit in incompleteHabits) {
      cards.add(
        ShelfCardData(
          id: 'habit_${habit.id}',
          moduleType: 'routine',
          title: habit.title,
          emoji: getHabitEmoji(habit.category),
          progressText: 'Pending',
          nextAction: 'Mark completed',
          progressValue: 0.0,
          metricLabel: habit.category,
          isGold: false,
        ),
      );
    }

    // 4. Goal milestones (Target goals from Hive)
    final hiveDb = ref.read(hiveDatabaseProvider);
    final selectedGoals = hiveDb.getSelectedGoals();
    if (selectedGoals.isNotEmpty) {
      for (var goal in selectedGoals) {
        final title = goal['title'] as String? ?? 'Goal';
        final category = goal['category'] as String? ?? 'General';
        final timeline = goal['timeline'] as String? ?? '1 Month';
        cards.add(
          ShelfCardData(
            id: 'goal_${goal['id'] ?? title}',
            moduleType: 'goals',
            title: title,
            emoji: '🎯',
            progressText: 'Active',
            nextAction: 'Take action today',
            progressValue: 0.5,
            metricLabel: '$category • $timeline',
            isGold: false,
          ),
        );
      }
    }

    // 5. Health reminders: Water, Sleep, Workout
    if (widget.waterLoggedMl < 2500) {
      cards.add(
        ShelfCardData(
          id: 'health_water',
          moduleType: 'health',
          title: 'Hydration',
          emoji: '💧',
          progressText: '${widget.waterLoggedMl} / 2500 ml',
          nextAction: 'Drink 250ml',
          progressValue: (widget.waterLoggedMl / 2500.0).clamp(0.0, 1.0),
          metricLabel: 'Target: 2.5L',
          isGold: false,
        ),
      );
    }

    if (widget.sleepHours < 8.0) {
      cards.add(
        ShelfCardData(
          id: 'health_sleep',
          moduleType: 'health',
          title: 'Sleep',
          emoji: '😴',
          progressText: '${widget.sleepHours} Hours',
          nextAction: 'Wind down at 10 PM',
          progressValue: (widget.sleepHours / 8.0).clamp(0.0, 1.0),
          metricLabel: 'Target: 8.0h',
          isGold: false,
        ),
      );
    }

    if (!widget.workoutComplete) {
      cards.add(
        ShelfCardData(
          id: 'health_workout',
          moduleType: 'health',
          title: 'Workout',
          emoji: '💪',
          progressText: 'Pending',
          nextAction: 'Workout Today',
          progressValue: 0.0,
          metricLabel: 'Steps: ${widget.stepsWalked}',
          isGold: false,
        ),
      );
    }

    // 6. Finance reminders
    if (widget.savingsSaved < widget.savingsTarget) {
      cards.add(
        ShelfCardData(
          id: 'finance_savings',
          moduleType: 'finance',
          title: 'Savings',
          emoji: '💰',
          progressText: '₹${widget.savingsSaved.toInt()}',
          nextAction: 'Save ₹500 Today',
          progressValue: (widget.savingsSaved / widget.savingsTarget).clamp(0.0, 1.0),
          metricLabel: 'Goal: ₹${widget.savingsTarget.toInt()}',
          isGold: false,
        ),
      );
    }

    // 7. Reading target
    if (widget.readPages < widget.readPagesTarget) {
      cards.add(
        ShelfCardData(
          id: 'reading_progress',
          moduleType: 'learning',
          title: 'Reading',
          emoji: '📚',
          progressText: '${widget.readPages} / ${widget.readPagesTarget} Pgs',
          nextAction: 'Read ${widget.readPagesTarget - widget.readPages > 0 ? widget.readPagesTarget - widget.readPages : 10} Pages',
          progressValue: (widget.readPages / widget.readPagesTarget).clamp(0.0, 1.0),
          metricLabel: widget.activeBook,
          isGold: false,
        ),
      );
    }

    // Filter duplicates by unique card ID and cap at 9 to keep it scrolling beautifully
    final Set<String> seenIds = {};
    final List<ShelfCardData> uniqueCards = [];
    for (var card in cards) {
      if (!seenIds.contains(card.id)) {
        seenIds.add(card.id);
        uniqueCards.add(card);
      }
    }

    if (uniqueCards.length > 9) {
      return uniqueCards.sublist(0, 9);
    }
    return uniqueCards;
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todosProvider);
    final todos = todosAsync.value ?? [];
    final cards = _buildCardData(todos);

    if (!_hasCentered && cards.isNotEmpty) {
      _hasCentered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final int middleIndex = (cards.length / 2).floor();
          final double targetOffset = middleIndex * (cardWidth + spacing);
          _scrollController.jumpTo(targetOffset);
        }
      });
    }

    Color woodColor;
    if (widget.state.woodTexture == 'Oak') {
      woodColor = const Color(0xFFC7B3A3);
    } else if (widget.state.woodTexture == 'Mahogany') {
      woodColor = const Color(0xFF4A2C22);
    } else {
      woodColor = const Color(0xFF2E1912); // classic walnut
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double sidePadding = (screenWidth - cardWidth) / 2;

        return SizedBox(
          height: cardHeight + 50,
          width: screenWidth,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 2. Shelf Wall Shadow (Deep backing shadow)
              Positioned(
                top: cardHeight + 6,
                left: 12,
                right: 12,
                height: 12,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.75),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Scrollable Cards List sitting directly on the shelf (optimized scroll performance)
              Positioned(
                top: -5.0,
                left: 0,
                right: 0,
                height: cardHeight + 15,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: sidePadding),
                  itemCount: cards.length,
                  clipBehavior: Clip.none,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _scrollController,
                      builder: (context, child) {
                        final double scrollOffset = _scrollController.hasClients
                            ? _scrollController.offset
                            : 0.0;
                        final double viewportCenter =
                            scrollOffset + screenWidth / 2;

                        // Compute current active index based on proximity to center
                        double minDistance = double.infinity;
                        int activeIndex = 0;
                        for (int i = 0; i < cards.length; i++) {
                          final double itemC =
                              sidePadding +
                              i * (cardWidth + spacing) +
                              cardWidth / 2;
                          final double dist = (itemC - viewportCenter).abs();
                          if (dist < minDistance) {
                            minDistance = dist;
                            activeIndex = i;
                          }
                        }

                        final double itemCenter =
                            sidePadding +
                            index * (cardWidth + spacing) +
                            cardWidth / 2;
                        final double distance = itemCenter - viewportCenter;
                        final double normalizedDistance =
                            (distance / (cardWidth + spacing)).clamp(-2.5, 2.5);

                        return _buildCard(
                          cards[index],
                          index,
                          normalizedDistance,
                          index == activeIndex,
                        );
                      },
                    );
                  },
                ),
              ),

              // 4. Wall support brackets
              Positioned(
                top: cardHeight,
                left: screenWidth * 0.18,
                child: _buildBracket(),
              ),
              Positioned(
                top: cardHeight,
                right: screenWidth * 0.18,
                child: _buildBracket(),
              ),

              // 5. 3D Wooden Plank (Top Slant Surface)
              Positioned(
                top: cardHeight - 6,
                left: 8,
                right: 8,
                height: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: woodColor.withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                ),
              ),

              // 6. 3D Wooden Plank (Front Edge Thickness)
              Positioned(
                top: cardHeight,
                left: 6,
                right: 6,
                height: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.lerp(woodColor, Colors.black, 0.22),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBracket() {
    return Container(
      width: 6,
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 2, offset: Offset(1, 1)),
        ],
      ),
    );
  }

  Widget _buildCard(
    ShelfCardData card,
    int index,
    double normalizedDistance,
    bool isActive,
  ) {
    final bool isLifted = _liftedIndex == index;

    // Cover flow 3D transformations parameters
    double scale = 1.0 - 0.14 * normalizedDistance.abs().clamp(0.0, 1.0);
    double rotationY = -0.32 * normalizedDistance.clamp(-1.5, 1.5);
    double translateZ = -75.0 * normalizedDistance.abs().clamp(0.0, 1.5);
    double translateX = -14.0 * normalizedDistance;

    // Extra lifts for focus
    if (isActive) {
      scale += 0.04;
    }
    if (isLifted) {
      scale += 0.08;
      translateZ += 25.0;
    }

    // Depth darken mask overlay
    double darkenOpacity = (normalizedDistance.abs() * 0.38).clamp(0.0, 0.65);
    if (isActive) {
      darkenOpacity = 0.0;
    }

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: spacing),
      child: Align(
        alignment: Alignment.topCenter,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0018) // 3D Perspective intensity
            ..multiply(
              Matrix4.translationValues(
                translateX,
                isLifted ? -10.0 : 0.0,
                translateZ,
              ),
            ) // Float upwards when tapped/lifted
            ..rotateY(rotationY)
            ..multiply(Matrix4.diagonal3Values(scale, scale, 1.0)),
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {
              if (!isActive) {
                // Centering click
                HapticFeedback.lightImpact();
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    index * (cardWidth + spacing),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeOutBack,
                  );
                }
              } else {
                if (!isLifted) {
                  // Lift card
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _liftedIndex = index;
                  });
                } else {
                  // Double tap / tap active card: Expand full screen
                  HapticFeedback.heavyImpact();
                  if (card.moduleType == 'cloud_save_promo') {
                    SaveWorkspaceSheet.show(context);
                  } else {
                    widget.onExpandModule(card.moduleType);
                  }
                  setState(() {
                    _liftedIndex = -1;
                  });
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: card.isGold
                    ? const LinearGradient(
                        colors: [
                          Color(0xFFFFF7C2),
                          Color(0xFFD4AF37),
                          Color(0xFFAA7C11),
                          Color(0xFFD4AF37),
                        ],
                        stops: [0.0, 0.35, 0.7, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.06),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: Border.all(
                  color: card.isGold
                      ? const Color(0xFFFFE082).withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.08),
                  width: card.isGold ? 1.2 : 0.5,
                ),
                boxShadow: [
                  if (!isActive)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 0. Frosted Glassmorphism Backdrop Blur
                    if (!card.isGold)
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                          child: Container(color: Colors.transparent),
                        ),
                      ),

                    // 1. Diagonal glossy glare reflection line
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GlossyReflectionPainter(isActive: isActive),
                      ),
                    ),

                    // 2. Depth shading to make cards look receded in dark room when scrolled away
                    if (darkenOpacity > 0.0)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: darkenOpacity),
                        ),
                      ),

                    // 3. Card Content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 6.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Icon row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: card.isGold
                                      ? Colors.black.withValues(alpha: 0.12)
                                      : Colors.white.withValues(
                                          alpha: isActive ? 0.08 : 0.04,
                                        ),
                                ),
                                child: Text(
                                  card.emoji,
                                  style: const TextStyle(fontSize: 12.0),
                                ),
                              ),
                            ],
                          ),

                          // Info titles
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                card.title.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: 7.0,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: card.isGold
                                      ? const Color(0xFF2C1E03)
                                      : Colors.white.withValues(
                                          alpha: isActive ? 0.95 : 0.72,
                                        ),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1.0),
                              Text(
                                card.progressText,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: card.isGold
                                      ? const Color(0xFF4A3403)
                                      : (isActive
                                          ? AppColors.accentBlue
                                          : Colors.white60),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (card.metricLabel != null) ...[
                                const SizedBox(height: 0.5),
                                Text(
                                  card.metricLabel!,
                                  style: TextStyle(
                                    fontSize: 6.0,
                                    fontWeight: FontWeight.w500,
                                    color: card.isGold
                                        ? const Color(0xFF5A4106)
                                        : Colors.white.withValues(alpha: 0.35),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),

                          // Action label & Micro Progress bar
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'NEXT ACTION',
                                style: TextStyle(
                                  fontSize: 4.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: card.isGold
                                      ? const Color(0xFF4A3403).withValues(alpha: 0.6)
                                      : Colors.white.withValues(alpha: 0.25),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 0.5),
                              Text(
                                card.nextAction,
                                style: TextStyle(
                                  fontSize: 6.5,
                                  fontWeight: FontWeight.w600,
                                  color: card.isGold
                                      ? const Color(0xFF2C1E03)
                                      : Colors.white.withValues(
                                          alpha: isActive ? 0.85 : 0.55,
                                        ),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3.0),

                              // Micro progress bar
                              Container(
                                height: 1.6,
                                decoration: BoxDecoration(
                                  color: card.isGold
                                      ? Colors.black.withValues(alpha: 0.1)
                                      : Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(0.8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0.8),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: card.progressValue,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: card.isGold
                                                ? [
                                                    const Color(0xFF3E2723),
                                                    const Color(0xFF5D4037),
                                                  ]
                                                : [
                                                    AppColors.accentBlue,
                                                    AppColors.accentBlue.withValues(
                                                      alpha: 0.65,
                                                    ),
                                                  ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GLOSSY REFLECTION PAINTER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _GlossyReflectionPainter extends CustomPainter {
  final bool isActive;

  _GlossyReflectionPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: isActive ? 0.12 : 0.06),
          Colors.white.withValues(alpha: isActive ? 0.03 : 0.01),
          Colors.transparent,
          Colors.white.withValues(alpha: isActive ? 0.05 : 0.02),
        ],
        stops: const [0.0, 0.32, 0.33, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _GlossyReflectionPainter oldDelegate) =>
      oldDelegate.isActive != isActive;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREMIUM 3D WOOD SHELF PAINTER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
