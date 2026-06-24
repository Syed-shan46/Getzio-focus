import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/onboarding_models.dart';
import '../providers/onboarding_providers.dart';
import '../../../os_dashboard/presentation/screens/os_dashboard_screen.dart';
import '../../../../main.dart';

/// Screen 9 — Workspace Preview & Launch
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  bool _isLaunching = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 850),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _launchWorkspace() async {
    setState(() => _isLaunching = true);

    await ref.read(onboardingProvider.notifier).completeOnboarding();
    ref.read(setupCompletedProvider.notifier).state = true;

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OSDashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    // Check which areas are selected
    final showBooks = state.selectedLifeAreas.contains('reading');
    final showJournal = state.selectedLifeAreas.contains('journaling');
    final showFinance = state.selectedLifeAreas.contains('finance');
    final showHealth = state.selectedLifeAreas.contains('health');

    // Get pinned affirmation
    final pinnedAff = state.selectedAffirmations.firstWhere(
      (a) => a.isPinned,
      orElse: () => state.selectedAffirmations.isNotEmpty
          ? state.selectedAffirmations.first
          : DailyAffirmation(
              id: 'default',
              text: 'Discipline creates freedom.',
            ),
    );

    return SafeArea(
      bottom: false,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _fadeController,
          curve: Curves.easeOut,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Headline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'Your Workspace\nis Ready.',
                style: AppTypography.displayLarge(
                  color: Colors.white,
                ).copyWith(fontSize: 32, height: 1.12, letterSpacing: -0.8),
              ),
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'A living environment tailored to your growth.',
                style: AppTypography.bodyMedium(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── LIVING ROOM CANVAS PREVIEW ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: CustomPaint(
                    painter: _MiniWorkspacePainter(
                      showBooks: showBooks,
                      showJournal: showJournal,
                      showFinance: showFinance,
                      showHealth: showHealth,
                      pinnedAffirmation: pinnedAff.text,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Summary description
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Dynamic detail pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.accentBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Personalized Environment',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Your selected habits, goals, and customized items have been integrated into your space.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 11,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Launch Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLaunching ? null : _launchWorkspace,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: Colors.white.withValues(
                            alpha: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLaunching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Enter Workspace',
                                style:
                                    AppTypography.titleMedium(
                                      color: Colors.black,
                                    ).copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),
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

/// Custom painter to draw a personalized preview of the Living Room workspace
class _MiniWorkspacePainter extends CustomPainter {
  final bool showBooks;
  final bool showJournal;
  final bool showFinance;
  final bool showHealth;
  final String pinnedAffirmation;

  const _MiniWorkspacePainter({
    required this.showBooks,
    required this.showJournal,
    required this.showFinance,
    required this.showHealth,
    required this.pinnedAffirmation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // ─── 1. WALL & FLOOR GRADIENT ───
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF161A24), Color(0xFF070B13), Colors.black],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final deskTop = h * 0.72;

    // Floor skirting board
    final floorPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, deskTop, w, h - deskTop), floorPaint);

    // Skirting highlight line
    canvas.drawLine(
      Offset(0, deskTop),
      Offset(w, deskTop),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..strokeWidth = 1,
    );

    // ─── 2. VISION ROOM WOODEN DOOR (Left side) ───
    final doorW = w * 0.20;
    final doorH = h * 0.54;
    final doorLeft = w * 0.08;
    final doorTop = deskTop - doorH;

    // Door Frame Outer
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(doorLeft, doorTop, doorW, doorH),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF2D1E18),
    );

    // Door Panel Inner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(doorLeft + 3, doorTop + 3, doorW - 6, doorH - 3),
        const Radius.circular(5),
      ),
      Paint()
        ..shader =
            const LinearGradient(
              colors: [Color(0xFF4A342B), Color(0xFF1F120D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(
              Rect.fromLTWH(doorLeft + 3, doorTop + 3, doorW - 6, doorH - 3),
            ),
    );

    // Door Handle (unlocked brass look)
    canvas.drawCircle(
      Offset(doorLeft + doorW - 8, doorTop + doorH * 0.55),
      3.2,
      Paint()..color = const Color(0xFFFCD34D),
    );

    // ─── 3. FLOATING WOODEN SHELF (Right side) ───
    final shelfY = h * 0.35;
    final shelfW = w * 0.38;
    final shelfLeft = w * 0.54;
    final shelfH = 6.0;

    final shelfPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8D6E63), Color(0xFF4E342E)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(shelfLeft, shelfY, shelfW, shelfH));

    canvas.drawRect(
      Rect.fromLTWH(shelfLeft, shelfY, shelfW, shelfH),
      shelfPaint,
    );
    // Shelf shadow
    canvas.drawRect(
      Rect.fromLTWH(shelfLeft, shelfY + shelfH, shelfW, 2),
      Paint()..color = Colors.black54,
    );

    // ─── 4. BOOKS ON SHELF (Reading Selected) ───
    final double bookH = 15.0;
    if (showBooks) {
      final double bookBaseX = shelfLeft + 12.0;
      final double bookY = shelfY;

      // Blue book
      canvas.drawRect(
        Rect.fromLTWH(bookBaseX, bookY - bookH, 5, bookH),
        Paint()..color = const Color(0xFF2563EB),
      );
      // Red book
      canvas.drawRect(
        Rect.fromLTWH(bookBaseX + 5, bookY - bookH, 4, bookH),
        Paint()..color = const Color(0xFFDC2626),
      );
      // Green book
      canvas.drawRect(
        Rect.fromLTWH(bookBaseX + 9, bookY - bookH, 5, bookH),
        Paint()..color = const Color(0xFF059669),
      );
      // Yellow book (tilted)
      canvas.save();
      canvas.translate(bookBaseX + 14, bookY);
      canvas.rotate(0.20);
      canvas.drawRect(
        Rect.fromLTWH(0, -bookH, 4, bookH),
        Paint()..color = const Color(0xFFD97706),
      );
      canvas.restore();
    }

    // ─── 5. PLANT ON SHELF / HEALTH OBJECT (Always show a nice Bonsai plant) ───
    final double potBaseX = shelfLeft + shelfW - 24.0;
    final double plantY = shelfY;

    // Plant Pot
    canvas.drawRect(
      Rect.fromLTWH(potBaseX, plantY - 8, 10, 8),
      Paint()..color = const Color(0xFFE2E8F0),
    );
    canvas.drawRect(
      Rect.fromLTWH(potBaseX - 1, plantY - 8, 12, 1.8),
      Paint()..color = const Color(0xFFCBD5E1),
    );

    // Green Bonsai Leaves — capped at bookH so the plant matches shelf flow
    final leafPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(Offset(potBaseX + 2, plantY - 11), 4.5, leafPaint);
    canvas.drawCircle(Offset(potBaseX + 8, plantY - 13), 5, leafPaint);
    canvas.drawCircle(Offset(potBaseX + 5, plantY - 17), 4.5, leafPaint);

    // Trailing Ivy Vine if Health is selected
    if (showHealth) {
      final stemPaint = Paint()
        ..color = const Color(0xFF047857)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      final vine = Path()
        ..moveTo(potBaseX + 5, plantY - 2)
        ..quadraticBezierTo(potBaseX + 9, plantY + 8, potBaseX + 6, plantY + 16)
        ..quadraticBezierTo(
          potBaseX + 3,
          plantY + 22,
          potBaseX + 7,
          plantY + 30,
        );
      canvas.drawPath(vine, stemPaint);

      final ivyLeafPaint = Paint()..color = const Color(0xFF34D399);
      canvas.drawCircle(Offset(potBaseX + 8, plantY + 8), 1.8, ivyLeafPaint);
      canvas.drawCircle(Offset(potBaseX + 5, plantY + 16), 2.2, ivyLeafPaint);
      canvas.drawCircle(Offset(potBaseX + 6, plantY + 26), 1.5, ivyLeafPaint);
    }

    // ─── 6. PINNED AFFIRMATION WALL FRAME (Center Wall) ───
    final frameW = w * 0.32;
    final frameH = h * 0.20;
    final frameLeft = w * 0.34;
    final frameTop = h * 0.12;

    // Wood frame border
    canvas.drawRect(
      Rect.fromLTWH(frameLeft, frameTop, frameW, frameH),
      Paint()..color = const Color(0xFF3E2723),
    );
    // Inner mat boarding
    canvas.drawRect(
      Rect.fromLTWH(frameLeft + 3, frameTop + 3, frameW - 6, frameH - 6),
      Paint()..color = const Color(0xFFECEFF1),
    );

    // Draw affirmation text inside the mat boarding
    final textPainter = TextPainter(
      text: TextSpan(
        text: pinnedAffirmation.length > 24
            ? '${pinnedAffirmation.substring(0, 22)}...'
            : pinnedAffirmation,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 5.5,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontFamily: 'serif',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: frameW - 10);
    textPainter.paint(
      canvas,
      Offset(
        frameLeft + 5 + (frameW - 10 - textPainter.width) / 2,
        frameTop + 5 + (frameH - 10 - textPainter.height) / 2,
      ),
    );

    // Frame glass/content highlight reflection
    canvas.drawRect(
      Rect.fromLTWH(frameLeft + 4, frameTop + 4, frameW - 8, frameH - 8),
      Paint()..color = Colors.white.withValues(alpha: 0.08),
    );

    // ─── 7. THE DESK (Bottom Area) ───
    final deskH = 14.0;
    final deskPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.1, deskTop, w * 0.8, deskH));

    // Wooden desk plank overlay
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, deskTop, w * 0.90, deskH),
        const Radius.circular(4),
      ),
      deskPaint,
    );
    // Desk surface bottom edge shadow
    canvas.drawRect(
      Rect.fromLTWH(w * 0.05, deskTop + deskH, w * 0.90, 2),
      Paint()..color = Colors.black45,
    );

    // ─── 8. JOURNAL NOTEBOOK ON DESK (Journaling Selected) ───
    if (showJournal) {
      final double noteX = w * 0.40;
      final double noteY = deskTop;
      final double noteW = 18.0;
      final double noteH = 4.0;

      // Dark brown leather cover
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(noteX, noteY - noteH, noteW, noteH),
          const Radius.circular(1.5),
        ),
        Paint()..color = const Color(0xFF4E342E),
      );

      // Gold binding bookmark strap
      canvas.drawRect(
        Rect.fromLTWH(noteX + noteW * 0.4, noteY - noteH, 2, noteH + 1),
        Paint()..color = const Color(0xFFD97706),
      );
    }

    // ─── 9. COIN / PIGGY BANK OBJECT ON DESK (Finance Selected) ───
    if (showFinance) {
      final double coinX = w * 0.65;
      final double coinY = deskTop;

      // Small gold coin stand
      canvas.drawCircle(
        Offset(coinX, coinY - 4),
        3.5,
        Paint()..color = const Color(0xFFFBBF24),
      );
      canvas.drawCircle(
        Offset(coinX - 1.5, coinY - 4.5),
        1,
        Paint()..color = const Color(0xFFFEF3C7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniWorkspacePainter oldDelegate) {
    return oldDelegate.showBooks != showBooks ||
        oldDelegate.showJournal != showJournal ||
        oldDelegate.showFinance != showFinance ||
        oldDelegate.showHealth != showHealth ||
        oldDelegate.pinnedAffirmation != pinnedAffirmation;
  }
}
