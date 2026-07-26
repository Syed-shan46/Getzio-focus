import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = backgroundColor ?? context.colors.accentBlue;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: (isLoading || onPressed == null) ? null : () {
          Feedback.forLongPress(context);
          onPressed!();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          foregroundColor: foregroundColor ?? Colors.white,
          disabledBackgroundColor: themeColor.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    text,
                    style: AppTypography.bodyLarge(
                      color: foregroundColor ?? Colors.white,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.textPrimary.withValues(alpha: 0.05),
          foregroundColor: context.colors.textPrimary,
          disabledBackgroundColor: context.colors.textPrimary.withValues(alpha: 0.02),
          disabledForegroundColor: context.colors.textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              text,
              style: AppTypography.bodyLarge(
                color: context.colors.textPrimary,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class AppOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;

  const AppOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: context.colors.textPrimary.withValues(alpha: 0.15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              text,
              style: AppTypography.bodyLarge(
                color: context.colors.textPrimary,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class FABButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String? label;

  const FABButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final decoration = BoxDecoration(
      color: colors.glass,
      borderRadius: BorderRadius.circular(AppRadius.round),
      border: Border.all(color: colors.glassBorder, width: 0.5),
      boxShadow: [
        BoxShadow(
          color: colors.accentBlue.withValues(alpha: isDark ? 0.3 : 0.15),
          blurRadius: 24,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );

    if (label != null) {
      return Container(
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadius.round),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  child,
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    label!,
                    style: AppTypography.bodyLarge(color: colors.textPrimary)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = AppIcons.medium,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: size,
        color: color ?? context.colors.textPrimary,
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      constraints: const BoxConstraints(),
    );
  }
}
