import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FocusAnimatedDigits extends StatelessWidget {
  final int remainingSeconds;
  final bool isBreakMode;
  final double? fontSize;

  const FocusAnimatedDigits({
    super.key,
    required this.remainingSeconds,
    this.isBreakMode = false,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final m = (remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    final timeStr = "$m:$s";

    final Color glowColor = isBreakMode ? const Color(0xFF66FFB2) : const Color(0xFFFFB266); // Cool green vs Amber

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Slide up, scale slightly, fade in
        final inAnimation = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(animation);
        final outAnimation = Tween<Offset>(begin: const Offset(0.0, -0.2), end: Offset.zero).animate(animation);

        final slideAnimation = child.key == ValueKey(timeStr) ? inAnimation : outAnimation;
        final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          ),
        );
      },
      child: Text(
        timeStr,
        key: ValueKey<String>(timeStr),
        style: GoogleFonts.outfit(
          fontSize: fontSize ?? 64,
          fontWeight: FontWeight.w800,
          height: 1.0,
          letterSpacing: -1.5,
          color: Colors.white,
          shadows: [
            Shadow(
              color: glowColor.withValues(alpha: 0.6),
              blurRadius: 15.0,
            ),
          ],
        ),
      ),
    );
  }
}
