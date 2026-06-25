import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/os_providers.dart';
import '../widgets/living_plant.dart';
import '../widgets/workspace_customization.dart';
import '../widgets/todays_checklist.dart';
import '../widgets/celebration_banner.dart';
import '../widgets/premium_shelf_section.dart';
import '../../../vision_room/presentation/screens/vision_room_screen.dart';
import '../../../todo/presentation/widgets/left_floating_shelf.dart';
import '../../../todo/presentation/widgets/floor_glass_panel.dart';
import 'daily_motivation_screen.dart';

// Helper model classes for background effects
class DustParticle {
  double xRatio;
  double yRatio;
  final double speed;
  final double size;
  final double swaySpeed;
  final double swayWidth;

  DustParticle({
    required this.xRatio,
    required this.yRatio,
    required this.speed,
    required this.size,
    required this.swaySpeed,
    required this.swayWidth,
  });
}

class RainDrop {
  double xRatio;
  double yRatio;
  final double speed;

  RainDrop({required this.xRatio, required this.yRatio, required this.speed});
}

class SteamWisp {
  double xOffset;
  double yProgress; // 0.0 to 1.0
  final double speed;
  final double waveFreq;
  final double size;

  SteamWisp({
    required this.xOffset,
    required this.yProgress,
    required this.speed,
    required this.waveFreq,
    required this.size,
  });
}

class OSDashboardScreen extends ConsumerStatefulWidget {
  const OSDashboardScreen({super.key});

  @override
  ConsumerState<OSDashboardScreen> createState() => _OSDashboardScreenState();
}

