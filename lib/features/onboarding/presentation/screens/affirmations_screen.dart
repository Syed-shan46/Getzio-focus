import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/onboarding_models.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/affirmation_room_background.dart';

class AffirmationsScreen extends ConsumerStatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  ConsumerState<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _CategoryData {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final List<DailyAffirmation> templates;

  const _CategoryData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.templates,
  });
}

class _AffirmationsScreenState extends ConsumerState<AffirmationsScreen> {
  final TextEditingController _customController = TextEditingController();
  late PageController _categoryPageController;
  int _currentCategoryIndex = 0;

  static final List<_CategoryData> _categories = [
    _CategoryData(
      id: 'discipline',
      name: 'Discipline',
      emoji: '🎯',
      color: const Color(0xFF4DA3FF),
      templates: [
        DailyAffirmation(id: 't1', text: 'Discipline creates freedom.', author: 'Focus Core', isPinned: true),
      ],
    ),
    _CategoryData(
      id: 'growth',
      name: 'Growth',
      emoji: '🌱',
      color: const Color(0xFF2CE38C),
      templates: [
        DailyAffirmation(id: 't2', text: 'I am matching my potential daily.', author: 'Focus Core'),
        DailyAffirmation(id: 't4', text: 'Consistency is my key to growth.', author: 'Focus Core'),
        DailyAffirmation(id: 't6', text: 'Today\'s actions build tomorrow\'s identity.', author: 'Focus Core'),
      ],
    ),
    _CategoryData(
      id: 'focus',
      name: 'Focus',
      emoji: '⚡',
      color: const Color(0xFFF59E0B),
      templates: [
        DailyAffirmation(id: 't3', text: 'Focus is my superpower.', author: 'Focus Core'),
      ],
    ),
    _CategoryData(
      id: 'mindset',
      name: 'Mindset',
      emoji: '🧠',
      color: const Color(0xFFA78BFA),
      templates: [
        DailyAffirmation(id: 't5', text: 'I choose consistency over convenience.', author: 'Focus Core'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _categoryPageController = PageController();
  }

  @override
  void dispose() {
    _customController.dispose();
    _categoryPageController.dispose();
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

  void _toggleTemplate(DailyAffirmation template) {
    final selected = ref.read(onboardingProvider).selectedAffirmations;
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
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final selected = onboardingState.selectedAffirmations;

    return Stack(
      children: [
        const Positioned.fill(
          child: AffirmationRoomBackground(child: SizedBox.expand()),
        ),

        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _categoryPageController,
                          onPageChanged: (index) {
                            setState(() => _currentCategoryIndex = index);
                          },
                          itemCount: _categories.length,
                          itemBuilder: (context, catIndex) {
                            final cat = _categories[catIndex];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _GlassCard(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                                            const SizedBox(width: 8),
                                            Text(
                                              cat.name.toUpperCase(),
                                              style: AppTypography.captionSmall(color: cat.color).copyWith(
                                                letterSpacing: 1.5,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              '${cat.templates.length} affirmation${cat.templates.length == 1 ? '' : 's'}',
                                              style: AppTypography.captionSmall(
                                                color: Colors.white.withValues(alpha: 0.35),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        ...cat.templates.map((template) {
                                          final isSelected = selected.any((a) => a.text == template.text);
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: _AffirmationItem(
                                              text: template.text,
                                              isSelected: isSelected,
                                              activeColor: cat.color,
                                              onTap: () => _toggleTemplate(template),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      _buildDots(),

                      const SizedBox(height: 8),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CREATE CUSTOM',
                                style: AppTypography.captionSmall(color: AppColors.accentBlue).copyWith(
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
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
                      ),

                      if (selected.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _GlassCard(
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
                                const SizedBox(height: 10),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: selected.length,
                                  itemBuilder: (context, idx) {
                                    final aff = selected[idx];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 6),
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
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_categories.length, (i) {
        final isActive = i == _currentCategoryIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive
                ? _categories[i].color.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _AffirmationItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _AffirmationItem({
    required this.text,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.06),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.12),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 18,
              color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
