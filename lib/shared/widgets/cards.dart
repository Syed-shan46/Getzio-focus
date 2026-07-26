import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PrimaryCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const PrimaryCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.bg2,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.md),
        border: AppBorders.thin(context),
      ),
      child: child,
    );
  }
}

class ElevatedCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const ElevatedCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.bg3,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
        border: AppBorders.thin(context),
      ),
      child: child,
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.radius = AppRadius.lg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: GlassDecoration.blurSigma,
            sigmaY: GlassDecoration.blurSigma,
          ),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.glass,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: context.colors.glassBorder, width: 0.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? cardColor;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardColor ?? context.colors.accentBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: cardColor?.withValues(alpha: 0.2) ?? context.colors.accentBlue.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium(color: context.colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: AppTypography.caption(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? context.colors.accentBlue;
    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.captionSmall(color: context.colors.textMuted),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: AppIcons.small,
                  color: themeColor,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.displayMedium(color: context.colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
