import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../os_dashboard/presentation/screens/os_dashboard_screen.dart';

/// Premium model representing a single daily quote
class MotivationQuote {
  final String text;
  final String author;
  const MotivationQuote(this.text, this.author);
}

/// Dynamic dust particle properties for ambient warm atmosphere
class DustParticle {
  double x; // Normalized 0.0 - 1.0
  double y; // Normalized 0.0 - 1.0
  double size;
  double speed;
  double opacity;
  double angle;

  DustParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.angle,
  });

  void update() {
    y -= speed; // Move upwards
    x += math.sin(angle) * 0.0004; // Gentle horizontal drift
    angle += 0.02;
    if (y < -0.05) {
      y = 1.05;
      x = math.Random().nextDouble();
    }
  }
}

class DailyMotivationScreen extends ConsumerStatefulWidget {
  const DailyMotivationScreen({super.key});

  @override
  ConsumerState<DailyMotivationScreen> createState() => _DailyMotivationScreenState();
}

class _DailyMotivationScreenState extends ConsumerState<DailyMotivationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _particleController;

  // Particle list
  final List<DustParticle> _particles = [];
  final math.Random _random = math.Random();

  // Animation sub-ranges
  late Animation<double> _bgFadeAnimation;
  late Animation<double> _greetingSlideAnimation;
  late Animation<double> _greetingFadeAnimation;
  late Animation<double> _quoteScaleAnimation;
  late Animation<double> _quoteFadeAnimation;
  late Animation<double> _authorFadeAnimation;
  late Animation<double> _buttonFadeAnimation;

  // Quote logic
  late MotivationQuote _currentQuote;
  late String _greeting;
  late String _dayName;
  late String _dateStr;

  Timer? _autoContinueTimer;
  bool _isNavigated = false;

  final List<MotivationQuote> _quotesList = const [
    MotivationQuote("Every small step today is building the future you've been dreaming about.", "Getzio"),
    MotivationQuote("Consistency beats perfection. Show up today.", "Getzio"),
    MotivationQuote("Dreams grow through action, not waiting.", "Getzio"),
    MotivationQuote("The life you imagine begins with today's decisions.", "Getzio"),
    MotivationQuote("Progress is still progress, no matter how small.", "Getzio"),
    MotivationQuote("Your future is created by what you repeat today.", "Getzio"),
    MotivationQuote("Build habits that keep moving you forward.", "Getzio"),
    MotivationQuote("The strongest version of you is built one day at a time.", "Getzio"),
    MotivationQuote("Today's discipline becomes tomorrow's freedom.", "Getzio"),
    MotivationQuote("Big achievements begin with small promises kept.", "Getzio"),
    MotivationQuote("Stay focused on becoming better than yesterday.", "Getzio"),
    MotivationQuote("Every challenge prepares you for the life you want.", "Getzio"),
    MotivationQuote("Believe in the person you're becoming.", "Getzio"),
    MotivationQuote("Your goals deserve today's effort.", "Getzio"),
    MotivationQuote("Keep moving. Small actions repeated daily change everything.", "Getzio"),
  ];

  @override
  void initState() {
    super.initState();

    _setupQuoteAndTime();
    _setupAnimations();
    _setupParticles();

    // Start animating
    _animController.forward();
    _particleController.repeat();

    // Auto-continue timer (3 seconds after animations complete)
    _autoContinueTimer = Timer(const Duration(milliseconds: 3800), () {
      _navigateToHome();
    });
  }

  void _setupQuoteAndTime() {
    final now = DateTime.now();

    // Determine Greeting
    final hour = now.hour;
    if (hour >= 5 && hour < 12) {
      _greeting = "Good Morning ☀️";
    } else if (hour >= 12 && hour < 17) {
      _greeting = "Good Afternoon ☀️";
    } else {
      _greeting = "Good Evening 🌙";
    }

    // Format Date
    _dayName = DateFormat('EEEE').format(now); // e.g. "Wednesday"
    _dateStr = "${now.day} ${DateFormat('MMMM').format(now)}"; // e.g. "8 July"

    // Load Quote based on Daily Rotation Logic
    final hiveDb = ref.read(hiveDatabaseProvider);
    final String todayStr = "${now.year}-${now.month}-${now.day}";
    final lastSavedDate = hiveDb.getLastQuoteDate();
    int activeIndex = hiveDb.getQuoteIndex();

    if (lastSavedDate != todayStr) {
      if (lastSavedDate != null) {
        // Rotate index only if not the first launch ever
        activeIndex = (activeIndex + 1) % _quotesList.length;
      }
      hiveDb.saveQuoteIndex(activeIndex);
      hiveDb.saveLastQuoteDate(todayStr);
    }

    _currentQuote = _quotesList[activeIndex];
  }

  void _setupAnimations() {
    // Total animation transition lasts 850 ms
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    // 1. Background fades in
    _bgFadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    // 2. Greeting slides down and fades in
    _greetingSlideAnimation = Tween<double>(begin: -16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.15, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _greetingFadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.15, 0.6, curve: Curves.easeOut),
    );

    // 3. Quote card fades + scales
    _quoteScaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
      ),
    );
    _quoteFadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );

    // 4. Author fades in
    _authorFadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.5, 0.85, curve: Curves.easeIn),
    );

    // 5. Button fades in
    _buttonFadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
    );
  }

  void _setupParticles() {
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    // Generate 25 subtle floating particles
    for (int i = 0; i < 25; i++) {
      _particles.add(DustParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3.0 + 1.0,
        speed: _random.nextDouble() * 0.001 + 0.0003,
        opacity: _random.nextDouble() * 0.4 + 0.15,
        angle: _random.nextDouble() * math.pi * 2,
      ));
    }

    _particleController.addListener(() {
      setState(() {
        for (var p in _particles) {
          p.update();
        }
      });
    });
  }

  void _navigateToHome() {
    if (_isNavigated) return;
    _isNavigated = true;
    _autoContinueTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const OSDashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _autoContinueTimer?.cancel();
    _animController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _navigateToHome,
        child: Stack(
          children: [
            // 1. Warm Vision Room Gradient Background with Top-Right Sunlight Bloom
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bgFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _bgFadeAnimation.value,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0F1524), // Dark deep purple-blue
                            Color(0xFF131B30),
                            Color(0xFF1F1D36), // Warm ambient tint
                          ],
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: Stack(
                  children: [
                    // Sunlight glow from top-right corner
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFD59E).withOpacity(0.18), // Warm golden sun bloom
                              const Color(0xFFFF9E79).withOpacity(0.06),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Ambient light center bloom
                    Center(
                      child: Container(
                        width: 600,
                        height: 600,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF6B5B95).withOpacity(0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Animated Custom Dust Particles
            Positioned.fill(
              child: CustomPaint(
                painter: DustParticlesPainter(particles: _particles),
              ),
            ),

            // 3. Vignette Overlay (Dark soft border edges for focus and luxury depth)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.3,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.25),
                        Colors.black.withOpacity(0.55),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 4. Main Interactive UI Layout
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 3),

                    // Top Greeting Section
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0.0, _greetingSlideAnimation.value),
                          child: Opacity(
                            opacity: _greetingFadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            _greeting,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 34,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _dayName,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              Text(
                                _dateStr,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 4),

                    // Central Glassmorphic Quote Card
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _quoteScaleAnimation.value,
                          child: Opacity(
                            opacity: _quoteFadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: Colors.white.withOpacity(0.04),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32.0,
                            vertical: 36.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentQuote.text,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.95),
                                  height: 1.45,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 20),
                              AnimatedBuilder(
                                animation: _authorFadeAnimation,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _authorFadeAnimation.value,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  "— ${_currentQuote.author}",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFFFD59E).withOpacity(0.85),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Helper text under card
                    AnimatedBuilder(
                      animation: _quoteFadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _quoteFadeAnimation.value,
                          child: child,
                        );
                      },
                      child: Text(
                        "Today's Daily Motivation",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.3),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const Spacer(flex: 5),

                    // Bottom Continue Section
                    AnimatedBuilder(
                      animation: _buttonFadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _buttonFadeAnimation.value,
                          child: child,
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: _navigateToHome,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0F1524),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Continue",
                                  style: GoogleFonts.outfit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Tap anywhere to continue",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
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

/// Custom painter to render subtle floating dust particles
class DustParticlesPainter extends CustomPainter {
  final List<DustParticle> particles;

  DustParticlesPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      paint.color = Colors.white.withOpacity(p.opacity);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
