import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    required IconData icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? Colors.white,
              size: AppIcons.small,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium(
                  color: textColor ?? Colors.white,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.grey[850],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: context.colors.success,
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: context.colors.error,
    );
  }

  static void info(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: context.colors.accentBlue,
    );
  }

  static void offline(BuildContext context) {
    show(
      context,
      message: 'You are offline. Connect to internet to sync.',
      icon: Icons.wifi_off_rounded,
      backgroundColor: Colors.grey[850],
    );
  }
}
