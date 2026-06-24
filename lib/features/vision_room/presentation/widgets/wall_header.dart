import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class WallHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onAddPressed;

  const WallHeader({
    super.key, 
    required this.title, 
    required this.subtitle,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: AppTypography.displayMedium(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodyMedium(color: Colors.white70),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onAddPressed();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.glass,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text('Add', style: AppTypography.caption(color: Colors.white).copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
