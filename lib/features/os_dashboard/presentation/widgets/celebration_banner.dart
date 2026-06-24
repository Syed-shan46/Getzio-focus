import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/theme/app_theme.dart';

class CelebrationBanner extends StatefulWidget {
  final VoidCallback onDismiss;

  const CelebrationBanner({super.key, required this.onDismiss});

  @override
  State<CelebrationBanner> createState() => _CelebrationBannerState();
}

class _CelebrationBannerState extends State<CelebrationBanner> with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    
    // Animation for sliding Top -> Center
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    
    _slideAnimation = Tween<double>(begin: -1.8, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // Play slide and confetti
    _slideController.forward();
    _confettiController.play();

    // Auto-dismiss logic (dismiss animation after 3.2 seconds, total 4 seconds)
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        _slideController.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Semi-transparent backdrop blur over dashboard
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black38,
              ),
            ),
          ),

          // Confetti Spawner
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 35,
              emissionFrequency: 0.1,
              maxBlastForce: 25,
              minBlastForce: 10,
              gravity: 0.25,
              colors: const [
                Color(0xFFD4AF37), // Metallic Gold
                Colors.orangeAccent,
                Colors.yellowAccent,
                Colors.white,
                Color(0xFFFFDF00),
              ],
            ),
          ),

          // Sliding Glass Card
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Align(
                alignment: Alignment(0, _slideAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 340,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1423).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFFD4AF37), // Golden accent border
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                    blurRadius: 40,
                    spreadRadius: 4,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gold star icon / sparkle decoration
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      color: Color(0xFFD4AF37),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Celebration Headline
                  Text(
                    '🎉 Congratulations!',
                    style: AppTypography.displayMedium(color: const Color(0xFFD4AF37)).copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    "You completed today's discipline plan.",
                    style: AppTypography.bodyMedium(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Rewards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRewardPill(
                        label: '+150 XP',
                        color: Colors.yellowAccent,
                        textColor: Colors.black,
                      ),
                      const SizedBox(width: 12),
                      _buildRewardPill(
                        label: '+5 Discipline Pts',
                        color: AppColors.accentEmerald,
                        textColor: Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Inspirational quote footer
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 16),
                  Text(
                    '"Tomorrow starts another step toward your dream."',
                    style: AppTypography.caption(color: Colors.white54).copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardPill({
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(
        label,
        style: AppTypography.captionSmall(color: textColor).copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
