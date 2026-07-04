import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../painters/wall_background_painter.dart';
import '../painters/rope_painter.dart';
import '../painters/wooden_hook_painter.dart';
import 'affirmation_plank.dart';
import '../../domain/models/affirmation_model.dart';
import '../providers/affirmations_provider.dart';

/// Layout constants for the hanging affirmation board.
class _Layout {
  static const double headerHeight = 56;
  static const double hookDiameter = 56;
  static const double hookToBoardGap = 42;
  static const double boardHeight = 76;
  static const double boardSpacing = 16.0;
  static const double knotsHeight = 0.0;
  static const double boardMarginH = 20;
  static const double paddingTop = 24;
  static const double paddingBottom = 32;
  static const double holeInset = 28;
  static const double holeRadius = 5;
  static const double ropeThickness = 5.0;
}

/// The complete redesigned hanging affirmation board experience.
///
/// Renders a premium warm paper wall background, a wooden hook with engraved
/// star, an inverted-V cotton rope passing through drilled holes in each
/// board, decorative knots and beads below the last board, and physics-based
/// swing animation with dampening.
class HangingAffirmationBoard extends ConsumerStatefulWidget {
  final List<DailyAffirmation> affirmations;
  final Map<String, int> repeatCounts;

  const HangingAffirmationBoard({
    super.key,
    required this.affirmations,
    this.repeatCounts = const {},
  });

  @override
  ConsumerState<HangingAffirmationBoard> createState() =>
      _HangingAffirmationBoardState();
}

