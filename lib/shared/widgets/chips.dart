import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AppCategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppAnimations.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.accentBlue
              : (isDark ? Colors.white.withValues(alpha: 0.05) : context.colors.textPrimary.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
        child: Text(
          label,
          style: AppTypography.caption(
            color: isSelected ? Colors.white : context.colors.textSecondary,
          ).copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class AppPriorityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const AppPriorityChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : context.colors.textPrimary.withValues(alpha: 0.03)),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.caption(
              color: isSelected ? color : context.colors.textSecondary,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class AppStatusChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const AppStatusChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
      child: Text(
        label,
        style: AppTypography.captionSmall(color: textColor).copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