class _OSDashboardScreenState extends ConsumerState<OSDashboardScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _ambientController;
  late AnimationController _expandController;
  late AnimationController _doorOpenController;
  late AnimationController _motivationController;

  // Particle systems
  late List<DustParticle> _dustParticles;
  late List<RainDrop> _rainDrops;
  late List<SteamWisp> _steamWisps;

  // Real-time elements
  late Timer _realtimeTimer;
  DateTime _currentTime = DateTime.now();

  // Active expanded module ('routine', 'health', 'goals', 'learning', 'finance', 'journal', 'achievements', 'affirmations', 'focus')
  String? _activeModule;

  // Daily Motivation Overlay Screen
  bool _motivationOpen = false;

  // 1. Focus Timer Mode
  Timer? _focusTimer;
  int _focusSeconds = 1500;
  bool _focusRunning = false;

  // 2. Local Priorities Tasks (Goals/Notepad)
  final List<Map<String, dynamic>> _priorities = [
    {'title': 'Finish UI Design', 'checked': true},
    {'title': 'Morning Run', 'checked': false},
    {'title': 'Read 20 Pages', 'checked': false},
  ];

  // 3. Health data
  int _waterLoggedMl = 750;
  double _sleepHours = 7.5;
  int _stepsWalked = 8450;
  bool _workoutComplete = false;

  // 4. Learning data
  int _readPages = 15;
  int _readPagesTarget = 40;
  String _activeBook = 'Atomic Habits';

  // 5. Finance data
  double _savingsSaved = 1250.0;
  double _savingsTarget = 2000.0;

  // 6. Journal data
  final TextEditingController _journalController = TextEditingController();
  bool _journalSaved = false;

  // 7. Affirmations database (custom user manager)
  final List<String> _userAffirmations = [
    'Discipline creates freedom.',
    'I am matching my potential daily.',
    'Focus is my superpower.',
  ];
  final TextEditingController _newAffirmationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    // Setup base controllers
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _doorOpenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _motivationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1400),
        )..addListener(() {
          setState(() {});
        });

    // Setup particle lists
    final random = math.Random();
    _dustParticles = List.generate(12, (idx) {
      return DustParticle(
        xRatio: random.nextDouble(),
        yRatio: random.nextDouble(),
        speed: 0.04 + random.nextDouble() * 0.06,
        size: 1.0 + random.nextDouble() * 1.5,
        swaySpeed: 0.1 + random.nextDouble() * 0.15,
        swayWidth: 4 + random.nextDouble() * 6,
      );
    });

    _rainDrops = List.generate(25, (idx) {
      return RainDrop(
        xRatio: random.nextDouble(),
        yRatio: random.nextDouble(),
        speed: 0.5 + random.nextDouble() * 0.5,
      );
    });

    _steamWisps = List.generate(3, (idx) {
      return SteamWisp(
        xOffset: random.nextDouble() * 8 - 4,
        yProgress: random.nextDouble(),
        speed: 0.2 + random.nextDouble() * 0.2,
        waveFreq: 1.0 + random.nextDouble() * 1.5,
        size: 1.2 + random.nextDouble() * 1.5,
      );
    });

    // Real-time ticking (Analog clock and digital header)
    _realtimeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();

          // Tick particles locally
          for (var p in _dustParticles) {
            p.yRatio = (p.yRatio - (0.006 * p.speed)) % 1.0;
          }
          for (var r in _rainDrops) {
            r.yRatio = (r.yRatio + (0.015 * r.speed)) % 1.0;
            r.xRatio = (r.xRatio - (0.003 * r.speed)) % 1.0;
          }
          for (var s in _steamWisps) {
            s.yProgress += 0.012 * s.speed;
            if (s.yProgress >= 1.0) {
              s.yProgress = 0.0;
              s.xOffset = random.nextDouble() * 8 - 4;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _expandController.dispose();
    _doorOpenController.dispose();
    _motivationController.dispose();
    _realtimeTimer.cancel();
    _focusTimer?.cancel();
    _journalController.dispose();
    _newAffirmationController.dispose();
    super.dispose();
  }

  // ─── AMBIENT WALLPAPER GENERATION ──────────────────────────────────────────
  LinearGradient _getWallGradient(String wallStyle, String ambientMode) {
    Color baseColor;
    switch (wallStyle) {
      case 'Classic Navy':
        baseColor = const Color(0xFF071220);
        break;
      case 'Charcoal':
        baseColor = const Color(0xFF141416);
        break;
      case 'Emerald':
        baseColor = const Color(0xFF041B15);
        break;
      case 'Warm Terracotta':
        baseColor = const Color(0xFF22110E);
        break;
      case 'Deep Indigo':
      default:
        baseColor = const Color(0xFF0D1527);
        break;
    }

    String timeMode = ambientMode;
    if (timeMode == 'Auto') {
      final hour = _currentTime.hour;
      if (hour >= 5 && hour < 12) {
        timeMode = 'Morning';
      } else if (hour >= 12 && hour < 17) {
        timeMode = 'Afternoon';
      } else if (hour >= 17 && hour < 21) {
        timeMode = 'Evening';
      } else {
        timeMode = 'Night';
      }
    }

    Color ambientAccent;
    switch (timeMode) {
      case 'Morning':
        ambientAccent = const Color(0xFF6B4C25); // Sunrise warm amber glow
        break;
      case 'Afternoon':
        ambientAccent = const Color(0xFF1C3252); // Daylight sky reflection
        break;
      case 'Evening':
        ambientAccent = const Color(0xFF5A2A1E); // Warm twilight peach
        break;
      case 'Night':
      default:
        ambientAccent = const Color(0xFF161A24); // Cozy dim lamp shade
        break;
    }

    return LinearGradient(
      colors: [ambientAccent, baseColor, Colors.black],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  // Focus Stopwatch
  void _startFocusTimer() {
    _focusTimer?.cancel();
    setState(() {
      _focusRunning = true;
    });
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_focusSeconds > 0) {
        setState(() {
          _focusSeconds--;
        });
      } else {
        _stopFocusTimer();
        HapticFeedback.vibrate();
        _claimFocusXp();
      }
    });
  }

  void _stopFocusTimer() {
    _focusTimer?.cancel();
    setState(() {
      _focusRunning = false;
    });
  }

  void _resetFocusTimer() {
    _stopFocusTimer();
    setState(() {
      _focusSeconds = 1500;
    });
  }

  void _claimFocusXp() {
    ref
        .read(osStateProvider.notifier)
        .updateWorkspaceSettings(); // Triggers a reload of points in provider
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white10),
        ),
        title: const Text('Focus Completed'),
        content: const Text(
          'Beautiful concentration block. You earned +15 discipline points.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Collect Points',
              style: TextStyle(color: AppColors.accentBlue),
            ),
          ),
        ],
      ),
    );
  }

  // Door interaction
  void _handleDoorTap(bool isUnlocked) {
    HapticFeedback.mediumImpact();
    if (isUnlocked) {
      _doorOpenController.forward().then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VisionRoomScreen()),
        ).then((_) {
          _doorOpenController.reverse();
        });
      });
    } else {
      // Locked: show alert info
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Vision Room is locked. Earn 500 discipline points to unlock!',
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // Transform expansion sheets trigger
  void _expandModule(String module) {
    HapticFeedback.mediumImpact();
    setState(() {
      _activeModule = module;
    });
    _expandController.forward();
  }

  void _closeModule() {
    HapticFeedback.lightImpact();
    _expandController.reverse().then((_) {
      setState(() {
        _activeModule = null;
      });
    });
  }

  void _closeMotivation() {
    HapticFeedback.lightImpact();
    _motivationController.reverse().then((_) {
      setState(() {
        _motivationOpen = false;
      });
    });
  }

  String _formatTimer() {
    final m = (_focusSeconds / 60).floor().toString().padLeft(2, '0');
    final s = (_focusSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(osStateProvider);
    final totalXp = state.xp;
    final isUnlockedVision =
        true; // Always unlocked by default in premium workspace

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenH = constraints.maxHeight;
        final double screenW = constraints.maxWidth;

        // Animations interpolating scale & blur
        final double scaleFactor =
            1.0 - (_expandController.value * 0.07); // shrinks slightly
        final double blurValue =
            _expandController.value * 14.0; // blurs background

        // Cinematic zoom & centering calculations
        final double p = CurvedAnimation(
          parent: _motivationController,
          curve: Curves.easeInOutCubic,
        ).value;

        final double roomScale = (1.0 + (p * 2.2)) * scaleFactor;
        final double roomBlur = (p * 18.0) + (1.0 - p) * blurValue;

        final double cx = screenW * 0.54;
        final double cy = screenH * 0.07 + 75.0;
        final double tx = (screenW * 0.5 - cx) * p;
        final double ty = (screenH * 0.5 - cy) * p;

        final Matrix4 roomTransform = Matrix4.identity()
          ..translate(screenW * 0.5, screenH * 0.5)
          ..scale(roomScale)
          ..translate(-screenW * 0.5, -screenH * 0.5)
          ..translate(tx, ty);

        final Animation<double> motivationFade =
            Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _motivationController,
                curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
              ),
            );
        final Animation<double> motivationScale =
            Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(
                parent: _motivationController,
                curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
              ),
            );

        // Very slow daylight breathing effect (16 seconds cycle)
        final double sunlightIntensity =
            0.15 +
            math.sin(
                  _currentTime.millisecondsSinceEpoch * (2 * math.pi / 16000),
                ) *
                0.08;

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // ─── BACKGROUND LAYER (Living Room Scene) ──────────────────────
              Transform(
                transform: roomTransform,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: roomBlur,
                    sigmaY: roomBlur,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Room background: wall texture, skirting board & perspective floorboards
                      Positioned.fill(
                        child: CustomPaint(
                          painter: RoomBackgroundPainter(
                            wallGradient: _getWallGradient(
                              state.wallColor,
                              state.ambientMode,
                            ),
                            floorHeight: 160,
                            sunlightIntensity: sunlightIntensity,
                          ),
                        ),
                      ),

                      // Rain Effect (If active)
                      if (state.rainMode)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: RainPainter(
                              progress: 0.0,
                              drops: _rainDrops,
                            ),
                          ),
                        ),

                      // 2. THE WINDOW (Top Left, expanded)
                      Positioned(
                        left: screenW * 0.08,
                        top: screenH * 0.06,
                        child: _buildWindow(
                          screenW,
                          screenH,
                          state.ambientMode,
                        ),
                      ),

                      // 4. THE WALL CLOCK (Top Right)
                      Positioned(
                        right: screenW * 0.08,
                        top: screenH * 0.07,
                        child: _buildClock(),
                      ),

                      // 4.6. AFFIRMATION CARD (shifted up 30px, left 15px)
                      Positioned(
                        right: screenW * 0.08 + 39,
                        top: screenH * 0.07 + 60,
                        child: _buildWallArtFrame(screenW, screenH, state),
                      ),

                      // 4.7. Right Floating Shelf (no padding on right)
                      Positioned(
                        right: 0,
                        width: screenW,
                        bottom: 155,
                        child: LeftFloatingShelf(
                          alignLeft: false,
                          woodTexture: state.woodTexture,
                          plantType: state.plantType,
                        ),
                      ),

                      // 5. FLOATING WOODEN SHELF + MODULE OBJECTS (Center)
                      Positioned(
                        left: screenW * 0.06,
                        right: screenW * 0.06,
                        top: screenH * 0.36,
                        child: Center(
                          child: _buildFloatingShelf(screenW, state),
                        ),
                      ),

                      // 5.5. PREMIUM 3D HORIZONTAL SHELF (Personalized Dashboard)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: screenH * 0.36 + 100,
                        child: PremiumShelfSection(
                          state: state,
                          onExpandModule: _expandModule,
                          waterLoggedMl: _waterLoggedMl,
                          sleepHours: _sleepHours,
                          stepsWalked: _stepsWalked,
                          workoutComplete: _workoutComplete,
                          readPages: _readPages,
                          readPagesTarget: _readPagesTarget,
                          activeBook: _activeBook,
                          savingsSaved: _savingsSaved,
                          savingsTarget: _savingsTarget,
                          journalSaved: _journalSaved,
                        ),
                      ),

                      // 5.6. Hanging vines overlay (rendered on top of 3D cards)
                      Positioned(
                        left: screenW * 0.06 + 2,
                        top: screenH * 0.36 + 22,
                        width: 35,
                        height: 140,
                        child: AnimatedBuilder(
                          animation: _ambientController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: HangingVinesPainter(
                                animationValue: _ambientController.value,
                                isLeft: true,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: screenW * 0.06 + 2,
                        top: screenH * 0.36 + 22,
                        width: 35,
                        height: 140,
                        child: AnimatedBuilder(
                          animation: _ambientController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: HangingVinesPainter(
                                animationValue: _ambientController.value,
                                isLeft: false,
                              ),
                            );
                          },
                        ),
                      ),

                      // 7. VISION ROOM WOODEN DOOR (Bottom Left, aligned to floor skirting)
                      Positioned(
                        left: 24,
                        bottom: 154,
                        child: _buildVisionDoor(isUnlockedVision, state),
                      ),

                      // 8. CUSTOMIZATION MINI PAINTING (right of the vision door)
                      Positioned(
                        left: 106,
                        bottom: 178,
                        child: const ThreeDCustomizeSwitch(),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── EXPANDED SHEET OVERLAY PANEL ─────────────────────────────
              if (_activeModule != null)
                FadeTransition(
                  opacity: _expandController,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.94, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _expandController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: _buildExpandedPanel(),
                  ),
                ),

              // Workspace customization is now a 3D tablet on the desk surface.

              // 10. Celebration banner animation overlay
              if (state.showCelebrationBanner)
                CelebrationBanner(
                  onDismiss: () {
                    ref.read(osStateProvider.notifier).hideCelebrationBanner();
                  },
                ),

              // ─── DAILY MOTIVATION OVERLAY SCREEN ──────────────────────────
              if (_motivationOpen)
                FadeTransition(
                  opacity: motivationFade,
                  child: ScaleTransition(
                    scale: motivationScale,
                    child: DailyMotivationScreen(onClose: _closeMotivation),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ─── ROOM COMPONENT WIDGETS ────────────────────────────────────────────────

  // Window visualizer with waving linen curtain & dynamic external skies
  Widget _buildWindow(double screenW, double screenH, String ambientMode) {
    String mode = ambientMode;
    if (mode == 'Auto') {
      final hour = _currentTime.hour;
      if (hour >= 5 && hour < 12)
        mode = 'Morning';
      else if (hour >= 12 && hour < 17)
        mode = 'Afternoon';
      else if (hour >= 17 && hour < 21)
        mode = 'Evening';
      else
        mode = 'Night';
    }

    return Container(
      width: 145,
      height: 195,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The window frame
          Container(
            width: 145,
            height: 195,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155), width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomPaint(
                painter: CityViewWindowPainter(
                  resolvedMode: mode,
                  animationValue: _ambientController.value,
                  isTopWindow: true,
                ),
              ),
            ),
          ),

          // Waving linen curtain hanging on the right side
          Positioned(
            top: 2,
            right: -12,
            bottom: 2,
            width: 44,
            child: CustomPaint(
              painter: CurtainPainter(
                time: _currentTime.millisecondsSinceEpoch * 0.001,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Analog Clock showing actual minutes/hours
  Widget _buildClock() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0F172A),
        border: Border.all(color: const Color(0xFF334155), width: 2.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(painter: AnalogClockPainter(time: _currentTime)),
    );
  }

  Widget _buildDisciplineCard() {
    return SizedBox(
      width: 80,
      height: 120,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: HangingBoardPainter())),
          Positioned(
            top: 24,
            left: 6,
            right: 6,
            bottom: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Discipline',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Georgia',
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Discipline today\nfreedom\ntomorrow.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 7.0,
                    height: 1.25,
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWallArtFrame(double screenW, double screenH, OSState state) {
    // Pendulum angle calculation (slow swing max 1.5 degrees, i.e., ~0.026 rad)
    final double pendulumAngle =
        math.sin(_currentTime.millisecondsSinceEpoch * (2 * math.pi / 10000)) *
        0.022;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() {
          _motivationOpen = true;
        });
        _motivationController.forward();
      },
      child: SizedBox(
        width: screenW * 0.24,
        height: 115,
        child: Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..translate(
              0.0,
              0.0,
              0.1,
            ) // Force GPU layer creation to resolve text glyph subpixel jitter
            ..rotateZ(pendulumAngle),
          filterQuality: FilterQuality.medium,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Ropes and nail painter
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 42,
                child: CustomPaint(painter: FrameWirePainter()),
              ),

              // Frame Body
              Positioned(
                top: 38,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1424), // dark canvas board
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: state.woodTexture == 'Oak'
                            ? const Color(0xFFD7CCC8)
                            : state.woodTexture == 'Mahogany'
                            ? const Color(0xFF5D4037)
                            : const Color(0xFF2E1912), // walnut
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                  ),
                  child: Opacity(
                    opacity: (1.0 - _motivationController.value).clamp(
                      0.0,
                      1.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '"${state.dailyQuote}"',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 7.5,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '— ${state.dailyQuoteAuthor}',
                          style: const TextStyle(
                            fontSize: 6.0,
                            color: Colors.white30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Wooden door integrated into wall next to wooden floorboards
  Widget _buildVisionDoor(bool isUnlocked, OSState state) {
    return GestureDetector(
      onTap: () => _handleDoorTap(isUnlocked),
      child: Column(
        children: [
          SizedBox(
            width: 70,
            height: 110,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Door frame back portal
                Container(
                  width: 70,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1424),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    border: Border.all(
                      color: const Color(0xFF334155),
                      width: 3.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 10,
                        offset: const Offset(2, 2), // cast wall shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (isUnlocked)
                          Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.amber.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                                radius: 0.8,
                              ),
                            ),
                          ),
                        AnimatedBuilder(
                          animation: _doorOpenController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: DoorPainter3D(
                                openProgress: _doorOpenController.value,
                                isUnlocked: isUnlocked,
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
        ],
      ),
    );
  }

  // Floating Wooden Shelf with custom vector miniatures
  Widget _buildFloatingShelf(double screenW, OSState state) {
    Color woodColor;
    if (state.woodTexture == 'Oak') {
      woodColor = const Color(0xFFC7B3A3);
    } else if (state.woodTexture == 'Mahogany') {
      woodColor = const Color(0xFF4A2C22);
    } else {
      woodColor = const Color(0xFF2E1912); // classic walnut
    }

    final double shelfWidth = screenW * 0.88;
    // Calculate miniature size dynamically based on available shelf width
    final double itemSize = ((shelfWidth - 24) / 7.8).clamp(24.0, 42.0);

    return Container(
      width: shelfWidth,
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Soft wall drop shadow underneath the shelf
          Positioned(
            top: 24,
            left: 20,
            right: 20,
            height: 35,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                  radius: 1.8,
                ),
              ),
            ),
          ),

          // 2. Custom wall support brackets
          Positioned(
            top: 24,
            left: shelfWidth * 0.15,
            child: _buildShelfBracket(),
          ),
          Positioned(
            top: 24,
            right: shelfWidth * 0.15,
            child: _buildShelfBracket(),
          ),

          // 3. 3D Wooden Plank
          // Top Slant Surface
          Positioned(
            top: 18,
            left: 2,
            right: 2,
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
          // Front Edge Thickness
          Positioned(
            top: 24,
            left: 0,
            right: 0,
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

          // 4. Custom Miniature Objects sitting spaced out (Dynamic scaling)
          Positioned(
            top: 24 - itemSize,
            left: 12,
            right: 12,
            height: itemSize,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildShelfItem(
                  'routine',
                  'Routine',
                  CalendarMiniaturePainter(),
                  itemSize,
                ),
                if (state.selectedLifeAreas.contains('health'))
                  _buildShelfItem(
                    'health',
                    'Health',
                    DumbbellMiniaturePainter(),
                    itemSize,
                  ),
                _buildShelfItem(
                  'goals',
                  'Goals',
                  TargetMiniaturePainter(),
                  itemSize,
                ),
                if (state.selectedLifeAreas.contains('reading'))
                  _buildShelfItem(
                    'learning',
                    'Learning',
                    BookstackMiniaturePainter(),
                    itemSize,
                  ),
                if (state.selectedLifeAreas.contains('finance'))
                  _buildShelfItem(
                    'finance',
                    'Finance',
                    WalletMiniaturePainter(),
                    itemSize,
                  ),
                if (state.selectedLifeAreas.contains('journaling'))
                  _buildShelfItem(
                    'journal',
                    'Journal',
                    NotebookMiniaturePainter(),
                    itemSize,
                  ),
                _buildShelfItem(
                  'achievements',
                  'Achievements',
                  GlassTrophyMiniaturePainter(),
                  itemSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShelfBracket() {
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

  Widget _buildShelfItem(
    String id,
    String label,
    CustomPainter painter,
    double sizeVal,
  ) {
    final bool isSelected = _activeModule == id;
    return Tooltip(
      message: label,
      textStyle: const TextStyle(fontSize: 9, color: Colors.white),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: GestureDetector(
        onTap: () => _expandModule(id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, isSelected ? -8 : 0, 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.accentBlue.withValues(alpha: 0.6),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: AnimatedScale(
            scale: isSelected ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: sizeVal,
              height: sizeVal,
              child: CustomPaint(painter: painter),
            ),
          ),
        ),
      ),
    );
  }

  // ─── EXPANDED MODULE SHEETS PANEL ──────────────────────────────────────────
  Widget _buildExpandedPanel() {
    Widget panelContent;

    switch (_activeModule) {
      case 'routine':
        panelContent = _buildRoutineSheetContent();
        break;
      case 'health':
        panelContent = _buildHealthSheetContent();
        break;
      case 'goals':
        panelContent = _buildGoalsSheetContent();
        break;
      case 'learning':
        panelContent = _buildLearningSheetContent();
        break;
      case 'finance':
        panelContent = _buildFinanceSheetContent();
        break;
      case 'journal':
        panelContent = _buildJournalSheetContent();
        break;
      case 'achievements':
        panelContent = _buildAchievementsSheetContent();
        break;
      case 'affirmations':
        panelContent = _buildAffirmationsSheetContent();
        break;
      case 'focus':
        panelContent = _buildFocusSheetContent();
        break;
      default:
        panelContent = const SizedBox();
    }

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: const Color(0xFF0F1424).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Sheet Header Row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activeModule!.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentBlue,
                      letterSpacing: 1.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white60,
                    ),
                    onPressed: _closeModule,
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),

            // Content scroll area
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: panelContent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. ROUTINE SHEET (Habits check)
  Widget _buildRoutineSheetContent() {
    return const TodaysChecklist(showTitle: true);
  }

  // 2. HEALTH SHEET (Water, Steps, Sleep, Workout)
  Widget _buildHealthSheetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Water
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.local_drink_rounded,
                        color: AppColors.accentBlue,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Water Hydration',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$_waterLoggedMl / 3000 ml',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _waterLoggedMl / 3000.0,
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accentBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _waterLoggedMl = (_waterLoggedMl + 250).clamp(0, 4000);
                      });
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add 250ml'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue.withValues(
                        alpha: 0.15,
                      ),
                      foregroundColor: AppColors.accentBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Sleep
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.nights_stay_rounded,
                        color: Colors.indigoAccent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sleep Tracker',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_sleepHours.toStringAsFixed(1)} hrs logged',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Slider(
                value: _sleepHours,
                min: 4.0,
                max: 12.0,
                divisions: 16,
                activeColor: Colors.indigoAccent,
                onChanged: (val) {
                  setState(() {
                    _sleepHours = val;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Steps & Workout
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.directions_walk_rounded,
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Steps Walked',
                      style: TextStyle(fontSize: 11, color: Colors.white30),
                    ),
                    Text(
                      '$_stepsWalked / 10k',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _workoutComplete = !_workoutComplete;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _workoutComplete
                        ? AppColors.accentEmerald.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _workoutComplete
                          ? AppColors.accentEmerald.withValues(alpha: 0.3)
                          : Colors.white10,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        color: _workoutComplete
                            ? AppColors.accentEmerald
                            : Colors.redAccent,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Active Workout',
                        style: TextStyle(fontSize: 11, color: Colors.white30),
                      ),
                      Text(
                        _workoutComplete ? 'Completed!' : 'Tap to Complete',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _workoutComplete
                              ? AppColors.accentEmerald
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 3. GOALS SHEET (Priorities check)
  Widget _buildGoalsSheetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Active Priorities',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(_priorities.length, (idx) {
            final p = _priorities[idx];
            final isChecked = p['checked'] == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isChecked
                    ? AppColors.accentBlue.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isChecked
                      ? AppColors.accentBlue.withValues(alpha: 0.3)
                      : Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    activeColor: AppColors.accentBlue,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _priorities[idx]['checked'] = val;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p['title'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isChecked ? Colors.white60 : Colors.white,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  // 4. LEARNING SHEET (Reading block log)
  Widget _buildLearningSheetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bookmark_rounded, color: Colors.amberAccent),
                  SizedBox(width: 8),
                  Text(
                    'Current Book',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _activeBook,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pages read',
                    style: TextStyle(color: Colors.white30, fontSize: 12),
                  ),
                  Text(
                    '$_readPages / $_readPagesTarget pages',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _readPages / _readPagesTarget.toDouble(),
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.amberAccent,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _readPages = (_readPages + 5).clamp(
                          0,
                          _readPagesTarget,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('+5 Pages'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. FINANCE SHEET (Goal progress)
  Widget _buildFinanceSheetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.savings_rounded, color: Colors.amberAccent),
                      SizedBox(width: 8),
                      Text(
                        'Savings Target',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '\$${_savingsSaved.toInt()} / \$${_savingsTarget.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _savingsSaved / _savingsTarget,
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.amberAccent,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Slider(
                value: _savingsSaved,
                min: 0.0,
                max: _savingsTarget,
                activeColor: Colors.amberAccent,
                onChanged: (val) {
                  setState(() {
                    _savingsSaved = val;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 6. JOURNAL SHEET (Write reflections)
  Widget _buildJournalSheetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Daily Reflection',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'What did you do today that brought you closer to your goals?',
          style: TextStyle(color: Colors.white30, fontSize: 12),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _journalController,
          maxLines: 8,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Start writing your entries...',
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.02),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accentBlue),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            setState(() {
              _journalSaved = true;
            });
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _journalSaved = false);
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            _journalSaved ? 'Saved Successful ✓' : 'Save Entry',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // 7. ACHIEVEMENTS SHEET (Badges trophy shelf)
  Widget _buildAchievementsSheetContent() {
    final state = ref.watch(osStateProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Level Indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discipline Level ${state.level}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${state.xp} XP',
                    style: const TextStyle(
                      color: Colors.yellowAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (state.xp % 500) / 500.0,
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.yellowAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Trophy Badges',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildBadgeItem('🏆', 'Consistent', '7-Day streak'),
            _buildBadgeItem('🔥', 'Ignition', 'First habit'),
            _buildBadgeItem('🎯', 'Bullseye', 'Clean checklist'),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeItem(String emoji, String title, String sub) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(fontSize: 8.5, color: Colors.white30),
          ),
        ],
      ),
    );
  }

  // 8. AFFIRMATIONS EDIT SHEETS (Picture Frame click)
  Widget _buildAffirmationsSheetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Daily Affirmations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: _userAffirmations.map((aff) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.amberAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      aff,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white30,
                      size: 18,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _userAffirmations.remove(aff);
                      });
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Add Affirmation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white30,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newAffirmationController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Type custom affirmation...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.02),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: AppColors.accentBlue,
                size: 30,
              ),
              onPressed: () {
                final txt = _newAffirmationController.text.trim();
                if (txt.isNotEmpty) {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _userAffirmations.add(txt);
                    _newAffirmationController.clear();
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  // 9. FOCUS STOPWATCH TIMER SHEET (Desk button click)
  Widget _buildFocusSheetContent() {
    final double breatheScale = _focusRunning
        ? (1.0 + math.sin(_currentTime.millisecondsSinceEpoch * 0.002) * 0.06)
        : 1.0;

    return Column(
      children: [
        const SizedBox(height: 24),
        // Breathing circles visualizer
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: Matrix4.identity()
              ..translate(25.0, 25.0, 0.0)
              ..scale(breatheScale, breatheScale, 1.0)
              ..translate(-25.0, -25.0, 0.0),
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBlue.withValues(
                alpha: _focusRunning ? 0.08 : 0.03,
              ),
              border: Border.all(
                color: AppColors.accentBlue.withValues(
                  alpha: _focusRunning ? 0.4 : 0.1,
                ),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _focusRunning ? 'BREATHE' : 'FOCUS',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Time countdown text
        Text(
          _formatTimer(),
          style: GoogleFonts.spaceMono(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 36),

        // Play Pause Reset
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 48,
              icon: Icon(
                _focusRunning
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                color: AppColors.accentBlue,
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                if (_focusRunning)
                  _stopFocusTimer();
                else
                  _startFocusTimer();
              },
            ),
            const SizedBox(width: 20),
            IconButton(
              iconSize: 28,
              icon: const Icon(Icons.replay_rounded, color: Colors.white30),
              onPressed: () {
                HapticFeedback.lightImpact();
                _resetFocusTimer();
              },
            ),
          ],
        ),
      ],
    );
  }
}

// ─── BACKGROUND FX CUSTOM PAINTERS ───────────────────────────────────────────

// 1. Room Background: Wall stucco texturing and bottom floorboards in perspective
class RoomBackgroundPainter extends CustomPainter {
  final LinearGradient wallGradient;
  final double floorHeight;
  final double sunlightIntensity;

  RoomBackgroundPainter({
    required this.wallGradient,
    required this.floorHeight,
    required this.sunlightIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double wallH = h - floorHeight;

    final Rect wallRect = Rect.fromLTRB(0, 0, w, wallH);
    final Rect floorRect = Rect.fromLTRB(0, wallH, w, h);

    // 1. Wall Background Gradient
    final Paint wallPaint = Paint()
      ..shader = wallGradient.createShader(wallRect);
    canvas.drawRect(wallRect, wallPaint);

    // Soft wall shadow / ambient gradient in corners
    final cornerShadow = RadialGradient(
      colors: [Colors.black.withValues(alpha: 0.35), Colors.transparent],
      radius: 1.3,
    ).createShader(Rect.fromLTRB(-100, -100, w + 100, wallH + 100));
    canvas.drawRect(
      wallRect,
      Paint()
        ..shader = cornerShadow
        ..blendMode = BlendMode.multiply,
    );

    // ── WALL ART: Motivational quotes & brushstroke accents ──────────────────
    _paintWallArt(canvas, w, wallH);

    // 2. Baseboard / Skirting Molding (gives solid perspective depth)
    final double baseboardH = 12.0;
    final Rect baseboardRect = Rect.fromLTRB(0, wallH - baseboardH, w, wallH);
    final baseboardPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF1E293B), const Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(baseboardRect);
    canvas.drawRect(baseboardRect, baseboardPaint);
    canvas.drawLine(
      Offset(0, wallH - baseboardH),
      Offset(w, wallH - baseboardH),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..strokeWidth = 0.8,
    );
    canvas.drawLine(
      Offset(0, wallH),
      Offset(w, wallH),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..strokeWidth = 1.2,
    );

    // 3. Wooden Floorboards in perspective
    final floorGradient = LinearGradient(
      colors: [const Color(0xFF2E1C0C), const Color(0xFF160A02)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    canvas.drawRect(
      floorRect,
      Paint()..shader = floorGradient.createShader(floorRect),
    );

    // Horizontal floorboard spacing lines
    final plankPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..strokeWidth = 1.4;
    final int plankCount = 6;
    for (int j = 0; j <= plankCount; j++) {
      final double t = j / plankCount;
      final double y = wallH + floorHeight * math.pow(t, 1.38);
      canvas.drawLine(Offset(0, y), Offset(w, y), plankPaint);
      if (j > 0 && j < plankCount) {
        canvas.drawLine(
          Offset(0, y + 1),
          Offset(w, y + 1),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.015)
            ..strokeWidth = 0.6,
        );
      }
    }

    // Converging vertical joint lines
    final jointPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    final Offset vanishingPoint = Offset(w / 2, -h * 0.15);
    for (int k = -3; k <= 7; k++) {
      final double startX = (w / 4.5) * k;
      final Offset startFloor = Offset(startX, wallH);
      final double dirX = startFloor.dx - vanishingPoint.dx;
      final double dirY = startFloor.dy - vanishingPoint.dy;
      final double scale = (h - wallH) / dirY;
      final Offset endFloor = Offset(startFloor.dx + dirX * scale, h);
      canvas.drawLine(startFloor, endFloor, jointPaint);
    }
  }

  void _paintWallArt(Canvas canvas, double w, double wallH) {
    _paintFramedQuote(
      canvas,
      x: w * 0.03,
      y: wallH * 0.55,
      frameW: w * 0.22,
      frameH: wallH * 0.30,
      quote: '"Small steps\nevery day."',
      author: '— Getzio Focus',
      accentColor: const Color(0xFFD4A017),
    );
    _paintFramedQuote(
      canvas,
      x: w * 0.75,
      y: wallH * 0.52,
      frameW: w * 0.22,
      frameH: wallH * 0.30,
      quote: '"Build the\nbest version."',
      author: '— Daily Discipline',
      accentColor: const Color(0xFF4A8FA8),
    );
  }

  void _paintFramedQuote(
    Canvas canvas, {
    required double x,
    required double y,
    required double frameW,
    required double frameH,
    required String quote,
    required String author,
    required Color accentColor,
  }) {
    // Wall quotes painted directly and faintly on the wall, no containers/frames
    final qPainter = TextPainter(
      text: TextSpan(
        text: quote,
        style: TextStyle(
          fontSize: frameW * 0.065, // Small font size
          color: Colors.white.withValues(alpha: 0.32),
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.6,
          height: 1.3,
          fontFamily: 'Outfit',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: frameW);
    qPainter.paint(
      canvas,
      Offset(
        x + (frameW - qPainter.width) / 2,
        y + (frameH - qPainter.height) / 2 - 8,
      ),
    );

    final aPainter = TextPainter(
      text: TextSpan(
        text: author,
        style: TextStyle(
          fontSize: frameW * 0.045, // Smaller font size
          color: accentColor.withValues(alpha: 0.38),
          fontWeight: FontWeight.w400,
          letterSpacing: 0.8,
          fontFamily: 'Outfit',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: frameW);
    aPainter.paint(
      canvas,
      Offset(
        x + (frameW - aPainter.width) / 2,
        y + (frameH - qPainter.height) / 2 + qPainter.height + 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant RoomBackgroundPainter oldDelegate) =>
      oldDelegate.sunlightIntensity != sunlightIntensity ||
      oldDelegate.wallGradient != wallGradient;
}

// 2. Waving linen window curtain (curtain rod and fabric drapes)
class CurtainPainter extends CustomPainter {
  final double time;

  CurtainPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Curtain rod
    canvas.drawLine(
      Offset(-6, 2),
      Offset(w + 6, 2),
      Paint()
        ..color = const Color(0xFF37474F)
        ..strokeWidth = 2.0,
    );

    final path = Path();
    path.moveTo(0, 4);

    final double waveMultiplier = math.sin(time * 1.5) * 1.5;

    path.lineTo(w, 4);
    for (double y = 4; y <= h; y += 4) {
      final double sway =
          math.sin((y / h * 4 * math.pi) + time * 1.8) * (2.0 + waveMultiplier);
      path.lineTo(w - 2 + sway, y);
    }
    path.lineTo(0, h);
    path.close();

    final curtainPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.06),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, curtainPaint);

    final foldPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.45, 4), Offset(w * 0.5, h), foldPaint);
    canvas.drawLine(Offset(w * 0.75, 4), Offset(w * 0.8, h), foldPaint);
  }

  @override
  bool shouldRepaint(covariant CurtainPainter oldDelegate) => true;
}

// 3. Wall hanging wire and nail painter
class FrameWirePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final nailPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.fill;

    final ropePaint = Paint()
      ..color =
          const Color(0xFF8D6E63) // brown fiber rope
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Draw nail in the wall
    canvas.drawCircle(Offset(size.width / 2, 2), 2.0, nailPaint);

    // Draw rope lines hanging down
    canvas.drawLine(
      Offset(size.width / 2, 2),
      Offset(size.width * 0.15, 38),
      ropePaint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 2),
      Offset(size.width * 0.85, 38),
      ropePaint,
    );
  }

  @override
  bool shouldRepaint(covariant FrameWirePainter oldDelegate) => false;
}

// 4. Real-time analog clock painter
class AnalogClockPainter extends CustomPainter {
  final DateTime time;

  AnalogClockPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final center = Offset(radius, radius);

    // Draw clock dials/points
    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * math.pi / 180;
      final point = Offset(
        center.dx + math.sin(angle) * (radius - 5),
        center.dy - math.cos(angle) * (radius - 5),
      );
      canvas.drawCircle(point, 1.2, paint);
    }

    // Hour hand
    final hrAngle = ((time.hour % 12) * 30 + time.minute * 0.5) * math.pi / 180;
    canvas.drawLine(
      center,
      Offset(
        center.dx + math.sin(hrAngle) * (radius - 14),
        center.dy - math.cos(hrAngle) * (radius - 14),
      ),
      Paint()
        ..color = Colors.white
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.4,
    );

    // Minute hand
    final minAngle = time.minute * 6 * math.pi / 180;
    canvas.drawLine(
      center,
      Offset(
        center.dx + math.sin(minAngle) * (radius - 9),
        center.dy - math.cos(minAngle) * (radius - 9),
      ),
      Paint()
        ..color = Colors.white70
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.4,
    );

    // Second hand
    final secAngle = time.second * 6 * math.pi / 180;
    canvas.drawLine(
      center,
      Offset(
        center.dx + math.sin(secAngle) * (radius - 7),
        center.dy - math.cos(secAngle) * (radius - 7),
      ),
      Paint()
        ..color = Colors.redAccent
        ..strokeWidth = 0.8,
    );

    // Center pin
    canvas.drawCircle(center, 2, Paint()..color = Colors.redAccent);
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter oldDelegate) => true;
}

// 5. 3D door frame painter (Hinged rotation visual)
class DoorPainter3D extends CustomPainter {
  final double openProgress;
  final bool isUnlocked;

  DoorPainter3D({required this.openProgress, required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Draw dark portal background
    final portalPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), portalPaint);

    if (isUnlocked && openProgress > 0.05) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFB8963E).withValues(alpha: 0.25 * openProgress),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), glowPaint);
    }

    // Door Slab drawing with 3D Hinge perspective
    canvas.save();
    // Rotate relative to right edge of frame (hinge on the right)
    canvas.translate(w, h / 2);
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0035) // perspective distortion
      ..rotateY(openProgress * math.pi / 2.3);
    canvas.transform(matrix.storage);
    canvas.translate(-w, -h / 2);

    // Door base slab color
    final doorPaint = Paint()
      ..color = isUnlocked ? const Color(0xFF3E2723) : const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isUnlocked
          ? const Color(0xFFC9A96E).withValues(alpha: 0.7)
          : Colors.white24
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final doorRect = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRect(doorRect, doorPaint);
    canvas.drawRect(doorRect, borderPaint);

    // Bevel highlights inside slab
    canvas.drawRect(doorRect.deflate(5), borderPaint..strokeWidth = 0.8);

    // Door knob
    canvas.drawCircle(
      Offset(8, h / 2),
      2.5,
      Paint()..color = isUnlocked ? const Color(0xFFB8963E) : Colors.white30,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DoorPainter3D oldDelegate) =>
      oldDelegate.openProgress != openProgress ||
      oldDelegate.isUnlocked != isUnlocked;
}

