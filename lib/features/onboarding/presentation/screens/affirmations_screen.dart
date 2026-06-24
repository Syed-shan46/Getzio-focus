import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/onboarding_models.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/premium_chip.dart';
import '../widgets/affirmation_room_background.dart';

/// Screen 8 — Daily Affirmations with premium room background
class AffirmationsScreen extends ConsumerStatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  ConsumerState<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends ConsumerState<AffirmationsScreen> {
  final TextEditingController _customController = TextEditingController();

  static final List<DailyAffirmation> _templates = [
    DailyAffirmation(id: 't1', text: 'Discipline creates freedom.', author: 'Focus Core', isPinned: true),
    DailyAffirmation(id: 't2', text: 'I am matching my potential daily.', author: 'Focus Core'),
    DailyAffirmation(id: 't3', text: 'Focus is my superpower.', author: 'Focus Core'),
    DailyAffirmation(id: 't4', text: 'Consistency is my key to growth.', author: 'Focus Core'),
    DailyAffirmation(id: 't5', text: 'I choose consistency over convenience.', author: 'Focus Core'),
    DailyAffirmation(id: 't6', text: 'Today\'s actions build tomorrow\'s identity.', author: 'Focus Core'),
  ];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _addCustomAffirmation() {
    final text = _customController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.mediumImpact();
    final newAff = DailyAffirmation(
      id: const Uuid().v4(),
      text: text,
      author: 'Self',
    );

    ref.read(onboardingProvider.notifier).toggleAffirmation(newAff);

    final selected = ref.read(onboardingProvider).selectedAffirmations;
    if (!selected.any((a) => a.isPinned)) {
      ref.read(onboardingProvider.notifier).setPinnedAffirmation(newAff.id);
    }

    _customController.clear();
  }

  void _pinAffirmation(String id) {
    HapticFeedback.mediumImpact();
    ref.read(onboardingProvider.notifier).setPinnedAffirmation(id);
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final selected = onboardingState.selectedAffirmations;

    return Stack(
      children: [
        // ── Room Background ──
        const Positioned.fill(
          child: AffirmationRoomBackground(child: SizedBox.expand()),
        ),

        // ── Content ──
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Glass Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily\nAffirmations.',
                          style: AppTypography.displayLarge(color: Colors.white).copyWith(
                            fontSize: 34,
                            height: 1.12,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Select affirmations that inspire you. Pin one to display in the main wall frame of your living workspace.',
                          style: AppTypography.bodyMedium(
                            color: Colors.white.withValues(alpha: 0.5),
                          ).copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Scrollable Content ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Templates Section ──
                        _GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AFFIRMATION TEMPLATES',
                                style: AppTypography.captionSmall(color: AppColors.accentBlue).copyWith(
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _templates.map((template) {
                                  final isSelected = selected.any((a) => a.text == template.text);
                                  return PremiumChip(
                                    emoji: '✨',
                                    title: template.text,
                                    isSelected: isSelected,
                                    onTap: () {
                                      final existingIndex = selected.indexWhere((a) => a.text == template.text);
                                      if (existingIndex >= 0) {
                                        final wasPinned = selected[existingIndex].isPinned;
                                        ref.read(onboardingProvider.notifier).toggleAffirmation(selected[existingIndex]);
                                        if (wasPinned) {
                                          final remaining = ref.read(onboardingProvider).selectedAffirmations;
                                          if (remaining.isNotEmpty) {
                                            ref.read(onboardingProvider.notifier).setPinnedAffirmation(remaining.first.id);
                                          }
                                        }
                                      } else {
                                        ref.read(onboardingProvider.notifier).toggleAffirmation(template);
                                        final current = ref.read(onboardingProvider).selectedAffirmations;
                                        if (!current.any((a) => a.isPinned)) {
                                          ref.read(onboardingProvider.notifier).setPinnedAffirmation(template.id);
                                        }
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ── Custom Input Section ──
                        _GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CREATE CUSTOM AFFIRMATION',
                                style: AppTypography.captionSmall(color: AppColors.accentBlue).copyWith(
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                      ),
                                      child: TextField(
                                        controller: _customController,
                                        style: const TextStyle(color: Colors.white, fontSize: 14),
                                        cursorColor: AppColors.accentBlue,
                                        decoration: const InputDecoration(
                                          hintText: 'Type your custom affirmation...',
                                          hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                                          border: InputBorder.none,
                                        ),
                                        onSubmitted: (_) => _addCustomAffirmation(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle, color: AppColors.accentBlue, size: 36),
                                    onPressed: _addCustomAffirmation,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ── Pinned Selection Section ──
                        if (selected.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PIN TO WORKSPACE',
                                  style: AppTypography.captionSmall(color: AppColors.accentBlue).copyWith(
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: selected.length,
                                  itemBuilder: (context, idx) {
                                    final aff = selected[idx];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.04),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: aff.isPinned
                                              ? AppColors.accentBlue.withValues(alpha: 0.3)
                                              : Colors.white.withValues(alpha: 0.06),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            aff.isPinned ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                            color: aff.isPinned ? AppColors.accentBlue : Colors.white24,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              aff.text,
                                              style: const TextStyle(color: Colors.white, fontSize: 13),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => _pinAffirmation(aff.id),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: aff.isPinned
                                                    ? AppColors.accentBlue.withValues(alpha: 0.15)
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: aff.isPinned ? AppColors.accentBlue : Colors.white.withValues(alpha: 0.15),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    aff.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                                    color: aff.isPinned ? AppColors.accentBlue : Colors.white70,
                                                    size: 11,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    aff.isPinned ? 'Pinned' : 'Pin',
                                                    style: TextStyle(
                                                      color: aff.isPinned ? AppColors.accentBlue : Colors.white70,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A frosted glass card overlay for the affirmation room background.
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