class _HangingAffirmationBoardState
    extends ConsumerState<HangingAffirmationBoard>
    with TickerProviderStateMixin {
  // ── Drop bounce on open ──
  late AnimationController _dropController;
  late Animation<double> _dropAnimation;

  // ── Planks individual gravity tilt ──
  late AnimationController _tiltController;
  late Animation<double> _tiltAnimation;
  final List<double> _targetAngles = [];

  // ── Drag swing with dampening ──
  double _swingAngle = 0;
  AnimationController? _dampenController;

  // ── Ambient sway (very slow, ±1°) ──
  late AnimationController _swayController;
  late Animation<double> _swayAnimation;

  // ── Ambient wall animation ──
  late AnimationController _ambientController;
  late AnimationController _sunlightController;

  // ── Per-plank wind offsets ──
  late List<AnimationController> _windControllers;
  late List<Animation<double>> _windAnimations;

  // ── Expanded plank state ──
  String? _expandedPlankId;

  // ── Dust motes for wall ──
  final List<DustMote> _dustMotes = [];

  @override
  void initState() {
    super.initState();

    // ── Planks gravity target angles (disabled - show straight) ──
    _targetAngles.clear();
    final count = widget.affirmations.length;
    for (int i = 0; i < count; i++) {
      _targetAngles.add(0.0);
    }

    // ── Drop bounce on open ──
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _dropAnimation = Tween<double>(begin: -800, end: 0).animate(
      CurvedAnimation(parent: _dropController, curve: Curves.elasticOut),
    );
    _dropController.forward();

    // ── Gravity tilt animation (starts when the boards hit the bottom at 400ms) ──
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _tiltAnimation = CurvedAnimation(
      parent: _tiltController,
      curve: Curves.elasticOut,
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _tiltController.forward();
      }
    });

    // Setup dummy sway/dampen animation objects to avoid breaking disposes
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    _swayAnimation = const AlwaysStoppedAnimation<double>(0.0);

    // ── Ambient wall dust ──
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    // ── Sunlight breathing ──
    _sunlightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    final rng = Random();

    // ── Initialize dust motes ──
    _dustMotes.addAll(
      List.generate(
        12,
        (_) => DustMote(
          x: rng.nextDouble(),
          y: rng.nextDouble(),
          speed: 0.006 + rng.nextDouble() * 0.012,
          size: 0.6 + rng.nextDouble() * 1.5,
          swaySpeed: 0.02 + rng.nextDouble() * 0.05,
        ),
      ),
    );

    // ── Per-plank wind controllers ──
    _initWindControllers();
  }

  void _initWindControllers() {
    _windControllers = [];
    _windAnimations = [];
    final rng = Random();

    for (int i = 0; i < widget.affirmations.length; i++) {
      // Each board has a different duration (4-6 second cycle)
      final duration = 4.0 + rng.nextDouble() * 2.0;
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: (duration * 1000).round()),
      );
      // Add slight delay between boards for wave effect
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) controller.repeat(reverse: true);
      });

      // Amplitude 1-3 pixels (gentle breeze effect)
      final amplitude = 1.0 + rng.nextDouble() * 2.0;
      final animation = Tween<double>(
        begin: -amplitude,
        end: amplitude,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      _windControllers.add(controller);
      _windAnimations.add(animation);
    }
  }

  @override
  void didUpdateWidget(HangingAffirmationBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.affirmations.length != oldWidget.affirmations.length) {
      for (var c in _windControllers) {
        c.dispose();
      }
      _initWindControllers();
    }
  }

  @override
  void dispose() {
    _dropController.dispose();
    _tiltController.dispose();
    _swayController.dispose();
    _ambientController.dispose();
    _sunlightController.dispose();
    _dampenController?.dispose();
    for (var c in _windControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _togglePlankExpansion(String plankId) {
    setState(() {
      _expandedPlankId = _expandedPlankId == plankId ? null : plankId;
    });
  }

  /// Handles horizontal drag to swing the board system.
  void _onPanUpdate(DragUpdateDetails details) {}

  /// On release, start dampening the swing.
  void _onPanEnd(DragEndDetails details) {}

  double _getSwayAngleForBoard(int index) {
    final waveValue = sin(_swayController.value * pi);
    final boardSway = waveValue * 0.008;
    final boardSwing = _swingAngle;
    return boardSway + boardSwing;
  }

  double _getStaticTilt(String id) {
    final rand = Random(id.hashCode.abs());
    return (rand.nextDouble() - 0.5) * 0.044;
  }

  double _getStaticOffsetX(String id) {
    final rand = Random(id.hashCode.abs() + 1);
    return (rand.nextDouble() - 0.5) * 6.0;
  }

  /// Calculates the total height of the board system.
  double _calculateTotalHeight(double headerHeight) {
    final n = widget.affirmations.length;
    if (n == 0) {
      return headerHeight +
          _Layout.hookDiameter +
          _Layout.hookToBoardGap +
          _Layout.boardHeight +
          _Layout.knotsHeight;
    }
    double currentY =
        headerHeight + _Layout.hookDiameter + _Layout.hookToBoardGap;
    for (int i = 0; i < n; i++) {
      final aff = widget.affirmations[i];
      final isExpanded = _expandedPlankId == aff.id;
      final h = isExpanded ? 192.0 : _Layout.boardHeight;
      currentY += h + _Layout.boardSpacing;
    }
    return currentY - _Layout.boardSpacing + _Layout.knotsHeight;
  }

  /// Calculates board rects for the rope system painter (plank body sizes).
  List<Rect> _calculateBoardRects(double width, double headerHeight) {
    final rects = <Rect>[];
    final boardWidth = width - 2 * _Layout.boardMarginH;
    double currentY =
        headerHeight + _Layout.hookDiameter + _Layout.hookToBoardGap;

    for (int i = 0; i < widget.affirmations.length; i++) {
      final aff = widget.affirmations[i];
      final isExpanded = _expandedPlankId == aff.id;
      // Rope passes through holes in the plank body itself
      final h = isExpanded ? 110.0 : _Layout.boardHeight;
      rects.add(Rect.fromLTWH(_Layout.boardMarginH, currentY, boardWidth, h));
      // But the layout position shift depends on total height including buttons
      final totalH = isExpanded ? 192.0 : _Layout.boardHeight;
      currentY += totalH + _Layout.boardSpacing;
    }
    return rects;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background is transparent to show the underlying screen with backdrop blur and overlay.

          // ── Hanging board system (sways + swings) ──
          Positioned.fill(
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: _buildBoardContent(context),
            ),
          ),

          // ── Close button ──
          Positioned(
            top: MediaQueryData.fromView(View.of(context)).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.paddingOf(context).top;
    final headerHeight = topPadding + 10;

    // ── Empty state ──
    if (widget.affirmations.isEmpty) {
      return _buildEmptyState(context, screenWidth, headerHeight);
    }
    final totalHeight = _calculateTotalHeight(headerHeight);
    final boardRects = _calculateBoardRects(screenWidth, headerHeight);
    final hookCenterX = screenWidth / 2;

    // Calculate vertical positions and heights dynamically for the stack positioned elements
    final List<double> boardYs = [];
    final List<double> boardHeights = [];
    double currentY =
        headerHeight + _Layout.hookDiameter + _Layout.hookToBoardGap;

    for (int i = 0; i < widget.affirmations.length; i++) {
      final aff = widget.affirmations[i];
      final isExpanded = _expandedPlankId == aff.id;
      final totalH = isExpanded ? 192.0 : _Layout.boardHeight;
      boardYs.add(currentY);
      boardHeights.add(totalH);
      currentY += totalH + _Layout.boardSpacing;
    }

    // Pre-build the planks ONCE to avoid rebuilding layout & text trees on animation frames
    final List<Widget> preBuiltPlanks = List.generate(widget.affirmations.length, (i) {
      final aff = widget.affirmations[i];
      final isExpanded = _expandedPlankId == aff.id;
      final targetAngle = i < _targetAngles.length ? _targetAngles[i] : 0.0;

      return AffirmationPlank(
        affirmation: aff,
        colorIndex: i,
        index: i,
        windOffset: 0.0,
        isExpanded: isExpanded,
        repeatCount: widget.repeatCounts[aff.id] ?? 0,
        onTap: () => _togglePlankExpansion(aff.id),
        onFavorite: () {
          ref.read(affirmationsProvider.notifier).toggleFavorite(aff.id);
        },
        onPin: () {
          ref.read(affirmationsProvider.notifier).togglePin(aff.id);
        },
        onRepeat: () => _showRepeatDialog(aff),
        tiltAngle: targetAngle,
      );
    });

    final Widget staticContent = Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Rope system (drawn BEHIND boards) ──
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: RopeSystemPainter(
                hookCenterX: hookCenterX,
                hookBottomY: headerHeight + 8.0,
                boardRects: boardRects,
                holeInset: _Layout.holeInset,
                holeRadius: _Layout.holeRadius,
                thickness: _Layout.ropeThickness,
              ),
            ),
          ),
        ),

        // ── Boards (drawn ON TOP of rope) ──
        ...List.generate(widget.affirmations.length, (i) {
          final boardY = boardYs[i];
          final boardH = boardHeights[i];
          final staticOffset = _getStaticOffsetX(widget.affirmations[i].id);

          return Positioned(
            top: boardY,
            left: 0,
            right: 0,
            height: boardH,
            child: Transform.translate(
              offset: Offset(staticOffset, 0),
              child: AnimatedBuilder(
                animation: _tiltAnimation,
                child: preBuiltPlanks[i],
                builder: (context, child) {
                  final targetAngle = i < _targetAngles.length ? _targetAngles[i] : 0.0;
                  final currentAngle = targetAngle * _tiltAnimation.value;
                  return Transform.rotate(
                    angle: currentAngle,
                    alignment: Alignment.center,
                    child: child,
                  );
                },
              ),
            ),
          );
        }),
      ],
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: _Layout.paddingTop,
        bottom: MediaQuery.of(context).padding.bottom + _Layout.paddingBottom,
      ),
      child: Center(
        child: SizedBox(
          width: screenWidth,
          height: totalHeight + _Layout.paddingTop + _Layout.paddingBottom,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Drop entrance ──
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _dropController,
                  child: staticContent,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _dropAnimation.value),
                      child: child,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    double screenWidth,
    double headerHeight,
  ) {
    final hookCenterX = screenWidth / 2;
    final hookBottomY = headerHeight + _Layout.hookDiameter;
    final emptyBoardRect = Rect.fromLTWH(
      _Layout.boardMarginH,
      headerHeight + _Layout.hookDiameter + _Layout.hookToBoardGap,
      screenWidth - 2 * _Layout.boardMarginH,
      _Layout.boardHeight,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: _Layout.paddingTop,
        bottom: MediaQuery.of(context).padding.bottom + _Layout.paddingBottom,
      ),
      child: Center(
        child: SizedBox(
          width: screenWidth,
          height:
              _calculateTotalHeight(headerHeight) +
              _Layout.paddingTop +
              _Layout.paddingBottom,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Drop entrance (Empty state)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _dropController,
                  builder: (context, _) {
                    return Transform.translate(
                      offset: Offset(0, _dropAnimation.value),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Rope system with one empty board
                          Positioned.fill(
                            child: RepaintBoundary(
                              child: CustomPaint(
                                painter: RopeSystemPainter(
                                  hookCenterX: hookCenterX,
                                  hookBottomY: headerHeight + 8.0,
                                  boardRects: [emptyBoardRect],
                                  holeInset: _Layout.holeInset,
                                  holeRadius: _Layout.holeRadius,
                                  thickness: _Layout.ropeThickness,
                                ),
                              ),
                            ),
                          ),

                          // Empty board
                          Positioned(
                            top:
                                headerHeight +
                                _Layout.hookDiameter +
                                _Layout.hookToBoardGap,
                            left: 0,
                            right: 0,
                            height: _Layout.boardHeight,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: _Layout.boardMarginH,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5EDD8),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Your Daily Spark begins here',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 14,
                                        color: const Color(0xFF5C4E35),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap + to create your first affirmation',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        color: const Color(0xFF8B7355),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRepeatDialog(DailyAffirmation affirmation) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RepeatBottomSheet(
        affirmation: affirmation,
        onRepeatSelected: (count) {
          _startRepeatSession(affirmation, count);
        },
      ),
    );
  }

  void _startRepeatSession(DailyAffirmation affirmation, int targetCount) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => _RepeatSessionSheet(
        affirmation: affirmation,
        targetCount: targetCount,
        onComplete: () {
          ref
              .read(affirmationsProvider.notifier)
              .incrementRepeatCount(affirmation.id, targetCount);
          HapticFeedback.heavyImpact();
        },
      ),
    );
  }
}

