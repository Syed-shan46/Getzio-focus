import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getzio_todo_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../main.dart';
import '../../../auth/presentation/screens/phone_login_screen.dart';

class PremiumMVPOnboardingScreen extends ConsumerStatefulWidget {
  const PremiumMVPOnboardingScreen({super.key});

  @override
  ConsumerState<PremiumMVPOnboardingScreen> createState() =>
      _PremiumMVPOnboardingScreenState();
}

class _PremiumMVPOnboardingScreenState
    extends ConsumerState<PremiumMVPOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _ambientController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _ambientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  Future<void> _completeAsGuest() async {
    HapticFeedback.mediumImpact();
    final hiveDb = ref.read(hiveDatabaseProvider);
    await hiveDb.saveOnboardingCompleted(true);
    ref.read(onboardingCompletedProvider.notifier).state = true;
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final double screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background subtle ambient light
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF581C87).withValues(alpha: 0.12),
              ),
            ),
          ),

          // Snapping PageView
          PageView(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
              HapticFeedback.selectionClick();
            },
            children: [
              _buildWelcomeScreen(screenW, screenH),
              _buildWorkspaceScreen(screenW, screenH),
              _buildVisionScreen(screenW, screenH),
              _buildRoadmapScreen(screenW, screenH),
              _buildStartScreen(screenW, screenH),
            ],
          ),

          // Skip Button (Top Right)
          if (_currentPage < 4)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 24,
              child: TextButton(
                onPressed: _completeAsGuest,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.45),
                ),
                child: Text(
                  'Skip',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Apple style progress bar indicator at bottom
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Thin progress lines
                Row(
                  children: List.generate(5, (index) {
                    final isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      margin: const EdgeInsets.only(right: 6),
                      height: 3,
                      width: isActive ? 28 : 12,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    );
                  }),
                ),

                // Active Button action
                if (_currentPage < 4)
                  GestureDetector(
                    onTap: _nextPage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
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

  // ─── Screen 1: Welcome ──────────────────────────────────────────────────
  Widget _buildWelcomeScreen(double w, double h) {
    return Column(
      children: [
        SizedBox(height: h * 0.12),
        // Scandinavian Workspace Illustration
        Expanded(
          flex: 5,
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ScandinavianWorkspacePainter(
                      ambientVal: _ambientController.value,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        // Typography & Copy
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Build the future you want to live.',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  'A beautiful space to organize your dreams, stay inspired and grow every day.',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Screen 2: Living Workspace ─────────────────────────────────────────
  Widget _buildWorkspaceScreen(double w, double h) {
    return Column(
      children: [
        SizedBox(height: h * 0.12),
        // Workspace Preview with Hotspots
        Expanded(
          flex: 5,
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _ambientController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _LivingWorkspacePainter(
                            ambientVal: _ambientController.value,
                          ),
                        );
                      },
                    ),
                  ),

                  // Hotspot 1: Vision Door (Left side)
                  Positioned(
                    left: w * 0.25,
                    bottom: h * 0.18,
                    child: _buildHotspotRing(),
                  ),

                  // Hotspot 2: Wooden Shelves (Center)
                  Positioned(
                    left: w * 0.5 - 20,
                    top: h * 0.18,
                    child: _buildHotspotRing(),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your personal productivity space.',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  'A workspace designed to help you stay focused, inspired and intentional.',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotspotRing() {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, _) {
        final double pulse = _ambientController.value;
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Center(
            child: Container(
              width: 12 + 10 * pulse,
              height: 12 + 10 * pulse,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8 * (1.0 - pulse)),
                  width: 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Screen 3: Vision Room ──────────────────────────────────────────────
  Widget _buildVisionScreen(double w, double h) {
    return Column(
      children: [
        SizedBox(height: h * 0.1),
        // Vision Board Mockup
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Mock Corkboard / Pinboard texture
                  Positioned.fill(
                    child: Container(color: const Color(0xFF1A1F2C)),
                  ),

                  // Polaroid 1 (Mountain sunset)
                  Positioned(
                    left: 20,
                    top: 15,
                    child: Transform.rotate(
                      angle: -0.06,
                      child: _buildPolaroid('🏔️', 'Rise above'),
                    ),
                  ),

                  // Polaroid 2 (Beach palm)
                  Positioned(
                    right: 20,
                    top: 25,
                    child: Transform.rotate(
                      angle: 0.08,
                      child: _buildPolaroid('🌴', 'Stay Calm'),
                    ),
                  ),

                  // Sticky Note (Lavender)
                  Positioned(
                    left: 25,
                    bottom: 25,
                    child: Transform.rotate(
                      angle: 0.04,
                      child: _buildStickyNote(
                        'Read 20 mins every morning',
                        const Color(0xFFDDD6FE),
                        const Color(0xFF5B21B6),
                      ),
                    ),
                  ),

                  // Inspirational Quote Frame
                  Positioned(
                    right: 25,
                    bottom: 30,
                    child: Transform.rotate(
                      angle: -0.05,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '"Discipline is freedom."',
                          style: GoogleFonts.outfit(
                            color: Colors.amber,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Title and Features checklist
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Design your future visually.',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Create your own private Vision Room with images, quotes and ideas that inspire you every day.',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                // Checked features list
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildFeatureChip('Add Images'),
                    _buildFeatureChip('Sticky Notes'),
                    _buildFeatureChip('Quotes'),
                    _buildFeatureChip('Resize & Rotate'),
                    _buildFeatureChip('Beautiful Layout'),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPolaroid(String emoji, String caption) {
    return Container(
      width: 75,
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 63,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            caption,
            style: GoogleFonts.outfit(
              color: Colors.black87,
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStickyNote(String text, Color bg, Color textCol) {
    return Container(
      width: 80,
      height: 70,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(1, 1)),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: textCol,
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, color: Colors.greenAccent, size: 11),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Screen 4: Roadmap ──────────────────────────────────────────────────
  Widget _buildRoadmapScreen(double w, double h) {
    return Column(
      children: [
        SizedBox(height: h * 0.1),
        // Visualizing Upcoming Features (Visually Muted)
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRoadmapCard(
                  '✨ Daily Affirmations',
                  'Daily motivation inside your workspace.',
                  true,
                ),
                const SizedBox(height: 10),
                _buildRoadmapCard(
                  '🎯 Daily Focus',
                  'Stay focused on what matters today.',
                  true,
                ),
                const SizedBox(height: 10),
                _buildRoadmapCard(
                  '📝 Journal',
                  'Capture thoughts and reflections.',
                  false,
                ),
                const SizedBox(height: 10),
                _buildRoadmapCard(
                  '📚 Reading',
                  'Track your learning journey.',
                  false,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your workspace will continue to grow.',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  'We\'re building new experiences that will seamlessly become part of your workspace.',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoadmapCard(String title, String subtitle, bool isHighlighted) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(
          0xFF1E293B,
        ).withValues(alpha: isHighlighted ? 0.3 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: isHighlighted ? 0.12 : 0.04),
          width: 1,
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
                    color: Colors.white.withValues(
                      alpha: isHighlighted ? 0.95 : 0.45,
                    ),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(
                      alpha: isHighlighted ? 0.55 : 0.3,
                    ),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Coming Soon',
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(
                  alpha: isHighlighted ? 0.45 : 0.25,
                ),
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Screen 5: Start Your Journey ───────────────────────────────────────
  Widget _buildStartScreen(double w, double h) {
    return Stack(
      children: [
        // Background illustration
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ambientController,
            builder: (context, _) {
              return CustomPaint(
                painter: _LivingWorkspacePainter(
                  ambientVal: _ambientController.value,
                ),
              );
            },
          ),
        ),
        // Dark overlay cover for readability
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.65)),
        ),

        Column(
          children: [
            const Spacer(flex: 3),
            // Header Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    'Start exploring today.',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Enter as a guest or sign in to securely save your Vision Room across all your devices.',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(flex: 4),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Button 1: Continue as Guest
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _completeAsGuest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue as Guest',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Button 2: Sign In
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PhoneLoginScreen(),
                          ),
                        ).then((_) {
                          // If signed in, complete onboarding state
                          final auth = ref.read(authProvider);
                          if (auth.hasValue && auth.value != null) {
                            _completeAsGuest();
                          }
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Note caption
                  Text(
                    'Guest mode lets you explore the app.\nVision Rooms are only saved when you\'re signed in.',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── CUSTOM PAINTERS FOR ARTWORK ──────────────────────────────────────────

// Scandinavian workspace painter
class _ScandinavianWorkspacePainter extends CustomPainter {
  final double ambientVal;
  _ScandinavianWorkspacePainter({required this.ambientVal});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Background wall (soft matte Scandinavian gray)
    final Paint wallPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF334155), Color(0xFF1E293B)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, wallPaint);

    // Warm desk lamp lighting glow
    final Paint glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(
                0xFFFCD34D,
              ).withValues(alpha: 0.16 + 0.05 * math.sin(ambientVal * math.pi)),
              Colors.transparent,
            ],
            radius: 0.7,
          ).createShader(
            Rect.fromCircle(center: Offset(w * 0.75, h * 0.6), radius: w * 0.7),
          );
    canvas.drawRect(Offset.zero & size, glowPaint);

    // Window frame on the left side
    final Paint framePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    final Rect windowRect = Rect.fromLTRB(16, h * 0.15, w * 0.42, h * 0.65);
    canvas.drawRect(windowRect, Paint()..color = const Color(0xFF020617));
    canvas.drawRect(windowRect, framePaint);
    // Divider line inside window
    canvas.drawLine(
      Offset(16 + (w * 0.42 - 16) / 2, h * 0.15),
      Offset(16 + (w * 0.42 - 16) / 2, h * 0.65),
      framePaint,
    );
    canvas.drawLine(
      Offset(16, h * 0.15 + (h * 0.65 - h * 0.15) / 2),
      Offset(w * 0.42, h * 0.15 + (h * 0.65 - h * 0.15) / 2),
      framePaint,
    );

    // Green garden scene inside the window
    final Paint gardenPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF34D399), Color(0xFF047857)],
      ).createShader(windowRect);
    canvas.drawRect(windowRect.deflate(2), gardenPaint);

    // Desk surface at bottom (Sleek light oak wood)
    final Paint deskPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD97706), Color(0xFF78350F)],
      ).createShader(Rect.fromLTRB(0, h * 0.75, w, h));
    canvas.drawRect(Rect.fromLTRB(0, h * 0.75, w, h), deskPaint);

    // Small indoor plant on the desk (right side)
    final Paint plantPotPaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.76, h * 0.7, w * 0.84, h * 0.75),
        const Radius.circular(3),
      ),
      plantPotPaint,
    );
    // Green leaves
    final Paint leafPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(Offset(w * 0.80, h * 0.67), 6.5, leafPaint);
    canvas.drawCircle(Offset(w * 0.77, h * 0.68), 5.5, leafPaint);
    canvas.drawCircle(Offset(w * 0.83, h * 0.68), 5.5, leafPaint);

    // Wooden Shelf above the desk
    final Paint shelfPaint = Paint()..color = const Color(0xFF451A03);
    canvas.drawRect(
      Rect.fromLTRB(w * 0.52, h * 0.35, w * 0.92, h * 0.375),
      shelfPaint,
    );

    // Tiny decorative items/books on the shelf
    final Paint book1Paint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawRect(
      Rect.fromLTRB(w * 0.58, h * 0.28, w * 0.61, h * 0.35),
      book1Paint,
    );
    final Paint book2Paint = Paint()..color = const Color(0xFF3B82F6);
    canvas.drawRect(
      Rect.fromLTRB(w * 0.615, h * 0.29, w * 0.645, h * 0.35),
      book2Paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Living Workspace illustration painter
class _LivingWorkspacePainter extends CustomPainter {
  final double ambientVal;
  _LivingWorkspacePainter({required this.ambientVal});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Room wall base
    final Paint wallPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, wallPaint);

    // Ambient morning/evening sky window visualizer (Center)
    final Rect windowRect = Rect.fromLTRB(
      w * 0.35,
      h * 0.12,
      w * 0.65,
      h * 0.45,
    );
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF38BDF8), Color(0xFFBAE6FD)],
      ).createShader(windowRect);
    canvas.drawRect(windowRect, skyPaint);
    // Draw green hills
    final Paint hillPaint = Paint()..color = const Color(0xFF16A34A);
    canvas.drawCircle(Offset(w * 0.5, h * 0.45), 35, hillPaint);

    // Frame of window
    final Paint framePaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(windowRect, framePaint);

    // Flooringboards
    final Paint floorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2E1912), Color(0xFF150A05)],
      ).createShader(Rect.fromLTRB(0, h * 0.72, w, h));
    canvas.drawRect(Rect.fromLTRB(0, h * 0.72, w, h), floorPaint);

    // Wooden door (Left side)
    final Paint doorPaint = Paint()..color = const Color(0xFF2C1B10);
    final Rect doorRect = Rect.fromLTRB(w * 0.1, h * 0.42, w * 0.28, h * 0.74);
    canvas.drawRect(doorRect, doorPaint);
    canvas.drawRect(
      doorRect,
      Paint()
        ..color = const Color(0xFF3E2723).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Shelves (Right side)
    final Paint shelfPaint = Paint()..color = const Color(0xFF2E1912);
    canvas.drawRect(
      Rect.fromLTRB(w * 0.7, h * 0.35, w * 0.92, h * 0.375),
      shelfPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(w * 0.7, h * 0.55, w * 0.92, h * 0.575),
      shelfPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
