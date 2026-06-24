import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/os_providers.dart';

class ShelfCardData {
  final String id;
  final String title;
  final String emoji;
  final String progressText;
  final String nextAction;
  final double progressValue; // 0.0 to 1.0
  final String? metricLabel;

  const ShelfCardData({
    required this.id,
    required this.title,
    required this.emoji,
    required this.progressText,
    required this.nextAction,
    required this.progressValue,
    this.metricLabel,
  });
}

class PremiumShelfSection extends StatefulWidget {
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
  State<PremiumShelfSection> createState() => _PremiumShelfSectionState();
}

class _PremiumShelfSectionState extends State<PremiumShelfSection> {
  late ScrollController _scrollController;
  int _liftedIndex = -1;
  late List<ShelfCardData> _cards;

  // Constants for card sizes
  final double cardWidth = 80.0;
  final double cardHeight = 110.0;
  final double spacing = 60.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _cards = _buildCardData();

    // Center the cards after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _cards.isNotEmpty) {
        final int middleIndex = (_cards.length / 2).floor();
        final double targetOffset = middleIndex * (cardWidth + spacing);
        _scrollController.jumpTo(targetOffset);
      }
    });

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
  void didUpdateWidget(covariant PremiumShelfSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-build card list if values change
    if (widget.waterLoggedMl != oldWidget.waterLoggedMl ||
        widget.workoutComplete != oldWidget.workoutComplete ||
        widget.readPages != oldWidget.readPages ||
        widget.savingsSaved != oldWidget.savingsSaved ||
        widget.journalSaved != oldWidget.journalSaved ||
        widget.state.selectedLifeAreas != oldWidget.state.selectedLifeAreas) {
      setState(() {
        _cards = _buildCardData();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<ShelfCardData> _buildCardData() {
    final List<ShelfCardData> cards = [];

    // 1. Reading
    if (widget.state.selectedLifeAreas.contains('reading') ||
        widget.state.selectedLifeAreas.contains('learning')) {
      final double progress = (widget.readPages / widget.readPagesTarget).clamp(
        0.0,
        1.0,
      );
      cards.add(
        ShelfCardData(
          id: 'learning',
          title: 'Reading',
          emoji: '📚',
          progressText: '${widget.readPages} / ${widget.readPagesTarget} Pgs',
          nextAction:
              'Read ${widget.readPagesTarget - widget.readPages > 0 ? (widget.readPagesTarget - widget.readPages).clamp(5, 15) : 10} Pages',
          progressValue: progress,
          metricLabel: 'Book: ${widget.activeBook}',
        ),
      );
    }

    // 2. Finance
    if (widget.state.selectedLifeAreas.contains('finance')) {
      final double progress = (widget.savingsSaved / widget.savingsTarget)
          .clamp(0.0, 1.0);
      cards.add(
        ShelfCardData(
          id: 'finance',
          title: 'Savings',
          emoji: '💰',
          progressText: '₹${widget.savingsSaved.toInt()}',
          nextAction: 'Save ₹500 Today',
          progressValue: progress,
          metricLabel: 'Goal ₹${widget.savingsTarget.toInt()}',
        ),
      );
    }

    // 3. Health
    if (widget.state.selectedLifeAreas.contains('health') ||
        widget.state.selectedLifeAreas.contains('nutrition') ||
        widget.state.selectedLifeAreas.contains('sleep')) {
      cards.add(
        ShelfCardData(
          id: 'health',
          title: 'Workout',
          emoji: '💪',
          progressText: widget.workoutComplete ? 'Completed' : 'Pending',
          nextAction: widget.workoutComplete
              ? 'Recover Today'
              : 'Workout Today',
          progressValue: widget.workoutComplete ? 1.0 : 0.4,
          metricLabel: 'Steps: ${widget.stepsWalked}',
        ),
      );
    }

    // 4. Goals / Productivity
    if (widget.state.selectedLifeAreas.contains('goals') ||
        widget.state.selectedLifeAreas.contains('productivity') ||
        widget.state.selectedLifeAreas.contains('coding') ||
        widget.state.selectedLifeAreas.contains('mindset')) {
      cards.add(
        const ShelfCardData(
          id: 'goals',
          title: 'Startup Launch',
          emoji: '🎯',
          progressText: '70% Done',
          nextAction: 'Finish Landing Page',
          progressValue: 0.7,
          metricLabel: '9 Days Remaining',
        ),
      );
    }

    // 5. Journaling
    if (widget.state.selectedLifeAreas.contains('journaling')) {
      cards.add(
        ShelfCardData(
          id: 'journal',
          title: 'Journal',
          emoji: '📝',
          progressText: widget.journalSaved ? 'Written' : 'Pending',
          nextAction: 'Write Reflection',
          progressValue: widget.journalSaved ? 1.0 : 0.0,
          metricLabel: widget.journalSaved
              ? 'Log Saved'
              : 'Last Entry: Yesterday',
        ),
      );
    }

    // 6. Business
    if (widget.state.selectedLifeAreas.contains('business')) {
      cards.add(
        const ShelfCardData(
          id: 'goals',
          title: 'Business',
          emoji: '🚀',
          progressText: '80% Progress',
          nextAction: 'Pitch Deck Update',
          progressValue: 0.8,
          metricLabel: '5 Tasks Remaining',
        ),
      );
    }

    // 7. Spiritual
    if (widget.state.selectedLifeAreas.contains('spiritual')) {
      cards.add(
        const ShelfCardData(
          id: 'routine',
          title: 'Spiritual',
          emoji: '🙏',
          progressText: '15 / 30 Days',
          nextAction: 'Meditation 10m',
          progressValue: 0.5,
          metricLabel: 'Streak: 6 Days',
        ),
      );
    }

    // 8. Fitness / Running
    if (widget.state.selectedLifeAreas.contains('running') ||
        widget.state.selectedLifeAreas.contains('fitness')) {
      cards.add(
        ShelfCardData(
          id: 'health',
          title: 'Fitness',
          emoji: '🏃',
          progressText: '12 / 20 Runs',
          nextAction: 'Run 5K Today',
          progressValue: 0.6,
          metricLabel: 'Steps: ${widget.stepsWalked}',
        ),
      );
    }

    // 9. Career
    if (widget.state.selectedLifeAreas.contains('career')) {
      cards.add(
        const ShelfCardData(
          id: 'goals',
          title: 'Career',
          emoji: '📈',
          progressText: '3 / 5 Applications',
          nextAction: 'Update CV Profile',
          progressValue: 0.6,
          metricLabel: 'Status: Active',
        ),
      );
    }

    // Fallback default list if onboarding set is empty
    if (cards.isEmpty) {
      cards.addAll([
        ShelfCardData(
          id: 'learning',
          title: 'Reading',
          emoji: '📚',
          progressText: '${widget.readPages} / ${widget.readPagesTarget} Pgs',
          nextAction: 'Read Pages Today',
          progressValue: (widget.readPages / widget.readPagesTarget).clamp(
            0.0,
            1.0,
          ),
          metricLabel: 'Book: ${widget.activeBook}',
        ),
        ShelfCardData(
          id: 'finance',
          title: 'Savings',
          emoji: '💰',
          progressText: '₹${widget.savingsSaved.toInt()}',
          nextAction: 'Save ₹500 Today',
          progressValue: (widget.savingsSaved / widget.savingsTarget).clamp(
            0.0,
            1.0,
          ),
          metricLabel: 'Goal ₹${widget.savingsTarget.toInt()}',
        ),
        ShelfCardData(
          id: 'health',
          title: 'Workout',
          emoji: '💪',
          progressText: widget.workoutComplete ? 'Completed' : 'Pending',
          nextAction: widget.workoutComplete
              ? 'Recover Today'
              : 'Workout Today',
          progressValue: widget.workoutComplete ? 1.0 : 0.4,
          metricLabel: 'Steps: ${widget.stepsWalked}',
        ),
        const ShelfCardData(
          id: 'goals',
          title: 'Startup Launch',
          emoji: '🎯',
          progressText: '70% Done',
          nextAction: 'Finish Landing Page',
          progressValue: 0.7,
          metricLabel: '9 Days Remaining',
        ),
        ShelfCardData(
          id: 'journal',
          title: 'Journal',
          emoji: '📝',
          progressText: widget.journalSaved ? 'Written' : 'Pending',
          nextAction: 'Write Reflection',
          progressValue: widget.journalSaved ? 1.0 : 0.0,
          metricLabel: widget.journalSaved
              ? 'Log Saved'
              : 'Last Entry: Yesterday',
        ),
      ]);
    }
    
    // Add 3 additional cards for UI testing
    cards.addAll([
      const ShelfCardData(
        id: 'hydration',
        title: 'Hydration',
        emoji: '💧',
        progressText: '1,200 / 2,500 mL',
        nextAction: 'Drink 250ml Water',
        progressValue: 0.48,
        metricLabel: 'Daily Target: 2.5L',
      ),
      const ShelfCardData(
        id: 'sleep',
        title: 'Sleep',
        emoji: '😴',
        progressText: '7.8 Hours',
        nextAction: 'Wind down at 10 PM',
        progressValue: 0.85,
        metricLabel: 'Deep Sleep: 2h 15m',
      ),
      const ShelfCardData(
        id: 'habits',
        title: 'Streak',
        emoji: '🔥',
        progressText: '18 Days',
        nextAction: 'Complete Daily 5',
        progressValue: 0.9,
        metricLabel: 'Level 4 Focus',
      ),
    ]);

    return cards;
  }

  @override
  Widget build(BuildContext context) {
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
                  itemCount: _cards.length,
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
                        for (int i = 0; i < _cards.length; i++) {
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
                          _cards[index],
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
                _scrollController.animateTo(
                  index * (cardWidth + spacing),
                  duration: const Duration(milliseconds: 550),
                  curve: Curves.easeOutBack,
                );
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
                  widget.onExpandModule(card.id);
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
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.5,
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
                                  color: Colors.white.withValues(
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
                                  color: Colors.white.withValues(
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
                                  color: isActive
                                      ? AppColors.accentBlue
                                      : Colors.white60,
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
                                    color: Colors.white.withValues(alpha: 0.35),
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
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 0.5),
                              Text(
                                card.nextAction,
                                style: TextStyle(
                                  fontSize: 6.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(
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
                                  color: Colors.white.withValues(alpha: 0.08),
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
                                            colors: [
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
