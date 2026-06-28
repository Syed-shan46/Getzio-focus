import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/phone_login_screen.dart';

class PremiumAuthSheet extends StatefulWidget {
  const PremiumAuthSheet({super.key});

  static bool _isShowing = false;

  /// Display the Premium Auth modal sheet with haptic feedback and safety guards.
  static void show(BuildContext context) {
    if (_isShowing) return;
    _isShowing = true;
    HapticFeedback.vibrate();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => const PremiumAuthSheet(),
    ).whenComplete(() {
      _isShowing = false;
    });
  }

  @override
  State<PremiumAuthSheet> createState() => _PremiumAuthSheetState();
}

class _PremiumAuthSheetState extends State<PremiumAuthSheet> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isLandscape = mq.orientation == Orientation.landscape;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutBack, // Spring animation curve
        builder: (context, animValue, child) {
          return Transform.scale(
            scale: 0.88 + (0.12 * animValue),
            child: Opacity(
              opacity: animValue.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: isLandscape ? mq.size.height * 0.9 : double.infinity,
          ),
          child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1E293B).withValues(alpha: 0.92),
                const Color(0xFF0F172A).withValues(alpha: 0.98),
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Warm Glowing Lighting Backdrop (Amber/Bronze glow in the top-left)
                Positioned(
                  top: -100,
                  left: -100,
                  width: 280,
                  height: 280,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFF59E0B).withOpacity(0.14),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Main Sheet Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top indicator pill
                      Center(
                        child: Container(
                          width: 42,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Premium Illustration Badge
                      Center(
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF59E0B).withOpacity(0.15),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withOpacity(0.28),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFF59E0B),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Title
                      Text(
                        '✨ Unlock Your Personal Workspace',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        "You've reached the free guest limit.\nCreate a free account to unlock unlimited Vision Boards, Daily Affirmations and secure cloud backup across all your devices.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Divider
                      Container(
                        height: 0.8,
                        color: Colors.white.withOpacity(0.08),
                      ),
                      const SizedBox(height: 20),

                      // Benefits Grid / List
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            _buildBenefit('✓ Unlimited Sticky Notes'),
                            _buildBenefit('✓ Unlimited Vision Images'),
                            _buildBenefit('✓ Unlimited Quotes'),
                            _buildBenefit('✓ Unlimited Daily Affirmations'),
                            _buildBenefit('✓ Secure Cloud Backup'),
                            _buildBenefit('✓ Sync Across Devices'),
                            _buildBenefit('✓ Future Premium Features'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Primary "Continue with Phone" Button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PhoneLoginScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.phone_android_rounded,
                            color: Colors.black,
                            size: 20,
                          ),
                          label: Text(
                            'Continue with Phone',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Secondary "Maybe Later" Button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Maybe Later',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Top Right Close Button
                Positioned(
                  top: 14,
                  right: 14,
                  child: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withOpacity(0.4),
                      size: 22,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF34D399),
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text.replaceFirst('✓ ', ''),
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
