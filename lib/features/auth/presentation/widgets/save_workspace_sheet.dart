import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';
import '../screens/phone_login_screen.dart';

class SaveWorkspaceSheet extends ConsumerWidget {
  const SaveWorkspaceSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SaveWorkspaceSheet(),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required Widget icon,
    required String text,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.glassBorder, width: 0.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            icon,
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodyLarge(
                  color: textColor ?? AppColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: (textColor ?? AppColors.textPrimary).withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg1.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          border: const Border(
            top: BorderSide(color: AppColors.glassBorder, width: 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2.25),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Emoji / Icon Header
            const Center(
              child: Text(
                '☁️',
                style: TextStyle(fontSize: 44),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Header Title
            Text(
              'Save Your Personal Workspace',
              style: AppTypography.displayMedium().copyWith(fontSize: 22, letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Subtitle explanation
            Text(
              'Create a free account to securely save your progress, sync across all your devices, restore your workspace anytime, and never lose your goals, journals, affirmations or Vision Room.',
              style: AppTypography.bodyMedium(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Buttons list
            _buildSocialButton(
              context: context,
              icon: const Text('🍎', style: TextStyle(fontSize: 20)),
              text: 'Continue with Apple',
              onTap: () async {
                Navigator.pop(context, true);
                await ref.read(authProvider.notifier).simulateSocialLogin('Apple');
              },
            ),
            const SizedBox(height: AppSpacing.md),

            _buildSocialButton(
              context: context,
              icon: const Text(' G ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accentBlue)),
              text: 'Continue with Google',
              onTap: () async {
                Navigator.pop(context, true);
                await ref.read(authProvider.notifier).simulateSocialLogin('Google');
              },
            ),
            const SizedBox(height: AppSpacing.md),

            _buildSocialButton(
              context: context,
              icon: const Icon(Icons.phone_android_rounded, color: AppColors.accentBlue, size: 20),
              text: 'Continue with Phone Number',
              onTap: () {
                Navigator.pop(context, true);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // "Maybe Later" fallback
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context, false);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Maybe Later',
                style: AppTypography.bodyLarge(color: AppColors.textSecondary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
