import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/auth/presentation/widgets/premium_auth_sheet.dart';
import '../providers/app_providers.dart';
import '../../core/theme/app_theme.dart';

/// A premium, elegant banner shown at the bottom of every screen for guest users.
/// Displays "Preview Mode" message with a CTA to sign in.
/// Auto-hides when the user has an auth token.
class PreviewModeBanner extends ConsumerWidget {
  const PreviewModeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasToken = ref.watch(hiveDatabaseProvider).getAuthToken() != null;
    if (hasToken) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colors.glass.withValues(alpha: 0.85),
                  context.colors.glass.withValues(alpha: 0.6),
                ],
              ),
              border: Border.all(
                color: context.colors.glassBorder.withValues(alpha: 0.4),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.explore_rounded,
                        color: Color(0xFFF59E0B),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Preview Mode',
                      style: GoogleFonts.outfit(
                        color: context.colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        'DEMO',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFF59E0B),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  'Explore every feature. Sign in to create and save your own workspace.',
                  style: GoogleFonts.outfit(
                    color: context.colors.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // CTA Button
                GestureDetector(
                  onTap: () {
                    PremiumAuthSheet.show(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Create My Workspace',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
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
    );
  }
}