// 6. Coffee Mug steam wisp painter
class SteamPainter extends CustomPainter {
  final List<SteamWisp> wisps;

  SteamPainter({required this.wisps});

  @override
  void paint(Canvas canvas, Size size) {
    final double midX = size.width / 2;

    for (var w in wisps) {
      final double y = size.height * (1.0 - w.yProgress);
      final double x =
          midX +
          w.xOffset +
          math.sin(w.yProgress * w.waveFreq * 2 * math.pi) * 3.5;
      final double alpha = (1.0 - w.yProgress).clamp(0.0, 1.0) * 0.25;

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), w.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SteamPainter oldDelegate) => true;
}

// 9. Floating Dust Particles Painter
class DustPainter extends CustomPainter {
  final double progress;
  final List<DustParticle> particles;

  DustPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    for (var p in particles) {
      final double x =
          (p.xRatio * size.width) +
          math.sin(p.yRatio * 2 * math.pi * p.swaySpeed) * p.swayWidth;
      final double y = p.yRatio * size.height;
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DustPainter oldDelegate) => true;
}

// 10. Rain Window Streaks Painter
class RainPainter extends CustomPainter {
  final double progress;
  final List<RainDrop> drops;

  RainPainter({required this.progress, required this.drops});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (var r in drops) {
      final double x = r.xRatio * size.width;
      final double y = r.yRatio * size.height;
      canvas.drawLine(Offset(x, y), Offset(x - 2, y + 10), paint);
    }
  }

  @override
  bool shouldRepaint(covariant RainPainter oldDelegate) => true;
}

// ─── SHELF MINIATURES VECTOR PAINTERS ────────────────────────────────────────

// 📅 Routine Miniature: flip calendar block
class CalendarMiniaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Drop shadow
    canvas.drawOval(
      Rect.fromLTRB(2, h - 3, w - 2, h),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // Stand
    final standPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(4, 8, w - 8, h - 10));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 8, w - 8, h - 10),
        const Radius.circular(3),
      ),
      standPaint,
    );

    // Paper sheets
    final paperPaint = Paint()..color = const Color(0xFFE9E9E9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6, 12, w - 12, h - 16),
        const Radius.circular(2),
      ),
      paperPaint,
    );

    // Red header strip
    final redStripPaint = Paint()..color = Colors.red[700]!;
    canvas.drawPath(
      Path()..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(6, 12, w - 12, 6),
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
      ),
      redStripPaint,
    );

    // Binder top rings
    final ringPaint = Paint()
      ..color = const Color(0xFFCFD8DC)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.35, 11), width: 4, height: 6),
      -math.pi,
      math.pi,
      false,
      ringPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.65, 11), width: 4, height: 6),
      -math.pi,
      math.pi,
      false,
      ringPaint,
    );

    // Date text lines
    final textPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.4, h * 0.65),
      Offset(w * 0.6, h * 0.65),
      textPaint,
    );
    canvas.drawLine(
      Offset(w * 0.4, h * 0.78),
      Offset(w * 0.55, h * 0.78),
      textPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CalendarMiniaturePainter oldDelegate) => false;
}

