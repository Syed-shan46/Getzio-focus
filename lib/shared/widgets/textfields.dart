import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool autofocus;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.autofocus = false,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: AppTypography.bodyLarge(color: context.colors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.bodyLarge(color: context.colors.textMuted),
        filled: true,
        fillColor: isDark 
            ? Colors.white.withValues(alpha: 0.05) 
            : context.colors.textPrimary.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(
            color: context.colors.accentBlue,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
