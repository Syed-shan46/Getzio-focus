import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? trailing;
  final double maxHeightPercent;

  const AppBottomSheet({
    super.key,
    required this.child,
    required this.title,
    this.trailing,
    this.maxHeightPercent = 0.82,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    required String title,
    Widget? trailing,
    double maxHeightPercent = 0.82,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AppBottomSheet(
        title: title,
        trailing: trailing,
        maxHeightPercent: maxHeightPercent,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * maxHeightPercent),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131722) : context.colors.bg2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: GlassDecoration.backgroundBlurSigma,
              sigmaY: GlassDecoration.backgroundBlurSigma,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.xs,
                    top: AppSpacing.sm,
                    bottom: AppSpacing.xxs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleLarge(color: context.colors.textPrimary),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      top: AppSpacing.xs,
                      bottom: AppSpacing.lg + bottomInset,
                    ),
                    child: child,
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