// 💪 Health Miniature: marble/chrome dumbbell sculpture
class DumbbellMiniaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final double midY = h * 0.55;

    // Drop shadow
    canvas.drawOval(
      Rect.fromLTRB(4, h - 3, w - 4, h),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // Barbell Rack/Stand
    final rackPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(8, h - 2), Offset(10, midY + 4), rackPaint);
    canvas.drawLine(Offset(w - 8, h - 2), Offset(w - 10, midY + 4), rackPaint);
    canvas.drawLine(
      Offset(6, h - 2),
      Offset(w - 6, h - 2),
      Paint()
        ..color = const Color(0xFF263238)
        ..strokeWidth = 2,
    );

    // Central chrome handle bar
    final barPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFECEFF1), Color(0xFF78909C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(8, midY - 2, w - 8, midY + 2));
    canvas.drawRect(Rect.fromLTRB(8, midY - 2, w - 8, midY + 2), barPaint);

    // Weight Plates (stacked layers)
    final platePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF37474F), Color(0xFF212121)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTRB(6, midY - 10, 10, midY + 10));

    // Left plates
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6, midY - 9, 3, 18),
        const Radius.circular(1),
      ),
      platePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(9, midY - 7, 3, 14),
        const Radius.circular(1),
      ),
      platePaint,
    );

    // Right plates
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w - 9, midY - 9, 3, 18),
        const Radius.circular(1),
      ),
      platePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w - 12, midY - 7, 3, 14),
        const Radius.circular(1),
      ),
      platePaint,
    );
  }

  @override
  bool shouldRepaint(covariant DumbbellMiniaturePainter oldDelegate) => false;
}

// 🎯 Goals Miniature: standing dartboard target stand with arrow hit
class TargetMiniaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h * 0.4);

    // Shadow
    canvas.drawOval(
      Rect.fromLTRB(6, h - 3, w - 6, h),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // Standing tripod frame (brass-like)
    final standPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD54F), Color(0xFFF57F17)],
      ).createShader(Rect.fromLTWH(4, h * 0.4, w - 8, h * 0.6))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(w / 2, h - 2), standPaint);
    canvas.drawLine(center, Offset(w * 0.25, h - 2), standPaint);
    canvas.drawLine(center, Offset(w * 0.75, h - 2), standPaint);

    // Target rings
    final redPaint = Paint()
      ..color = const Color(0xFFC62828)
      ..style = PaintingStyle.fill;
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12, redPaint);
    canvas.drawCircle(center, 8, whitePaint);
    canvas.drawCircle(center, 4, redPaint);

    // Golden Arrow struck in the center!
    final arrowPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    // Arrow shaft coming from top right
    canvas.drawLine(Offset(center.dx + 12, center.dy - 12), center, arrowPaint);
    // Arrow fletching (feathers)
    final featherPaint = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx + 11, center.dy - 11),
      1.8,
      featherPaint,
    );
    canvas.drawCircle(Offset(center.dx + 9, center.dy - 9), 1.2, featherPaint);
  }

  @override
  bool shouldRepaint(covariant TargetMiniaturePainter oldDelegate) => false;
}

// 📖 Learning Miniature: stack of colored leather books
class BookstackMiniaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Drop shadow
    canvas.drawOval(
      Rect.fromLTRB(2, h - 3, w - 2, h),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // Books stack from bottom to top
    final borderPaint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Bottom book (Navy)
    final bottomRect = Rect.fromLTWH(4, h - 10, w - 8, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomRect, const Radius.circular(1.5)),
      Paint()..color = const Color(0xFF1565C0),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomRect, const Radius.circular(1.5)),
      borderPaint,
    );
    final goldPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 0.6;
    canvas.drawLine(Offset(6, h - 10), Offset(6, h - 2), goldPaint);
    canvas.drawLine(Offset(8, h - 10), Offset(8, h - 2), goldPaint);

    // Middle book (Red)
    final middleRect = Rect.fromLTWH(6, h - 17, w - 11, 7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(middleRect, const Radius.circular(1.5)),
      Paint()..color = const Color(0xFFC62828),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(middleRect, const Radius.circular(1.5)),
      borderPaint,
    );
    canvas.drawLine(Offset(8, h - 17), Offset(8, h - 10), goldPaint);

    // Top book (Green)
    final topRect = Rect.fromLTWH(9, h - 23, w - 16, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(topRect, const Radius.circular(1.5)),
      Paint()..color = const Color(0xFF2E7D32),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(topRect, const Radius.circular(1.5)),
      borderPaint,
    );
    canvas.drawLine(Offset(11, h - 23), Offset(11, h - 17), goldPaint);
  }

  @override
  bool shouldRepaint(covariant BookstackMiniaturePainter oldDelegate) => false;
}

// 💰 Finance Miniature: luxury cardholder wallet
class WalletMiniaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Drop shadow
    canvas.drawOval(
      Rect.fromLTRB(4, h - 3, w - 4, h),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // Leather wallet body (charcoal/matte black)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2E1C0C), Color(0xFF1E0A00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(5, 12, w - 10, h - 16));

    final walletRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(5, 12, w - 10, h - 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(walletRect, bodyPaint);

    // Fine leather stitching
    final stitchPaint = Paint()
      ..color = const Color(0xFFFFCC80).withValues(alpha: 0.4)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(walletRect.deflate(1.5), stitchPaint);

    // Gold clip
    final clipPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
      ).createShader(Rect.fromLTWH(w * 0.4, 12, 6, 8));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, 11, 5, 7),
        const Radius.circular(1),
      ),
      clipPaint,
    );

    // Credit card corners
    final card1 = Paint()..color = Colors.blue[300]!;
    final card2 = Paint()..color = Colors.amberAccent;
    canvas.drawRect(Rect.fromLTWH(8, 8, 8, 4), card1);
    canvas.drawRect(Rect.fromLTWH(18, 9, 6, 3), card2);
  }

  @override
  bool shouldRepaint(covariant WalletMiniaturePainter oldDelegate) => false;
}

// 📝 Journal Miniature: forest green notebook with pen
class NotebookMiniaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Drop shadow
    canvas.drawOval(
      Rect.fromLTRB(4, h - 3, w - 4, h),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // Leather cover (Forest Green)
    final coverPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1B5E20), Color(0xFF003300)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(6, 6, w - 12, h - 11));

    final notebookRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(6, 6, w - 12, h - 11),
      const Radius.circular(3),
    );
    canvas.drawRRect(notebookRect, coverPaint);

    // Elastic band
    final strapPaint = Paint()
      ..color = const Color(0xFF001500)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(w * 0.72, 6), Offset(w * 0.72, h - 5), strapPaint);

    // Ribbon bookmark hanging
    final ribbonPaint = Paint()
      ..color = const Color(0xFFC62828)
      ..style = PaintingStyle.fill;
    final ribbon = Path()
      ..moveTo(w * 0.35, h - 5)
      ..lineTo(w * 0.42, h - 1)
      ..lineTo(w * 0.42, h - 5)
      ..close();
    canvas.drawPath(ribbon, ribbonPaint);

    // Silver pen lying diagonally
    final penPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFECEFF1), Color(0xFF90A4AE)],
      ).createShader(Rect.fromLTRB(8, 10, w - 12, h - 7))
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(8, h - 7), Offset(w - 12, 10), penPaint);
  }

  @override
  bool shouldRepaint(covariant NotebookMiniaturePainter oldDelegate) => false;
}

// 🏆 Achievements Miniature: faceted glass trophy
class GlassTrophyMiniaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Drop shadow
    canvas.drawOval(
      Rect.fromLTRB(4, h - 3, w - 4, h),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // Marble Base
    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF37474F), Color(0xFF212121)],
      ).createShader(Rect.fromLTWH(w * 0.25, h - 9, w * 0.5, 7));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h - 9, w * 0.56, 7),
        const Radius.circular(1.5),
      ),
      basePaint,
    );

    // Glass Stem
    final glassPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    final glassBorder = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRect(Rect.fromLTWH(w * 0.44, h - 16, w * 0.12, 7), glassPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.44, h - 16, w * 0.12, 7), glassBorder);

    // Star shape
    final path = Path();
    final double centerX = w / 2;
    final double centerY = h * 0.4;
    final double outerRadius = 9;
    final double innerRadius = 4.5;
    final int points = 5;

    for (int i = 0; i < points * 2; i++) {
      final double angle = i * math.pi / points - math.pi / 2;
      final double r = i.isEven ? outerRadius : innerRadius;
      final double x = centerX + math.cos(angle) * r;
      final double y = centerY + math.sin(angle) * r;
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();

    canvas.drawPath(path, glassPaint);
    canvas.drawPath(path, glassBorder);

    // Shine highlight reflection
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX - 4, centerY - 4),
      Offset(centerX - 2, centerY + 2),
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant GlassTrophyMiniaturePainter oldDelegate) =>
      false;
}

// ─── 3D HANGING BOARD PAINTER (Discipline Board) ─────────────────────────────
class HangingBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final double hookX = w / 2;
    final double hookY = 8.0;

    final double boardTop = 32.0;
    final double boardLeft = 8.0;
    final double boardRight = w - 8.0;
    final double boardBot = h - 6.0;

    // 1. Draw hanging string (brass/gold wire)
    final stringPaint = Paint()
      ..color = const Color(0xFF8B6C25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Draw string from left connector to hook and then to right connector
    final stringPath = Path()
      ..moveTo(boardLeft + 8, boardTop)
      ..lineTo(hookX, hookY)
      ..lineTo(boardRight - 8, boardTop);
    canvas.drawPath(stringPath, stringPaint);

    // 2. Draw wall peg/hook (brass/bronze screw head)
    final hookPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFD4A853), Color(0xFF5A451A)],
        center: Alignment(-0.3, -0.3),
      ).createShader(Rect.fromCircle(center: Offset(hookX, hookY), radius: 3.5))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(hookX, hookY), 3.5, hookPaint);
    // Darker center recess of the screw/nail
    canvas.drawCircle(
      Offset(hookX, hookY),
      1.0,
      Paint()..color = const Color(0xFF2E1C0C),
    );

    // 3. Draw Board Shadow (ambient drop shadow on wall)
    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(boardLeft, boardTop, boardRight, boardBot),
      const Radius.circular(4.0),
    );
    canvas.drawRRect(
      boardRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );

    // 4. Draw Board Body (dark charcoal board)
    final boardBodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E2022), Color(0xFF121315)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTRB(boardLeft, boardTop, boardRight, boardBot));
    canvas.drawRRect(boardRect, boardBodyPaint);

    // 5. Draw Gold Border Outline
    final goldOutlinePaint = Paint()
      ..color = const Color(0xFFB38F3F).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(boardRect.deflate(3.0), goldOutlinePaint);

    // 6. Draw Gold Star Icon (solid gold star centered top)
    final double starCX = w / 2;
    final double starCY = boardTop + 22;
    final double outerR = 8.5;
    final double innerR = 4.0;

    final starPath = Path();
    for (int i = 0; i < 10; i++) {
      final double angle = i * math.pi / 5 - math.pi / 2;
      final double r = i.isEven ? outerR : innerR;
      final double x = starCX + math.cos(angle) * r;
      final double y = starCY + math.sin(angle) * r;
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    final starPaint = Paint()
      ..shader =
          const LinearGradient(
            colors: [Color(0xFFFFF59D), Color(0xFFD4A853), Color(0xFF8B6C25)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(
            Rect.fromCircle(center: Offset(starCX, starCY), radius: outerR),
          );
    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── 3D STICKY NOTE PAINTER (Reminder Note) ──────────────────────────────────
class StickyNotePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final double noteTop = 12.0;
    final double noteLeft = 4.0;
    final double noteRight = w - 4.0;
    final double noteBot = h - 4.0;

    // 1. Draw Drop Shadow (soft blur shadow cast to the bottom-right)
    final noteRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(noteLeft, noteTop, noteRight, noteBot),
      const Radius.circular(2.0),
    );
    canvas.drawRRect(
      noteRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
    );

    // 2. Draw Note Body (dark cardstock)
    final notePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E1E2E), Color(0xFF2D2D44)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTRB(noteLeft, noteTop, noteRight, noteBot));
    canvas.drawRRect(noteRect, notePaint);

    // 3. Draw Dark Push Pin at the top center
    final double pinCX = w / 2;
    final double pinCY = noteTop;

    // Pin shadow (cast bottom-right)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pinCX + 2.5, pinCY + 2.5),
        width: 5.5,
        height: 4.5,
      ),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // Pin head (3D glossy dark metallic sphere)
    final pinPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF6C63FF), Color(0xFF3F37C9), Color(0xFF1A1480)],
        center: Alignment(-0.35, -0.35),
      ).createShader(Rect.fromCircle(center: Offset(pinCX, pinCY), radius: 4.5))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pinCX, pinCY), 4.5, pinPaint);

    // Little shine highlight on the pin head
    canvas.drawCircle(
      Offset(pinCX - 1.2, pinCY - 1.2),
      1.0,
      Paint()..color = Colors.white.withValues(alpha: 0.65),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 12. 3D Premium Tablet / Customizer Panel sitting slanted in a wood stand
class CustomizerTablet3DPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Stand and Tablet Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.50)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    // Shadow under the stand feet
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h - 1),
        width: w * 0.85,
        height: 3.5,
      ),
      shadowPaint,
    );

    // 2. Wood Stand (Back brace and base plate)
    final standPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3E2723), Color(0xFF1B0000)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h - 8, w, 8));

    // Stand base plate
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h - 5, w * 0.70, 4.5),
        const Radius.circular(1),
      ),
      standPaint,
    );

    // Stand back support slanted bar
    final standBackPath = Path()
      ..moveTo(w * 0.44, h - 5)
      ..lineTo(w * 0.44, h * 0.2)
      ..lineTo(w * 0.56, h * 0.2)
      ..lineTo(w * 0.56, h - 5)
      ..close();
    canvas.drawPath(standBackPath, standPaint);

    // 3. Tablet Body (Walnut wood casing, tilted slightly, sitting inside the stand)
    final double tabX = w * 0.08;
    final double tabY = 1.0;
    final double tabW = w * 0.84;
    final double tabH = h - 6;

    final casingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(tabX, tabY, tabW, tabH));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tabX, tabY, tabW, tabH),
        const Radius.circular(3),
      ),
      casingPaint,
    );

    // Casing side shadow/highlight for 3D look
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tabX, tabY, tabW, tabH),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Screen (bevel dark slate screen)
    final screenPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(tabX + 2.5, tabY + 2.5, tabW - 5, tabH - 5));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tabX + 2.5, tabY + 2.5, tabW - 5, tabH - 5),
        const Radius.circular(1.5),
      ),
      screenPaint,
    );

    // Screen highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tabX + 2.5, tabY + 2.5, tabW - 5, tabH - 5),
        const Radius.circular(1.5),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // 4. Stylized color palette & brush layout on the screen
    final double cx = w / 2;
    final double cy = tabY + tabH / 2 - 1.5;

    // Palette wood board
    final boardPaint = Paint()
      ..color = const Color(0xFF8D6E63).withValues(alpha: 0.35);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 2, cy), width: 18, height: 11),
      boardPaint,
    );

    // Palette thumbhole
    canvas.drawCircle(
      Offset(cx - 6, cy),
      1.0,
      Paint()..color = const Color(0xFF0F172A),
    );

    // Paint colored paint dots (Red, Green, Blue, Gold)
    final colors = [
      const Color(0xFFE53935),
      const Color(0xFF43A047),
      const Color(0xFF1E88E5),
      const Color(0xFFFFB300),
    ];
    for (int i = 0; i < colors.length; i++) {
      final double angle = i * (math.pi / 2) + 0.35;
      final double dx = cx - 1.5 + math.cos(angle) * 6.2;
      final double dy = cy + math.sin(angle) * 4.0;
      canvas.drawCircle(
        Offset(dx, dy),
        1.3,
        Paint()..color = colors[i].withValues(alpha: 0.95),
      );
    }

    // A tiny paint brush lying diagonally
    final brushShaftPaint = Paint()
      ..color = const Color(0xFFE0C068)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - 8, cy + 5),
      Offset(cx + 6, cy - 4),
      brushShaftPaint,
    );
    // Tip of brush
    canvas.drawCircle(
      Offset(cx + 6, cy - 4),
      1.1,
      Paint()..color = const Color(0xFFE53935),
    );

    // 5. Stand front brackets (holding the tablet in place at the bottom)
    final bracketPaint = Paint()
      ..color = const Color(0xFF2E1912)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(w * 0.20, h - 6, 4, 3.5), bracketPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.76, h - 6, 4, 3.5), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 13. 3D Plant Showcase Shelf holding two plants in a row
