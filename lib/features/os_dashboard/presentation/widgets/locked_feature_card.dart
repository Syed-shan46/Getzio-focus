import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class LockedFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final int currentXp;
  final int targetXp;
  final VoidCallback onDebugUnlock;

  const LockedFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.currentXp,
    required this.targetXp,
    required this.onDebugUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentXp / targetXp).clamp(0.0, 1.0);
    final remaining = targetXp - currentXp;

    return GestureDetector(
      onLongPress: onDebugUnlock, // Hidden debug shortcut to unlock
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, color: Colors.white30, size: 24),
                        const SizedBox(width: 12),
                        Text(title, style: AppTypography.titleLarge(color: Colors.white54)),
                      ],
                    ),
                    Icon(icon, color: Colors.white12, size: 32),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: AppTypography.bodyMedium(color: Colors.white30),
                ),
                const SizedBox(height: 24),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$currentXp / $targetXp XP', style: AppTypography.titleMedium(color: Colors.white)),
                    Text(
                      '$remaining XP Remaining',
                      style: AppTypography.captionSmall(color: AppColors.accentBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep going! Earn XP by completing daily habits.',
                  style: AppTypography.captionSmall(color: Colors.white30),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
