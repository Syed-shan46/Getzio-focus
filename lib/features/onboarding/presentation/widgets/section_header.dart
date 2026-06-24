import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Reusable section header for grouping chips within onboarding screens.
/// Displays a label with optional subtitle, separated with generous spacing.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.only(left: 28, right: 28, top: 24, bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium(
              color: Colors.white.withValues(alpha: 0.5),
            ).copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTypography.captionSmall(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