class PlantShowcaseShelf extends StatefulWidget {
  final String woodTexture;
  final String plantType;

  const PlantShowcaseShelf({
    super.key,
    required this.woodTexture,
    required this.plantType,
  });

  @override
  State<PlantShowcaseShelf> createState() => _PlantShowcaseShelfState();
}

class _PlantShowcaseShelfState extends State<PlantShowcaseShelf>
    with SingleTickerProviderStateMixin {
  late AnimationController _swayController;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double shelfW = 140.0;
    final double shelfH = 75.0;

    return AnimatedBuilder(
      animation: _swayController,
      builder: (context, child) {
        final double sway1 =
            math.sin(_swayController.value * 2 * math.pi) * 0.020;
        final double sway2 =
            math.sin((_swayController.value + 0.35) * 2 * math.pi) * 0.016;

        return Container(
          width: shelfW,
          height: shelfH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 3D Custom Painted wood shelf & bracket loop loops
              Positioned.fill(
                child: CustomPaint(
                  painter: PlantShelf3DPainter(woodTexture: widget.woodTexture),
                ),
              ),

              // Two Plants side by side (scaled to look small)
              Positioned(
                top: 24 - 82,
                left: 6,
                right: 6,
                height: 82,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Transform.scale(
                      scale: 0.38,
                      alignment: Alignment.bottomCenter,
                      child: CustomPaint(
                        size: const Size(64, 82),
                        painter: PlantPainter(
                          plantType: widget.plantType,
                          growthStage: 3,
                          completionRatio: 0.9,
                          sway: sway1,
                          woodTexture: widget.woodTexture,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.38,
                      alignment: Alignment.bottomCenter,
                      child: CustomPaint(
                        size: const Size(64, 82),
                        painter: PlantPainter(
                          plantType: widget.plantType,
                          growthStage: 3,
                          completionRatio: 0.85,
                          sway: sway2,
                          woodTexture: widget.woodTexture,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── 3D PLANT SHELF PAINTER ──────────────────────────────────────────────────
class PlantShelf3DPainter extends CustomPainter {
  final String woodTexture;

  const PlantShelf3DPainter({required this.woodTexture});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    Color woodColor;
    if (woodTexture == 'Oak') {
      woodColor = const Color(0xFFC7B3A3);
    } else if (woodTexture == 'Mahogany') {
      woodColor = const Color(0xFF4A2C22);
    } else {
      woodColor = const Color(0xFF2E1912); // classic walnut
    }

    final shelfTopY = 18.0;
    final shelfBotY = 24.0;
    final sideThickness = 6.0;

    // 1. Draw elegant triangular brackets
    // We paint brackets as modern black iron triangle loops
    final bracketPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final bracketShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Left bracket triangle
    final double leftBracketX = w * 0.20;
    final leftBracketPath = Path()
      ..moveTo(leftBracketX, shelfBotY)
      ..lineTo(leftBracketX - 8, shelfBotY + 18)
      ..lineTo(leftBracketX + 8, shelfBotY + 18)
      ..close();

    // Right bracket triangle
    final double rightBracketX = w * 0.80;
    final rightBracketPath = Path()
      ..moveTo(rightBracketX, shelfBotY)
      ..lineTo(rightBracketX - 8, shelfBotY + 18)
      ..lineTo(rightBracketX + 8, shelfBotY + 18)
      ..close();

    // Draw bracket shadows
    canvas.drawPath(leftBracketPath, bracketShadowPaint);
    canvas.drawPath(rightBracketPath, bracketShadowPaint);

    // Draw bracket outlines
    canvas.drawPath(leftBracketPath, bracketPaint);
    canvas.drawPath(rightBracketPath, bracketPaint);

    // 2. 3D WOODEN PLANK
    // Top Slant Face (Perspective trapezoid)
    final topPath = Path()
      ..moveTo(4, shelfTopY)
      ..lineTo(w - 4, shelfTopY)
      ..lineTo(w, shelfBotY)
      ..lineTo(0, shelfBotY)
      ..close();

    final topPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          woodColor.withValues(alpha: 0.95),
          Color.lerp(woodColor, Colors.white, 0.08)!,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, shelfTopY, w, sideThickness));

    canvas.drawPath(topPath, topPaint);

    // Front edge thickness
    final frontPath = Path()
      ..moveTo(0, shelfBotY)
      ..lineTo(w, shelfBotY)
      ..lineTo(w - 1, shelfBotY + 4)
      ..lineTo(1, shelfBotY + 4)
      ..close();

    final frontPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.lerp(woodColor, Colors.black, 0.15)!,
          Color.lerp(woodColor, Colors.black, 0.35)!,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, shelfBotY, w, 4));

    canvas.drawPath(frontPath, frontPaint);

    // Highlight line between top face and front face
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, shelfBotY), Offset(w, shelfBotY), highlightPaint);

    // Wood Grain lines on top face
    final grainPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= 3; i++) {
      final y = shelfTopY + i * 1.5;
      canvas.drawLine(
        Offset(4 + i * 2, y),
        Offset(w - 4 - i * 2, y),
        grainPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PlantShelf3DPainter oldDelegate) {
    return oldDelegate.woodTexture != woodTexture;
  }
}

// ─── 3D CUSTOMIZER BUTTON WIDGET ─────────────────────────────────────────────
class ThreeDCustomizeButton extends StatefulWidget {
  const ThreeDCustomizeButton({super.key});

  @override
  State<ThreeDCustomizeButton> createState() => _ThreeDCustomizeButtonState();
}

class _ThreeDCustomizeButtonState extends State<ThreeDCustomizeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    // Play press-down and release animation
    _pressController.forward().then((_) {
      _pressController.reverse();
    });
    // Open workspace customization sheet
    WorkspaceCustomizationSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return CustomPaint(
            painter: ThreeDCustomizeButtonPainter(
              pressProgress: _pressController.value,
            ),
          );
        },
      ),
    );
  }
}

// ─── 3D CUSTOMIZER BUTTON PAINTER (Tactile Dial/Button) ──────────────────────
class ThreeDCustomizeButtonPainter extends CustomPainter {
  final double pressProgress;

  ThreeDCustomizeButtonPainter({required this.pressProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final cx = w / 2;
    // Base of the collar sits near the bottom
    final baseCenterY = h * 0.65;
    final radiusX = w * 0.4;
    final radiusY = radiusX * 0.55; // perspective flattening

    // 1. Desk footprint shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, baseCenterY + 4),
        width: radiusX * 2.2,
        height: radiusY * 2.2,
      ),
      shadowPaint,
    );

    // 2. COLLAR BASE (Static outer cylinder ring)
    // Bottom ellipse of the collar
    final collarThickness = 8.0;
    final collarBottomY = baseCenterY + collarThickness;
    final collarTopY = baseCenterY;

    final collarSidePath = Path()
      ..moveTo(cx - radiusX, collarTopY)
      ..lineTo(cx - radiusX, collarBottomY)
      ..arcToPoint(
        Offset(cx + radiusX, collarBottomY),
        radius: Radius.elliptical(radiusX, radiusY),
        clockwise: false,
      )
      ..lineTo(cx + radiusX, collarTopY)
      ..arcToPoint(
        Offset(cx - radiusX, collarTopY),
        radius: Radius.elliptical(radiusX, radiusY),
        clockwise: true,
      )
      ..close();

    final brassSideGradient =
        LinearGradient(
          colors: const [
            Color(0xFF5A451A), // deep brass shadow
            Color(0xFFB38F3F), // highlight gold
            Color(0xFFD4A853), // bright gold
            Color(0xFF8B6C25), // shadow gold
            Color(0xFF3E2F0B), // deep shadow
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(
          Rect.fromLTWH(cx - radiusX, collarTopY, radiusX * 2, collarThickness),
        );

    final collarPaint = Paint()..shader = brassSideGradient;
    canvas.drawPath(collarSidePath, collarPaint);

    // Top rim of the collar (thin brass ring)
    final collarTopPaint = Paint()
      ..shader =
          LinearGradient(
            colors: const [Color(0xFFFFF176), Color(0xFF8B6C25)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(
            Rect.fromCenter(
              center: Offset(cx, collarTopY),
              width: radiusX * 2,
              height: radiusY * 2,
            ),
          )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, collarTopY),
        width: radiusX * 2,
        height: radiusY * 2,
      ),
      collarTopPaint,
    );

    // 3. THE BUTTON/DIAL (Sinks down by pressProgress * 4.0)
    final pressOffset = pressProgress * 4.2;
    final btnRadiusX = radiusX - 2.5;
    final btnRadiusY = btnRadiusX * 0.55;
    final btnTopY =
        collarTopY -
        3.5 +
        pressOffset; // starts elevated by 3.5px, presses down to collar level
    final btnBottomY = btnTopY + 5.0; // button thickness is 5px

    // Side wall of the button cylinder (steel/dark alloy color to contrast brass base)
    final btnSidePath = Path()
      ..moveTo(cx - btnRadiusX, btnTopY)
      ..lineTo(cx - btnRadiusX, btnBottomY)
      ..arcToPoint(
        Offset(cx + btnRadiusX, btnBottomY),
        radius: Radius.elliptical(btnRadiusX, btnRadiusY),
        clockwise: false,
      )
      ..lineTo(cx + btnRadiusX, btnTopY)
      ..arcToPoint(
        Offset(cx - btnRadiusX, btnTopY),
        radius: Radius.elliptical(btnRadiusX, btnRadiusY),
        clockwise: true,
      )
      ..close();

    final btnSideGradient =
        LinearGradient(
          colors: const [
            Color(0xFF1E293B),
            Color(0xFF334155),
            Color(0xFF475569),
            Color(0xFF1E293B),
          ],
        ).createShader(
          Rect.fromLTWH(cx - btnRadiusX, btnTopY, btnRadiusX * 2, 5.0),
        );
    canvas.drawPath(btnSidePath, Paint()..shader = btnSideGradient);

    // Top surface of the button
    final btnTopRect = Rect.fromCenter(
      center: Offset(cx, btnTopY),
      width: btnRadiusX * 2,
      height: btnRadiusY * 2,
    );
    final btnFacePaint = Paint()
      ..shader = LinearGradient(
        colors: const [Color(0xFF1E293B), Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(btnTopRect);
    canvas.drawOval(btnTopRect, btnFacePaint);

    // Neon Accent Ring inside the button face (adds high tech premium feel)
    final neonRect = Rect.fromCenter(
      center: Offset(cx, btnTopY),
      width: (btnRadiusX - 3.0) * 2,
      height: (btnRadiusY - 1.8) * 2,
    );
    final neonPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1.2);
    canvas.drawOval(neonRect, neonPaint);

    // Ambient glow inside the recess
    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(neonRect, glowPaint);

    // 4. Customize Sliders Icon drawn inside the button top
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Draw stylized 3D settings/sliders lines
    // We adjust the height coordinates by * 0.55 for perspective!
    final double iconW = btnRadiusX * 0.45;
    final double iconH = btnRadiusY * 0.45;

    // Left Slider Line
    canvas.drawLine(
      Offset(cx - iconW * 0.5, btnTopY - iconH * 0.7),
      Offset(cx - iconW * 0.5, btnTopY + iconH * 0.7),
      iconPaint,
    );
    // Right Slider Line
    canvas.drawLine(
      Offset(cx + iconW * 0.5, btnTopY - iconH * 0.7),
      Offset(cx + iconW * 0.5, btnTopY + iconH * 0.7),
      iconPaint,
    );

    // Slider handles (small ellipses or dots)
    final dotPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - iconW * 0.5, btnTopY + iconH * 0.1),
        width: 3.5,
        height: 2.2,
      ),
      dotPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + iconW * 0.5, btnTopY - iconH * 0.3),
        width: 3.5,
        height: 2.2,
      ),
      dotPaint,
    );

    // Center circular gear accent or gear pin in the middle
    canvas.drawCircle(
      Offset(cx, btnTopY),
      1.5,
      Paint()..color = const Color(0xFF00E5FF),
    );

    // 5. Polished glass reflection (diagonal sheen)
    final glossPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.4],
      ).createShader(btnTopRect);
    canvas.drawOval(btnTopRect, glossPaint);
  }

  @override
  bool shouldRepaint(covariant ThreeDCustomizeButtonPainter oldDelegate) {
    return oldDelegate.pressProgress != pressProgress;
  }
}

// ─── MINIATURE PAINTING ON PEDESTAL (Opens customization on tap) ───────────────
class ThreeDCustomizeSwitch extends StatefulWidget {
  const ThreeDCustomizeSwitch({super.key});