/// Bottom sheet for selecting repeat count (10, 25, 50, 100).
class _RepeatBottomSheet extends StatelessWidget {
  final DailyAffirmation affirmation;
  final ValueChanged<int> onRepeatSelected;

  const _RepeatBottomSheet({
    required this.affirmation,
    required this.onRepeatSelected,
  });

  @override
  Widget build(BuildContext context) {
    final counts = [10, 25, 50, 100];
    final icons = [
      Icons.repeat_one_rounded,
      Icons.repeat_rounded,
      Icons.loop_rounded,
      Icons.all_inclusive_rounded,
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1510),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Repeat Affirmation',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '"${affirmation.text}"',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Text(
                'Choose repetition count',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: counts.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onRepeatSelected(counts[index]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icons[index],
                            color: const Color(0xFFB5C4B1),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${counts[index]}x',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen repeat session with counter animation.
class _RepeatSessionSheet extends StatefulWidget {
  final DailyAffirmation affirmation;
  final int targetCount;
  final VoidCallback onComplete;

  const _RepeatSessionSheet({
    required this.affirmation,
    required this.targetCount,
    required this.onComplete,
  });

  @override
  State<_RepeatSessionSheet> createState() => _RepeatSessionSheetState();
}

class _RepeatSessionSheetState extends State<_RepeatSessionSheet>
    with TickerProviderStateMixin {
  int _currentCount = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _increment() {
    if (_currentCount >= widget.targetCount) return;
    HapticFeedback.selectionClick();
    setState(() => _currentCount++);
    _pulseController.forward(from: 0.0);

    if (_currentCount >= widget.targetCount) {
      Future.delayed(const Duration(milliseconds: 500), () {
        HapticFeedback.heavyImpact();
        widget.onComplete();
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentCount / widget.targetCount;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF1A1510), const Color(0xFF0F0C08)],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white54,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 4,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 4,
                                valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFFB5C4B1),
                                ),
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, _) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$_currentCount',
                                        style: GoogleFonts.outfit(
                                          fontSize: 48,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '/ ${widget.targetCount}',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          color: Colors.white.withValues(
                                            alpha: 0.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        widget.affirmation.text,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _increment,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB5C4B1),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFB5C4B1,
                                ).withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            _currentCount >= widget.targetCount
                                ? 'Complete! ✨'
                                : 'Tap to Repeat',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              color: const Color(0xFF3D4F3A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap gently with each breath',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
