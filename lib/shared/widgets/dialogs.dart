import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'buttons.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String content;
  final Widget? icon;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final String cancelLabel;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel = 'Cancel',
    this.onCancel,
    this.isDestructive = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    Widget? icon,
    required String confirmLabel,
    required VoidCallback onConfirm,
    String cancelLabel = 'Cancel',
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        content: content,
        icon: icon,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        cancelLabel: cancelLabel,
        onCancel: onCancel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : context.colors.bg2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              title,
              style: AppTypography.titleLarge(color: context.colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              content,
              style: AppTypography.bodyMedium(color: context.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              text: confirmLabel,
              onPressed: onConfirm,
              backgroundColor: isDestructive ? Colors.redAccent : context.colors.accentBlue,
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: onCancel ?? () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: context.colors.textSecondary,
              ),
              child: Text(
                cancelLabel,
                style: AppTypography.bodyLarge(
                  color: context.colors.textSecondary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
