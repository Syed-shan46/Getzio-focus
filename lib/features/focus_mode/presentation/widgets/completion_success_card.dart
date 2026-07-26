import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompletionSuccessCard extends StatelessWidget {
  final int durationMinutes;
  final VoidCallback onDismiss;

  const CompletionSuccessCard({
    super.key,
    required this.durationMinutes,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFD4A017).withValues(alpha: 0.3), // Gold trim
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4A017).withValues(alpha: 0.15),
                  blurRadius: 30.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFFD4A017),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Great Work',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$durationMinutes minutes completed.',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time for a short break.',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onDismiss,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Dismiss',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
