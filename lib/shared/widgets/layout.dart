import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'buttons.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? context.colors.bg1,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.displayMedium(color: context.colors.textPrimary),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle!,
                  style: AppTypography.bodyMedium(color: context.colors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class AppSection extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const AppSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.titleLarge(color: context.colors.textPrimary),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.message,
    this.subtitle,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: context.colors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.titleMedium(color: context.colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppTypography.bodyMedium(color: context.colors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                text: actionLabel!,
                onPressed: onAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(context.colors.accentBlue),
      ),
    );
  }
}

class AppError extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const AppError({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              error,
              style: AppTypography.bodyLarge(color: context.colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
