import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Persistent bottom navigation bar for the onboarding flow.
/// Shows Back button, animated progress indicator, and Continue button.
class OnboardingBottomBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool canContinue;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final bool showBack;
  final String? continueLabel;

  const OnboardingBottomBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.canContinue,
    required this.onBack,
    required this.onContinue,
    this.showBack = true,
    this.continueLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress Indicator
              _buildProgressIndicator(),
              const SizedBox(height: 16),

              // Navigation Row
              Row(
                children: [
                  // Back Button
                  if (showBack)
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white54,
                          size: 20,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),

                  const SizedBox(width: 12),

                  // Continue Button
                  Expanded(
                    child: GestureDetector(
                      onTap: canContinue ? onContinue : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        height: 48,
                        decoration: BoxDecoration(
                          color: canContinue
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: canContinue
                              ? [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    blurRadius: 16,
                                    spreadRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          continueLabel ?? 'Continue',
                          style: AppTypography.titleMedium(
                            color: canContinue
                                ? Colors.black
                                : Colors.white.withValues(alpha: 0.2),
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.accentBlue
                  : isCurrent
                      ? AppColors.accentBlue.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
