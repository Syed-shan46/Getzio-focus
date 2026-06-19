import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../main.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    HapticFeedback.mediumImpact();
    final hiveDb = ref.read(hiveDatabaseProvider);
    await hiveDb.saveOnboardingCompleted(true);
    // Trigger StateProvider update to refresh MaterialApp home selection
    ref.read(onboardingCompletedProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      body: Stack(
        children: [
          // ─── BACKGROUND GLOW SYSTEM ────────────────────────────────────────
          Container(color: const Color(0xFF030712)),
          
          // Radial/Linear Backdrop Gradients
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0B1528), // Soft Deep Blue
                    Color(0xFF0F0E26), // Indigo
                    Color(0xFF1A0A2A), // Violet
                  ],
                ),
              ),
            ),
          ),

          // Top Left Ambient Glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.15),
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Right Ambient Glow
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA855F7).withValues(alpha: 0.15), // Violet Glow
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // ─── PAGES & PAGINATION ───────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Logo
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '⚡',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Getzio Focus',
                        style: AppTypography.titleMedium().copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      HapticFeedback.selectionClick();
                    },
                    children: [
                      _buildPage(
                        title: 'Organize Effortlessly',
                        description: 'Create and structure tasks and subtasks under a stunning glassmorphic interface.',
                        mockup: const OnboardingMockupOne(),
                      ),
                      _buildPage(
                        title: 'Track Progress',
                        description: 'Stay driven with beautiful completion rings, graphs, and live focus metrics.',
                        mockup: const OnboardingMockupTwo(),
                      ),
                      _buildPage(
                        title: 'Stay Motivated',
                        description: 'Unlock key achievements, build streaks, and power up your daily progress.',
                        mockup: const OnboardingMockupThree(),
                      ),
                    ],
                  ),
                ),

                // Bottom Navigation controls
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      // Smooth Pagination Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isActive = _currentPage == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: isActive ? 18 : 6,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.accentBlue
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Actions (Next / Get Started)
                      GestureDetector(
                        onTap: () {
                          if (_currentPage < 2) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _finishOnboarding();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 52,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: _currentPage == 2
                                ? const LinearGradient(
                                    colors: [AppColors.accentBlue, Color(0xFFA855F7)],
                                  )
                                : null,
                            color: _currentPage == 2 ? null : AppColors.accentBlue,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            boxShadow: [
                              BoxShadow(
                                color: (_currentPage == 2 ? const Color(0xFFA855F7) : AppColors.accentBlue)
                                    .withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _currentPage == 2 ? 'Get Started' : 'Next',
                              style: AppTypography.bodyLarge(
                                color: Colors.white,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required Widget mockup,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Elevated Graphic Mockup
          Expanded(
            child: Center(
              child: mockup,
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),

          // Titles & Copy
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.displayLarge(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ─── SMARTPHONE MOCKUP FRAME WIDGET ───────────────────────────────────────
class SmartphoneMockup extends StatelessWidget {
  final Widget child;

  const SmartphoneMockup({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 440,
      decoration: BoxDecoration(
        color: const Color(0xFF080D1A), // Sleek OLED Black
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: AppColors.accentBlue.withValues(alpha: 0.05),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Notch
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 100,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
          ),
          // Inner Padding for Screen Content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 28, 12, 12),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─── MOCKUP CONTENT FOR SCREEN 1 ──────────────────────────────────────────
class OnboardingMockupOne extends StatelessWidget {
  const OnboardingMockupOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Phone Layout
        SmartphoneMockup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Task List',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Active Task Card
              _buildMockTask('Finalize Project Proposal', true, true),
              // Inactive Task Card
              _buildMockTask('Review Marketing Strategy', false, false),
              // Another Card
              _buildMockTask('TeamSync Meeting (3 PM)', false, false),
            ],
          ),
        ),

        // Floating Checkmark Badge
        Positioned(
          top: 140,
          right: -8,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1D3557).withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF4FA6FF),
                size: 26,
              ),
            ),
          ),
        ),

        // Floating Calendar Badge
        Positioned(
          bottom: 40,
          right: -10,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2B1D38).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_rounded, color: Color(0xFFA855F7), size: 20),
                SizedBox(height: 4),
                Text(
                  '33',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMockTask(String title, bool isActive, bool checked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.accentBlue.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive 
              ? AppColors.accentBlue.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.05),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: checked ? AppColors.accentBlue : Colors.white24,
                width: 1.5,
              ),
              color: checked ? AppColors.accentBlue : Colors.transparent,
            ),
            child: checked
                ? const Icon(Icons.check, size: 8, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MOCKUP CONTENT FOR SCREEN 2 ──────────────────────────────────────────
class OnboardingMockupTwo extends StatelessWidget {
  const OnboardingMockupTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartphoneMockup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            'Time Tracker',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Completion Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                // Ring
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: 0.78,
                        strokeWidth: 4,
                        color: AppColors.accentBlue,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                      ),
                      const Center(
                        child: Text(
                          '78%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tasks Completed Today',
                      style: TextStyle(color: Colors.white54, fontSize: 8),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '78% of Daily Goal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Line graph mockup
          const Text(
            'Weekly Focus Hours',
            style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: CustomPaint(
                painter: SparklinePainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MOCKUP CONTENT FOR SCREEN 3 ──────────────────────────────────────────
class OnboardingMockupThree extends StatelessWidget {
  const OnboardingMockupThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Smartphone
        SmartphoneMockup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Achievements',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              // Achievement rows
              _buildMockAchievement('🏆', 'Milestone Reached!', 'Done 15 tasks'),
              _buildMockAchievement('🔥', 'Focus Streak: 5 days', 'Continuous progress'),
              
              const SizedBox(height: 12),
              
              // Progress checkmarks
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Ready to sync tasks',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Floating Trophy Icon
        Positioned(
          top: -15,
          left: -8,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF382B14).withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 1),
            ),
            child: const Center(
              child: Text(
                '🏆',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),

        // Floating Rocket Icon
        Positioned(
          bottom: 120,
          right: -10,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1D3534).withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.teal.withValues(alpha: 0.3), width: 1),
            ),
            child: const Center(
              child: Text(
                '🚀',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMockAchievement(String emoji, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CUSTOM GRAPH PAINTER ───────────────────────────────────────────────
class SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = AppColors.accentBlue.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    // Define line path points representing focus hours
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.16, size.height * 0.7),
      Offset(size.width * 0.33, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.65),
      Offset(size.width * 0.66, size.height * 0.2),
      Offset(size.width * 0.83, size.height * 0.5),
      Offset(size.width, size.height * 0.3),
    ];

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Gradient fill under the graph line
    final fillPath = Path()
      ..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    fillPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.accentBlue.withValues(alpha: 0.15), Colors.transparent],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Callout Dot at the peak (index 4)
    final peakDot = points[4];
    final dotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = AppColors.accentBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(peakDot, 4, dotPaint);
    canvas.drawCircle(peakDot, 4, dotBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