  @override
  State<ThreeDCustomizeSwitch> createState() => _ThreeDCustomizeSwitchState();
}

class _ThreeDCustomizeSwitchState extends State<ThreeDCustomizeSwitch>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _burstController;
  late Animation<double> _burstAnim;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _burstAnim = CurvedAnimation(
      parent: _burstController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.heavyImpact();
    _burstController.forward().then((_) => _burstController.reverse());
    WorkspaceCustomizationSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatController, _burstAnim]),
        builder: (context, child) {
          return CustomPaint(
            size: const Size(40, 55),
            painter: FloatingCrystalPainter(
              floatPhase: _floatController.value,
              burstProgress: _burstAnim.value,
            ),
          );
        },
      ),
    );
  }
}

class FloatingCrystalPainter extends CustomPainter {
  final double floatPhase;
  final double burstProgress;

  FloatingCrystalPainter({
    required this.floatPhase,
    this.burstProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final float = floatPhase;
    final b = burstProgress;

    final floatY = math.sin(float * math.pi * 2) * 1.5;
    final cy = h * 0.4 + floatY;

    // ── 1. Pedestal ──
    final baseY = h * 0.4 + 18;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 11, baseY, 22, 5),
        const Radius.circular(3),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A2A3A).withValues(alpha: 0.6),
            const Color(0xFF0D0D1A).withValues(alpha: 0.8),
          ],
        ).createShader(Rect.fromLTWH(cx - 14, baseY, 28, 6)),
    );
    canvas.drawLine(
      Offset(cx - 11, baseY),
      Offset(cx + 11, baseY),
      Paint()..color = const Color(0xFF555577).withValues(alpha: 0.4),
    );

    // ── 2. Ground shadow ──
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, baseY + 4), width: 26, height: 6),
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, baseY + 8), radius: 16)),
    );

    // ── 3. Painting frame ──
    final frameW = 22.0 + b * 1.5;
    final frameH = 26.0 + b * 1.5;
    final frameX = cx - frameW / 2;
    final frameY = cy - frameH / 2;

    // Frame shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(frameX + 2, frameY + 2, frameW, frameH),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Outer frame (wood/gold)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(frameX, frameY, frameW, frameH),
        const Radius.circular(3),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFFC9A96E),
            Color(0xFF8B6914),
            Color(0xFF5C4400),
            Color(0xFF8B6914),
          ],
        ).createShader(Rect.fromLTWH(frameX, frameY, frameW, frameH)),
    );

    // Inner mat
    final matInset = 2.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(frameX + matInset, frameY + matInset, frameW - matInset * 2, frameH - matInset * 2),
        const Radius.circular(1.5),
      ),
      Paint()..color = const Color(0xFF1A1A2E),
    );

    // Canvas artwork — abstract mountain/sun
    final canX = frameX + matInset + 2;
    final canY = frameY + matInset + 2;
    final canW = frameW - (matInset + 2) * 2;
    final canH = frameH - (matInset + 2) * 2;

    // Sky gradient
    canvas.drawRect(
      Rect.fromLTWH(canX, canY, canW, canH),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF1A0533),
            Color(0xFF2D1B69),
            Color(0xFF4A2C8A),
          ],
        ).createShader(Rect.fromLTWH(canX, canY, canW, canH)),
    );

    // Moon/sun circle
    canvas.drawCircle(
      Offset(cx, canY + canH * 0.3),
      4.5,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0xFFFFE082),
            Color(0xFFFFB300),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, canY + canH * 0.3), radius: 6)),
    );

    // Mountains
    final mountainPath = Path()
      ..moveTo(canX, canY + canH)
      ..lineTo(canX + canW * 0.25, canY + canH * 0.45)
      ..lineTo(canX + canW * 0.5, canY + canH * 0.65)
      ..lineTo(canX + canW * 0.75, canY + canH * 0.3)
      ..lineTo(canX + canW, canY + canH * 0.55)
      ..lineTo(canX + canW, canY + canH)
      ..close();

    // Back mountain (darker)
    final backMountainPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFF2D1B69),
          Color(0xFF1A0533),
        ],
      ).createShader(Rect.fromLTWH(canX, canY + canH * 0.2, canW, canH * 0.8));
    canvas.drawPath(mountainPath, backMountainPaint);

    // Front mountain (lighter)
    final frontMountainPath = Path()
      ..moveTo(canX, canY + canH)
      ..lineTo(canX + canW * 0.15, canY + canH * 0.6)
      ..lineTo(canX + canW * 0.4, canY + canH * 0.78)
      ..lineTo(canX + canW * 0.65, canY + canH * 0.5)
      ..lineTo(canX + canW, canY + canH * 0.75)
      ..lineTo(canX + canW, canY + canH)
      ..close();
    canvas.drawPath(
      frontMountainPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF4A2C8A),
            Color(0xFF2D1B69),
          ],
        ).createShader(Rect.fromLTWH(canX, canY + canH * 0.4, canW, canH * 0.6)),
    );

    // Stars
    for (int i = 0; i < 4; i++) {
      final sa = float * math.pi * 2 + i * 1.57;
      final sx = canX + 4 + i * 4.5 + math.sin(sa) * 1.5;
      final sy = canY + 3 + (i % 2) * 4 + math.cos(sa * 1.3) * 1.5;
      canvas.drawCircle(
        Offset(sx, sy),
        0.7,
        Paint()..color = Colors.white.withValues(alpha: 0.5 + math.sin(sa * 2 + float * 3) * 0.3),
      );
    }

    // Frame top highlight
    canvas.drawLine(
      Offset(frameX + 1, frameY + 1),
      Offset(frameX + frameW - 1, frameY + 1),
      Paint()..color = const Color(0xFFE8C97A).withValues(alpha: 0.5),
    );
    canvas.drawLine(
      Offset(frameX + 1, frameY + 1),
      Offset(frameX + 1, frameY + frameH - 1),
      Paint()..color = const Color(0xFFE8C97A).withValues(alpha: 0.3),
    );

    // ── 4. Frame glow on tap ──
    if (b > 0.01) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(frameX - 2, frameY - 2, frameW + 4, frameH + 4),
          const Radius.circular(5),
        ),
        Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: b * 0.4)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0 + b * 10),
      );

      // Burst particles
      for (int i = 0; i < 4; i++) {
        final angle = i * 1.57 + b * 2.0;
        final dist = b * 28;
        canvas.drawCircle(
          Offset(cx + math.cos(angle) * dist, cy + math.sin(angle) * dist * 0.7),
          1.5 * (1.0 - b * 0.6),
          Paint()
            ..color = Color.lerp(
              const Color(0xFF00E5FF),
              const Color(0xFFC9A96E),
              b,
            )!.withValues(alpha: (1.0 - b) * 0.7),
        );
      }

      canvas.drawCircle(
        Offset(cx, cy),
        b * 20,
        Paint()
          ..color = const Color(0xFFC9A96E).withValues(alpha: (1.0 - b) * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 * (1.0 - b),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FloatingCrystalPainter oldDelegate) {
    return oldDelegate.floatPhase != floatPhase ||
        oldDelegate.burstProgress != burstProgress;
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HANGING PLANT VINES PAINTER (Sways dynamically)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HangingVinesPainter extends CustomPainter {
  final double animationValue;
  final bool isLeft;

  HangingVinesPainter({required this.animationValue, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Vine stem paint
    final stemPaint = Paint()
      ..color = const Color(0xFF1B4332)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Leaf paint (using beautiful variations of greens)
    final leafPaint1 = Paint()
      ..color = const Color(0xFF2D6A4F)
      ..style = PaintingStyle.fill;
    final leafPaint2 = Paint()
      ..color = const Color(0xFF40916C)
      ..style = PaintingStyle.fill;
    final leafHighlight = Paint()
      ..color = const Color(0xFF52B788)
      ..style = PaintingStyle.fill;

    // We will draw 2-3 main trailing vines of different lengths
    final random = math.Random(
      isLeft ? 42 : 84,
    ); // Seeded differently for left/right

    for (int vineIndex = 0; vineIndex < 3; vineIndex++) {
      final path = Path();
      // Start point at top edge of the painter container
      final startX = w * (0.3 + vineIndex * 0.2);
      final startY = 0.0;
      path.moveTo(startX, startY);

      // Sway offset using animationValue
      final swayPeriod = (1 + vineIndex).toDouble();
      final swayAmp = 3.0 + vineIndex * 1.5;
      final sway =
          math.sin(
            (animationValue * 2 * math.pi * swayPeriod) + (vineIndex * 2.0),
          ) *
          swayAmp;

      final vineLen = h * (0.5 + random.nextDouble() * 0.45);

      // Control points for a organic hanging curve
      final cp1x = startX + (isLeft ? -8 : 8) + sway * 0.5;
      final cp1y = vineLen * 0.33;
      final cp2x = startX + (isLeft ? 6 : -6) + sway;
      final cp2y = vineLen * 0.66;
      final endX = startX + (isLeft ? -4 : 4) + sway;
      final endY = vineLen;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, endX, endY);
      canvas.drawPath(path, stemPaint);

      // Draw leaves along the vine path
      final numLeaves = 8 + random.nextInt(6);
      for (int i = 0; i < numLeaves; i++) {
        final t = i / (numLeaves - 1);
        if (t == 0) continue;

        // Calculate position on Bezier curve using cubic formula
        final omt = 1 - t;
        final omt2 = omt * omt;
        final omt3 = omt2 * omt;
        final t2 = t * t;
        final t3 = t2 * t;

        final leafX =
            omt3 * startX +
            3 * omt2 * t * cp1x +
            3 * omt * t2 * cp2x +
            t3 * endX;
        final leafY =
            omt3 * startY +
            3 * omt2 * t * cp1y +
            3 * omt * t2 * cp2y +
            t3 * endY;

        // Leaf angle is perpendicular to the tangent
        final tx =
            3 * omt2 * (cp1x - startX) +
            6 * omt * t * (cp2x - cp1x) +
            3 * t2 * (endX - cp2x);
        final ty =
            3 * omt2 * (cp1y - startY) +
            6 * omt * t * (cp2y - cp1y) +
            3 * t2 * (endY - cp2y);
        final angle = math.atan2(ty, tx);

        // Alternating leaf direction
        final leafDirection = (i % 2 == 0) ? 1.0 : -1.0;
        final leafAngle =
            angle +
            (math.pi / 2) * leafDirection +
            (math.sin(animationValue * 2 * math.pi + i) * 0.1);

        // Draw leaf shape
        canvas.save();
        canvas.translate(leafX, leafY);
        canvas.rotate(leafAngle);

        // Draw a beautiful teardrop leaf
        final leafSize = 4.0 + random.nextDouble() * 3.5;
        final leafPath = Path();
        leafPath.moveTo(0, 0);
        leafPath.quadraticBezierTo(
          leafSize * 0.6,
          -leafSize * 0.4,
          leafSize,
          0,
        );
        leafPath.quadraticBezierTo(leafSize * 0.6, leafSize * 0.4, 0, 0);
        leafPath.close();

        canvas.drawPath(
          leafPath,
          (i % 3 == 0)
              ? leafPaint1
              : (i % 3 == 1)
              ? leafPaint2
              : leafHighlight,
        );

        // Draw leaf center vein line
        final veinPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
        canvas.drawLine(
          const Offset(0, 0),
          Offset(leafSize * 0.8, 0),
          veinPaint,
        );

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant HangingVinesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class CityViewWindowPainter extends CustomPainter {
  final String resolvedMode;
  final double animationValue;
  final bool isTopWindow;

  CityViewWindowPainter({
    required this.resolvedMode,
    required this.animationValue,
    this.isTopWindow = false,
  });

  void _drawCloud(Canvas canvas, Offset center, double size, Color color) {
    final Paint cloudPaint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(center, size, cloudPaint);
    canvas.drawCircle(
      center + Offset(-size * 0.6, size * 0.1),
      size * 0.75,
      cloudPaint,
    );
    canvas.drawCircle(
      center + Offset(size * 0.6, size * 0.15),
      size * 0.7,
      cloudPaint,
    );
    canvas.drawCircle(
      center + Offset(-size * 1.1, size * 0.25),
      size * 0.5,
      cloudPaint,
    );
    canvas.drawCircle(
      center + Offset(size * 1.1, size * 0.3),
      size * 0.55,
      cloudPaint,
    );

    // Flat cloud base
    final Rect bottomRect = Rect.fromLTRB(
      center.dx - size * 1.4,
      center.dy + size * 0.1,
      center.dx + size * 1.4,
      center.dy + size * 0.5,
    );
    canvas.drawRect(bottomRect, cloudPaint);
  }

  void _drawLeaf(
    Canvas canvas,
    Offset position,
    double angle,
    double scale,
    Color color,
  ) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    canvas.scale(scale);

    final Paint leafPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw leaf shape using bezier curves
    final Path leafPath = Path();
    leafPath.moveTo(0, 0);
    leafPath.quadraticBezierTo(-2.8, -5, 0, -10); // left side curve
    leafPath.quadraticBezierTo(2.8, -5, 0, 0); // right side curve
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);

    // Draw central vein
    final Paint veinPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.16)
      ..strokeWidth = 0.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, 0), const Offset(0, -9.0), veinPaint);

    canvas.restore();
  }

  void _drawWindowGrid(
    Canvas canvas,
    double xStart,
    double xEnd,
    double yStart,
    double yEnd,
    int columns,
    int rows,
    Paint paint,
    double animVal,
    int seed,
  ) {
    final double width = xEnd - xStart;
    final double height = yEnd - yStart;

    final double cellW = width / (columns * 2 - 1);
    final double cellH = height / (rows * 2 - 1);

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        // Deterministic flicker per window
        final double windowIndex = (r * columns + c + seed).toDouble();
        final double flicker =
            math.sin(animVal * 2.5 * math.pi + windowIndex * 1.5) * 0.5 + 0.5;

        // Skip some windows randomly to look realistic (occupancy rates)
        final double occupancyRandom = math.sin(windowIndex * 4.3) * 0.5 + 0.5;
        if (occupancyRandom < 0.28) continue; // 28% dark windows

        final double wx = xStart + c * (cellW * 2);
        final double wy = yStart + r * (cellH * 2);

        // Flicker intensity
        final double currentAlpha = paint.color.a * (0.5 + 0.5 * flicker);

        canvas.drawRect(
          Rect.fromLTRB(wx, wy, wx + cellW, wy + cellH),
          Paint()..color = paint.color.withValues(alpha: currentAlpha),
        );
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Resolve colors based on resolvedMode
    late final List<Color> skyGradient;

    // City building colors
    late final Color farCityColor;
    late final Color midCityColor;
    late final Color nearCityColor;
    late final Color windowLightColor;

    late final Color sunMoonColor;
    late final Color sunMoonGlow;
    late final Offset sunMoonCenter;
    late final double sunMoonRadius;
    bool isNight = false;

    switch (resolvedMode) {
      case 'Morning':
        skyGradient = [
          const Color(0xFFF57C00),
          const Color(0xFFFFB74D),
          const Color(0xFF90CAF9),
        ];
        farCityColor = const Color(0xFF90A4AE).withValues(alpha: 0.45);
        midCityColor = const Color(0xFF607D8B).withValues(alpha: 0.65);
        nearCityColor = const Color(0xFF37474F);
        windowLightColor = const Color(0xFFFFECB3).withValues(alpha: 0.35);
        sunMoonColor = const Color(0xFFFFE082);
        sunMoonGlow = Colors.amberAccent;
        sunMoonCenter = Offset(w * 0.35, h * 0.45);
        sunMoonRadius = 9.0;
        break;
      case 'Afternoon':
        skyGradient = [
          const Color(0xFF29B6F6),
          const Color(0xFF80DEEA),
          const Color(0xFF0288D1),
        ];
        farCityColor = const Color(0xFFB0BEC5).withValues(alpha: 0.4);
        midCityColor = const Color(0xFF78909C).withValues(alpha: 0.6);
        nearCityColor = const Color(0xFF455A64);
        windowLightColor = Colors.transparent;
        sunMoonColor = Colors.white;
        sunMoonGlow = Colors.white70;
        sunMoonCenter = Offset(w * 0.7, h * 0.25);
        sunMoonRadius = 7.5;
        break;
      case 'Evening':
        skyGradient = [
          const Color(0xFFBA68C8),
          const Color(0xFFF06292),
          const Color(0xFF283593),
        ];
        farCityColor = const Color(0xFF311B92).withValues(alpha: 0.35);
        midCityColor = const Color(0xFF4A148C).withValues(alpha: 0.55);
        nearCityColor = const Color(0xFF1A0933);
        windowLightColor = const Color(0xFFFFB74D);
        sunMoonColor = const Color(0xFFFF8A65);
        sunMoonGlow = Colors.deepOrangeAccent;
        sunMoonCenter = Offset(w * 0.5, h * 0.48);
        sunMoonRadius = 11.0;
        break;
      case 'Night':
      default:
        isNight = true;
        skyGradient = [const Color(0xFF03070E), const Color(0xFF080E1A)];
        farCityColor = const Color(0xFF0C1322);
        midCityColor = const Color(0xFF0F172A);
        nearCityColor = const Color(0xFF050B14);
        windowLightColor = const Color(0xFFFFD54F);
        sunMoonColor = const Color(0xFFECEFF1);
        sunMoonGlow = Colors.white24;
        sunMoonCenter = Offset(w * 0.3, h * 0.28);
        sunMoonRadius = 6.5;
        break;
    }

    // 2. Draw Sky
    final Rect skyRect = Rect.fromLTRB(0, 0, w, h);
    final Paint skyPaint = Paint()
      ..shader = LinearGradient(
        colors: skyGradient,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    // 3. Draw Stars at Night
    if (isNight) {
      final Paint starPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6);
      canvas.drawCircle(Offset(w * 0.15, h * 0.15), 0.8, starPaint);
      canvas.drawCircle(Offset(w * 0.45, h * 0.08), 0.6, starPaint);
      canvas.drawCircle(Offset(w * 0.65, h * 0.20), 0.7, starPaint);
      canvas.drawCircle(Offset(w * 0.85, h * 0.12), 0.8, starPaint);
      canvas.drawCircle(Offset(w * 0.52, h * 0.18), 0.5, starPaint);
    }

    // 4. Draw Soft Drifting Clouds
    final Color cloudColor = isNight
        ? Colors.white.withValues(alpha: 0.04)
        : (resolvedMode == 'Evening'
              ? const Color(0xFFFFB0B0).withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.15));

    final double cloudX1 =
        ((w * 0.25) + (animationValue * w * 0.3)) % (w + 40) - 20;
    _drawCloud(canvas, Offset(cloudX1, h * 0.2), 6.0, cloudColor);

    final double cloudX2 =
        ((w * 0.7) + (animationValue * w * 0.25)) % (w + 50) - 25;
    _drawCloud(canvas, Offset(cloudX2, h * 0.12), 8.0, cloudColor);

    // 5. Draw Sun/Moon
    final Paint glowPaint = Paint()
      ..color = sunMoonGlow.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(sunMoonCenter, sunMoonRadius + 4, glowPaint);

    final Paint mainPaint = Paint()..color = sunMoonColor;
    if (isNight) {
      final Path crescentPath = Path()
        ..addOval(
          Rect.fromCircle(center: sunMoonCenter, radius: sunMoonRadius),
        );
      final Path shadowPath = Path()
        ..addOval(
          Rect.fromCircle(
            center:
                sunMoonCenter -
                Offset(sunMoonRadius * 0.42, -sunMoonRadius * 0.1),
            radius: sunMoonRadius * 0.95,
          ),
        );
      final Path finalMoon = Path.combine(
        PathOperation.difference,
        crescentPath,
        shadowPath,
      );
      canvas.drawPath(finalMoon, mainPaint);
    } else {
      canvas.drawCircle(sunMoonCenter, sunMoonRadius, mainPaint);
    }

    // 6. Draw City Skyline (3 Layers of Silhouettes)
    final Paint buildingPaint = Paint()..style = PaintingStyle.fill;
    final Paint lightPaint = Paint()..style = PaintingStyle.fill;

    // Shift buildings downwards for elevated top-window perspective
    final double heightScale = isTopWindow ? 0.70 : 1.0;

    // --- LAYER 1: FAR CITY (Background) ---
    buildingPaint.color = farCityColor;
    final Path farPath = Path();
    farPath.moveTo(0, h);
    farPath.lineTo(0, h - 0.40 * h * heightScale);
    farPath.lineTo(0.12 * w, h - 0.40 * h * heightScale);

    farPath.lineTo(0.12 * w, h - 0.55 * h * heightScale);
    farPath.lineTo(0.25 * w, h - 0.55 * h * heightScale);

    farPath.lineTo(0.25 * w, h - 0.46 * h * heightScale);
    farPath.lineTo(0.38 * w, h - 0.52 * h * heightScale); // angled roof
    farPath.lineTo(0.38 * w, h - 0.46 * h * heightScale);

    // Tower slab
    farPath.lineTo(0.40 * w, h - 0.46 * h * heightScale);
    farPath.lineTo(0.40 * w, h - 0.68 * h * heightScale);
    farPath.lineTo(0.52 * w, h - 0.68 * h * heightScale);
    farPath.lineTo(0.52 * w, h - 0.48 * h * heightScale);

    farPath.lineTo(0.55 * w, h - 0.48 * h * heightScale);
    farPath.lineTo(0.55 * w, h - 0.58 * h * heightScale);
    farPath.lineTo(0.68 * w, h - 0.58 * h * heightScale);

    // Dome top
    farPath.lineTo(0.68 * w, h - 0.45 * h * heightScale);
    farPath.lineTo(0.70 * w, h - 0.45 * h * heightScale);
    farPath.quadraticBezierTo(
      0.76 * w,
      h - (0.45 + 0.09 * heightScale) * h,
      0.82 * w,
      h - 0.45 * h * heightScale,
    );
    farPath.lineTo(0.85 * w, h - 0.45 * h * heightScale);

    farPath.lineTo(0.85 * w, h - 0.40 * h * heightScale);
    farPath.lineTo(w, h - 0.40 * h * heightScale);
    farPath.lineTo(w, h);
    farPath.close();
    canvas.drawPath(farPath, buildingPaint);

    // Blinking warning beacon on the radio mast
    if (isNight || resolvedMode == 'Evening') {
      final double beaconX = 0.46 * w;
      final double beaconY = h - 0.68 * h * heightScale;

      canvas.drawLine(
        Offset(beaconX, beaconY),
        Offset(beaconX, beaconY - 6.0),
        Paint()
          ..color = farCityColor
          ..strokeWidth = 0.9,
      );

      final double blink = math.sin(animationValue * 4.5 * math.pi) * 0.5 + 0.5;
      final Paint beaconPaint = Paint()
        ..color = const Color(0xFFFF1744).withValues(alpha: 0.3 + 0.7 * blink)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(beaconX, beaconY - 6.0), 1.0, beaconPaint);

      canvas.drawCircle(
        Offset(beaconX, beaconY - 6.0),
        3.0,
        Paint()
          ..color = const Color(0xFFFF1744).withValues(alpha: 0.15 * blink)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }

    // --- LAYER 2: MID CITY ---
    buildingPaint.color = midCityColor;
    final Path midPath = Path();
    midPath.moveTo(0, h);
    midPath.lineTo(0, h - 0.32 * h * heightScale);
    midPath.lineTo(0.16 * w, h - 0.32 * h * heightScale);

    // Spire tower
    midPath.lineTo(0.16 * w, h - 0.44 * h * heightScale);
    midPath.lineTo(0.21 * w, h - 0.48 * h * heightScale); // spire tip
    midPath.lineTo(0.26 * w, h - 0.44 * h * heightScale);
    midPath.lineTo(0.26 * w, h - 0.32 * h * heightScale);

    midPath.lineTo(0.28 * w, h - 0.32 * h * heightScale);
    midPath.lineTo(0.28 * w, h - 0.38 * h * heightScale);
    midPath.lineTo(0.45 * w, h - 0.38 * h * heightScale);

    midPath.lineTo(0.45 * w, h - 0.44 * h * heightScale);
    midPath.lineTo(0.60 * w, h - 0.44 * h * heightScale);

    midPath.lineTo(0.60 * w, h - 0.41 * h * heightScale);
    midPath.lineTo(0.74 * w, h - 0.41 * h * heightScale);

    // Stepped building
    midPath.lineTo(0.74 * w, h - 0.35 * h * heightScale);
    midPath.lineTo(0.77 * w, h - 0.40 * h * heightScale);
    midPath.lineTo(0.80 * w, h - 0.45 * h * heightScale);
    midPath.lineTo(0.84 * w, h - 0.45 * h * heightScale);
    midPath.lineTo(0.87 * w, h - 0.40 * h * heightScale);
    midPath.lineTo(0.90 * w, h - 0.35 * h * heightScale);

    midPath.lineTo(w, h - 0.35 * h * heightScale);
    midPath.lineTo(w, h);
    midPath.close();
    canvas.drawPath(midPath, buildingPaint);

    // Scattered windows on Mid layer
    if (isNight || resolvedMode == 'Evening') {
      lightPaint.color = windowLightColor.withValues(alpha: 0.55);

      // Building A windows
      _drawWindowGrid(
        canvas,
        0.04 * w,
        0.12 * w,
        h - 0.28 * h * heightScale,
        h - 0.12 * h,
        2,
        3,
        lightPaint,
        animationValue,
        1,
      );
      // Spire tower windows
      _drawWindowGrid(
        canvas,
        0.18 * w,
        0.24 * w,
        h - 0.40 * h * heightScale,
        h - 0.30 * h,
        1,
        2,
        lightPaint,
        animationValue,
        2,
      );
      // Building D windows
      _drawWindowGrid(
        canvas,
        0.48 * w,
        0.57 * w,
        h - 0.40 * h * heightScale,
        h - 0.20 * h,
        2,
        4,
        lightPaint,
        animationValue,
        3,
      );
      // Stepped building windows
      _drawWindowGrid(
        canvas,
        0.79 * w,
        0.85 * w,
        h - 0.38 * h * heightScale,
        h - 0.20 * h,
        1,
        3,
        lightPaint,
        animationValue,
        4,
      );
    }

    // --- LAYER 3: NEAR CITY (Foreground Silhouettes) ---
    buildingPaint.color = nearCityColor;
    final Path nearPath = Path();
    nearPath.moveTo(0, h);
    nearPath.lineTo(0, h - 0.25 * h * heightScale);
    nearPath.lineTo(0.22 * w, h - 0.25 * h * heightScale);

    // Center building with double slope
    nearPath.lineTo(0.22 * w, h - 0.32 * h * heightScale);
    nearPath.lineTo(0.35 * w, h - 0.36 * h * heightScale); // peak
    nearPath.lineTo(0.48 * w, h - 0.32 * h * heightScale);
    nearPath.lineTo(0.58 * w, h - 0.32 * h * heightScale);
    nearPath.lineTo(0.58 * w, h - 0.22 * h * heightScale);

    nearPath.lineTo(0.80 * w, h - 0.22 * h * heightScale);
    nearPath.lineTo(0.80 * w, h - 0.30 * h * heightScale);
    nearPath.lineTo(w, h - 0.30 * h * heightScale);
    nearPath.lineTo(w, h);
    nearPath.close();
    canvas.drawPath(nearPath, buildingPaint);

    // Bright window lights on Near layer
    if (isNight || resolvedMode == 'Evening') {
      lightPaint.color = windowLightColor;

      // Building X windows
      _drawWindowGrid(
        canvas,
        0.03 * w,
        0.16 * w,
        h - 0.22 * h * heightScale,
        h - 0.08 * h,
        3,
        3,
        lightPaint,
        animationValue,
        5,
      );
      // Center building Y windows (below peak)
      _drawWindowGrid(
        canvas,
        0.26 * w,
        0.44 * w,
        h - 0.28 * h * heightScale,
        h - 0.06 * h,
        4,
        4,
        lightPaint,
        animationValue,
        6,
      );
      // Building W windows (right)
      _drawWindowGrid(
        canvas,
        0.84 * w,
        0.96 * w,
        h - 0.26 * h * heightScale,
        h - 0.08 * h,
        2,
        4,
        lightPaint,
        animationValue,
        7,
      );
    }

    // Cozy Streetlamp Silhouette - only visible in bottom window
    if (!isTopWindow) {
      final double lampX = 0.72 * w;
      final double lampY = h - 0.23 * h;
      final Paint lampPaint = Paint()
        ..color = nearCityColor
        ..strokeCap = StrokeCap.round;

      // Post
      canvas.drawLine(
        Offset(lampX, h),
        Offset(lampX, lampY),
        lampPaint..strokeWidth = 1.2,
      );
      // Bracket
      final Path bracket = Path()
        ..moveTo(lampX, lampY)
        ..quadraticBezierTo(lampX - 2.5, lampY - 5, lampX - 5, lampY - 3.5);
      canvas.drawPath(
        bracket,
        lampPaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );

      // Lantern head
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(lampX - 5, lampY - 2.5),
          width: 2.6,
          height: 3.5,
        ),
        lampPaint..style = PaintingStyle.fill,
      );

      // Light glow at night/evening
      if (isNight || resolvedMode == 'Evening') {
        final Paint bulbPaint = Paint()
          ..color = const Color(0xFFFFD54F)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(lampX - 5, lampY - 1.5), 1.0, bulbPaint);

        final double lampBlink =
            math.sin(animationValue * 2 * math.pi) * 0.04 + 0.96;
        canvas.drawCircle(
          Offset(lampX - 5, lampY - 1.5),
          8.0,
          Paint()
            ..color = const Color(
              0xFFFFD54F,
            ).withValues(alpha: 0.18 * lampBlink)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }

    // 7. Draw Swaying Tree Silhouettes
    final Paint treePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          isNight ? const Color(0xFF000000) : const Color(0xFF040A08),
          isNight ? const Color(0xFF030303) : const Color(0xFF0C1713),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, w, h));

    final double swayLeft = math.sin(animationValue * 2 * math.pi) * 2.8;
    final double swayRight = math.sin(animationValue * 2 * math.pi + 1.6) * 2.0;

    final Paint twigPaint = Paint()
      ..color = isNight ? const Color(0xFF010202) : const Color(0xFF0B1713)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Color leafBaseColor = isNight
        ? const Color(0xFF020605)
        : const Color(0xFF143024);
    final Color leafHighlightColor = isNight
        ? const Color(0xFF040A08)
        : const Color(0xFF26533F);

    void drawLeafPair(Offset pos, double angleBase) {
      _drawLeaf(canvas, pos, angleBase - 0.45, 0.85, leafBaseColor);
      _drawLeaf(canvas, pos, angleBase + 0.45, 0.80, leafHighlightColor);
    }

    if (!isTopWindow) {
      // A. Left Street Tree Trunk (bottom window ground perspective)
      final Path trunkLeft = Path();
      final double botLeft = -4.0;
      final double botRight = 4.0;
      final double topLeft = w * 0.08 + swayLeft - 1.4;
      final double topRight = w * 0.08 + swayLeft + 1.4;

      trunkLeft.moveTo(botLeft, h);
      trunkLeft.quadraticBezierTo(
        w * 0.09 + swayLeft * 0.4 - 2.8,
        h * 0.65,
        topLeft,
        h * 0.35,
      );
      trunkLeft.lineTo(topRight, h * 0.35);
      trunkLeft.quadraticBezierTo(
        w * 0.09 + swayLeft * 0.4 + 2.8,
        h * 0.65,
        botRight,
        h,
      );
      trunkLeft.close();
      canvas.drawPath(trunkLeft, treePaint);

      // Left tree branches and leaves framing the top-left corner
      final Offset leftCrown = Offset(w * 0.09 + swayLeft, h * 0.35);

      final Offset lbEnd = leftCrown + Offset(-15 + swayLeft * 0.38, -13);
      canvas.drawLine(leftCrown, lbEnd, twigPaint..strokeWidth = 1.5);

      final Offset rbEnd = leftCrown + Offset(15 + swayLeft * 0.28, -7);
      canvas.drawLine(leftCrown, rbEnd, twigPaint..strokeWidth = 1.3);

      final Offset mbEnd = leftCrown + Offset(1.5 + swayLeft * 0.48, -19);
      canvas.drawLine(leftCrown, mbEnd, twigPaint..strokeWidth = 1.1);

      // Left Tree leaves
      _drawLeaf(canvas, lbEnd, -2.4, 0.85, leafBaseColor);
      _drawLeaf(
        canvas,
        lbEnd + const Offset(-3, -2),
        -2.8,
        0.75,
        leafHighlightColor,
      );
      _drawLeaf(
        canvas,
        lbEnd + const Offset(-2, 3),
        -1.85,
        0.80,
        leafBaseColor,
      );

      _drawLeaf(canvas, rbEnd, -0.6, 0.85, leafBaseColor);
      _drawLeaf(
        canvas,
        rbEnd + const Offset(3, -2),
        -0.2,
        0.75,
        leafHighlightColor,
      );
      _drawLeaf(canvas, rbEnd + const Offset(2, 3), -1.0, 0.80, leafBaseColor);

      _drawLeaf(canvas, mbEnd, -1.6, 0.80, leafBaseColor);
      _drawLeaf(
        canvas,
        mbEnd + const Offset(-2, -3),
        -2.0,
        0.70,
        leafHighlightColor,
      );
      _drawLeaf(canvas, mbEnd + const Offset(2, 2), -1.2, 0.75, leafBaseColor);

      drawLeafPair(leftCrown + (lbEnd - leftCrown) * 0.5, -2.0);
      drawLeafPair(leftCrown + (rbEnd - leftCrown) * 0.5, -0.8);
    } else {
      // Left leafy branch hanging in from top-left (balanced elevated framing, no trunk)
      canvas.save();
      canvas.translate(-12, -4);

      final Path leftBranch = Path();
      leftBranch.moveTo(0, -2);
      leftBranch.quadraticBezierTo(
        w * 0.2 + swayLeft * 0.3,
        h * 0.08,
        w * 0.42 + swayLeft,
        h * 0.28,
      );
      leftBranch.lineTo(w * 0.42 + swayLeft, h * 0.28 + 1.6);
      leftBranch.quadraticBezierTo(
        w * 0.2 + swayLeft * 0.3,
        h * 0.08 + 3.5,
        0,
        6,
      );
      leftBranch.close();
      canvas.drawPath(
        leftBranch,
        Paint()
          ..color = isNight ? const Color(0xFF010202) : const Color(0xFF0B1713),
      );

      Offset getLeftBranchPoint(double t) {
        final double omt = 1 - t;
        final double x =
            omt * omt * 0 +
            2 * omt * t * (w * 0.2 + swayLeft * 0.3) +
            t * t * (w * 0.42 + swayLeft);
        final double y =
            omt * omt * (-2) + 2 * omt * t * (h * 0.08) + t * t * (h * 0.28);
        return Offset(x, y);
      }

      final Offset lt1Start = getLeftBranchPoint(0.36);
      final Offset lt1End = lt1Start + Offset(14 + swayLeft * 0.24, -11);
      canvas.drawLine(lt1Start, lt1End, twigPaint..strokeWidth = 1.5);

      final Offset lt2Start = getLeftBranchPoint(0.66);
      final Offset lt2End = lt2Start + Offset(17 + swayLeft * 0.18, 7);
      canvas.drawLine(lt2Start, lt2End, twigPaint..strokeWidth = 1.3);

      final Offset lt3Start = getLeftBranchPoint(0.84);
      final Offset lt3End = lt3Start + Offset(13 + swayLeft * 0.12, -6);
      canvas.drawLine(lt3Start, lt3End, twigPaint..strokeWidth = 1.1);

      final Offset leftEnd = getLeftBranchPoint(1.0);
      _drawLeaf(canvas, leftEnd, 1.8, 0.95, leafBaseColor);
      _drawLeaf(
        canvas,
        leftEnd + const Offset(2, -3),
        2.2,
        0.85,
        leafHighlightColor,
      );
      _drawLeaf(canvas, leftEnd + const Offset(4, 2), 1.3, 0.90, leafBaseColor);
      _drawLeaf(
        canvas,
        leftEnd + const Offset(7, -1),
        1.6,
        0.75,
        leafHighlightColor,
      );
      _drawLeaf(
        canvas,
        leftEnd + const Offset(1, 4),
        0.85,
        0.80,
        leafBaseColor,
      );

      _drawLeaf(canvas, lt1End, 2.4, 0.85, leafBaseColor);
      _drawLeaf(
        canvas,
        lt1End + const Offset(3, -2),
        2.8,
        0.75,
        leafHighlightColor,
      );
      _drawLeaf(canvas, lt1End + const Offset(2, 3), 1.85, 0.80, leafBaseColor);

      _drawLeaf(canvas, lt2End, 1.2, 0.80, leafBaseColor);
      _drawLeaf(
        canvas,
        lt2End + const Offset(3, 1),
        0.8,
        0.70,
        leafHighlightColor,
      );
      _drawLeaf(canvas, lt2End + const Offset(2, -3), 1.6, 0.75, leafBaseColor);

      _drawLeaf(canvas, lt3End, 2.0, 0.75, leafBaseColor);
      _drawLeaf(
        canvas,
        lt3End + const Offset(3, -2),
        2.4,
        0.65,
        leafHighlightColor,
      );
      _drawLeaf(canvas, lt3End + const Offset(2, 2), 1.5, 0.70, leafBaseColor);

      void drawLeftLeafPair(Offset pos, double angleBase) {
        _drawLeaf(canvas, pos, angleBase - 0.45, 0.85, leafBaseColor);
        _drawLeaf(canvas, pos, angleBase + 0.45, 0.80, leafHighlightColor);
      }

      drawLeftLeafPair(getLeftBranchPoint(0.24), 1.9);
      drawLeftLeafPair(getLeftBranchPoint(0.50), 1.65);
      drawLeftLeafPair(getLeftBranchPoint(0.78), 1.35);

      drawLeftLeafPair(lt1Start + (lt1End - lt1Start) * 0.5, 2.1);
      drawLeftLeafPair(lt2Start + (lt2End - lt2Start) * 0.5, 1.25);

      canvas.restore();
    }

    // B. Right Side Detailed Leafy Branch
    canvas.save();
    canvas.translate(w + 12, -4);

    final Path mainBranch = Path();
    mainBranch.moveTo(0, -2);
    mainBranch.quadraticBezierTo(
      -w * 0.2 + swayRight * 0.3,
      h * 0.08,
      -w * 0.42 + swayRight,
      h * 0.28,
    );
    mainBranch.lineTo(-w * 0.42 + swayRight, h * 0.28 + 1.6);
    mainBranch.quadraticBezierTo(
      -w * 0.2 + swayRight * 0.3,
      h * 0.08 + 3.5,
      0,
      6,
    );
    mainBranch.close();
    canvas.drawPath(
      mainBranch,
      Paint()
        ..color = isNight ? const Color(0xFF010202) : const Color(0xFF0B1713),
    );

    Offset getBranchPoint(double t) {
      final double omt = 1 - t;
      final double x =
          omt * omt * 0 +
          2 * omt * t * (-w * 0.2 + swayRight * 0.3) +
          t * t * (-w * 0.42 + swayRight);
      final double y =
          omt * omt * (-2) + 2 * omt * t * (h * 0.08) + t * t * (h * 0.28);
      return Offset(x, y);
    }

    // Twigs and leaves on Right branch
    final Offset t1Start = getBranchPoint(0.36);
    final Offset t1End = t1Start + Offset(-14 + swayRight * 0.24, -11);
    canvas.drawLine(t1Start, t1End, twigPaint..strokeWidth = 1.5);

    final Offset t2Start = getBranchPoint(0.66);
    final Offset t2End = t2Start + Offset(-17 + swayRight * 0.18, 7);
    canvas.drawLine(t2Start, t2End, twigPaint..strokeWidth = 1.3);

    final Offset t3Start = getBranchPoint(0.84);
    final Offset t3End = t3Start + Offset(-13 + swayRight * 0.12, -6);
    canvas.drawLine(t3Start, t3End, twigPaint..strokeWidth = 1.1);

    // Right end leaf cluster
    final Offset mainEnd = getBranchPoint(1.0);
    _drawLeaf(canvas, mainEnd, -1.8, 0.95, leafBaseColor);
    _drawLeaf(
      canvas,
      mainEnd + const Offset(-2, -3),
      -2.2,
      0.85,
      leafHighlightColor,
    );
    _drawLeaf(canvas, mainEnd + const Offset(-4, 2), -1.3, 0.90, leafBaseColor);
    _drawLeaf(
      canvas,
      mainEnd + const Offset(-7, -1),
      -1.6,
      0.75,
      leafHighlightColor,
    );
    _drawLeaf(
      canvas,
      mainEnd + const Offset(-1, 4),
      -0.85,
      0.80,
      leafBaseColor,
    );

    // Twig 1 end cluster
    _drawLeaf(canvas, t1End, -2.4, 0.85, leafBaseColor);
    _drawLeaf(
      canvas,
      t1End + const Offset(-3, -2),
      -2.8,
      0.75,
      leafHighlightColor,
    );
    _drawLeaf(canvas, t1End + const Offset(-2, 3), -1.85, 0.80, leafBaseColor);

    // Twig 2 end cluster
    _drawLeaf(canvas, t2End, -1.2, 0.80, leafBaseColor);
    _drawLeaf(
      canvas,
      t2End + const Offset(-3, 1),
      -0.8,
      0.70,
      leafHighlightColor,
    );
    _drawLeaf(canvas, t2End + const Offset(-2, -3), -1.6, 0.75, leafBaseColor);

    // Twig 3 end cluster
    _drawLeaf(canvas, t3End, -2.0, 0.75, leafBaseColor);
    _drawLeaf(
      canvas,
      t3End + const Offset(-3, -2),
      -2.4,
      0.65,
      leafHighlightColor,
    );
    _drawLeaf(canvas, t3End + const Offset(-2, 2), -1.5, 0.70, leafBaseColor);

    drawLeafPair(getBranchPoint(0.24), -1.9);
    drawLeafPair(getBranchPoint(0.50), -1.65);
    drawLeafPair(getBranchPoint(0.78), -1.35);

    drawLeafPair(t1Start + (t1End - t1Start) * 0.5, -2.1);
    drawLeafPair(t2Start + (t2End - t2Start) * 0.5, -1.25);

    canvas.restore();

    // 8. Draw Grid lines of the window
    final Paint gridShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 2.4;
    final Paint gridPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 1.6;

    canvas.drawLine(
      Offset(w * 0.5 + 0.6, 0),
      Offset(w * 0.5 + 0.6, h),
      gridShadowPaint,
    );
    canvas.drawLine(
      Offset(0, h * 0.45 + 0.6),
      Offset(w, h * 0.45 + 0.6),
      gridShadowPaint,
    );

    canvas.drawLine(Offset(w * 0.5, 0), Offset(w * 0.5, h), gridPaint);
    canvas.drawLine(Offset(0, h * 0.45), Offset(w, h * 0.45), gridPaint);

    // 9. Recessed Border Shadow
    final Paint borderShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTRB(0, 0, w, h), borderShadowPaint);

    // 10. Diagonal Glass glare lines
    final Paint glarePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.015),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTRB(0, 0, w, h))
      ..strokeWidth = 4.0;

    canvas.drawLine(Offset(w * 0.25, 0), Offset(0, w * 0.25), glarePaint);
    canvas.drawLine(Offset(w * 0.65, 0), Offset(0, w * 0.65), glarePaint);
    canvas.drawLine(Offset(w * 0.9, 0), Offset(w * 0.15, h), glarePaint);
  }

  @override
  bool shouldRepaint(covariant CityViewWindowPainter oldDelegate) {
    return oldDelegate.resolvedMode != resolvedMode ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isTopWindow != isTopWindow;
  }
}
