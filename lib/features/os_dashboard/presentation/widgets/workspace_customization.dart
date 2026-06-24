import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/os_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/screens/phone_login_screen.dart';

class WorkspaceCustomizationSheet extends ConsumerWidget {
  const WorkspaceCustomizationSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WorkspaceCustomizationSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(osStateProvider);
    final notifier = ref.read(osStateProvider.notifier);
    final authState = ref.watch(authProvider);
    final user = authState.value;

    // Lists of options
    final woodStyles = ['Walnut', 'Oak', 'Mahogany'];
    final wallColors = ['Deep Indigo', 'Classic Navy', 'Charcoal', 'Emerald', 'Warm Terracotta'];
    final plantTypes = ['Bonsai', 'Snake Plant', 'Monstera', 'Peace Lily'];
    final ambientModes = ['Auto', 'Morning', 'Afternoon', 'Evening', 'Night'];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: BoxDecoration(
          color: const Color(0xFF070A13).withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 16, bottom: 20),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workspace Settings',
                        style: AppTypography.displayMedium(color: Colors.white).copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tailor your personal growth environment.',
                        style: AppTypography.caption(color: Colors.white54),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white60),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10, height: 1),

            // Settings list
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  // 1. Wall Theme Color
                  _buildSectionHeader('Backdrop Wall Color'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: wallColors.length,
                      itemBuilder: (context, idx) {
                        final val = wallColors[idx];
                        final isSelected = state.wallColor == val;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(val),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                HapticFeedback.selectionClick();
                                notifier.updateWorkspaceSettings(wallColor: val);
                              }
                            },
                            selectedColor: AppColors.accentBlue.withValues(alpha: 0.25),
                            backgroundColor: Colors.white.withValues(alpha: 0.03),
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.accentBlue : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? AppColors.accentBlue : Colors.white12,
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Shelf Wood Type
                  _buildSectionHeader('Wood Plank Craftsmanship'),
                  const SizedBox(height: 10),
                  Row(
                    children: woodStyles.map((val) {
                      final isSelected = state.woodTexture == val;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              notifier.updateWorkspaceSettings(woodTexture: val);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? AppColors.accentBlue : Colors.white12,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      gradient: _getWoodPreviewGradient(val),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    val,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white60,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 3. Living Plant Type
                  _buildSectionHeader('Discipline Plant Bonsai'),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: plantTypes.length,
                    itemBuilder: (context, idx) {
                      final val = plantTypes[idx];
                      final isSelected = state.plantType == val;
                      return InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          notifier.updateWorkspaceSettings(plantType: val);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.white.withValues(alpha: 0.01),
                            border: Border.all(
                              color: isSelected ? AppColors.accentEmerald : Colors.white.withValues(alpha: 0.05),
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.eco_rounded,
                                color: isSelected ? AppColors.accentEmerald : Colors.white30,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  val,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // 4. Ambient Time Mode
                  _buildSectionHeader('Room Lighting (Ambient)'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ambientModes.length,
                      itemBuilder: (context, idx) {
                        final val = ambientModes[idx];
                        final isSelected = state.ambientMode == val;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(val),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                HapticFeedback.selectionClick();
                                notifier.updateWorkspaceSettings(ambientMode: val);
                              }
                            },
                            selectedColor: Colors.amberAccent.withValues(alpha: 0.2),
                            backgroundColor: Colors.white.withValues(alpha: 0.03),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.amberAccent : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? Colors.amberAccent.withValues(alpha: 0.5) : Colors.white12,
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Rain Mode Toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ambient Rain Overlay',
                                style: AppTypography.bodyLarge(color: Colors.white).copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Gentle rain streaks slide down your window',
                                style: AppTypography.caption(color: Colors.white30),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: state.rainMode,
                          activeColor: AppColors.accentBlue,
                          onChanged: (val) {
                            HapticFeedback.mediumImpact();
                            notifier.updateWorkspaceSettings(rainMode: val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. Cloud Sync & Backup
                  _buildSectionHeader('Cloud Sync & Backup'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user == null ? 'Cloud Backup & Sync' : 'Cloud Sync Connected',
                                style: AppTypography.bodyLarge(color: Colors.white).copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user == null
                                    ? 'Back up your habits, goals & settings online.'
                                    : 'Your workspace is secured to ${user.mobile}',
                                style: AppTypography.caption(color: Colors.white30),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (user == null)
                          ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              // Close sheet first
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              'Sign In',
                              style: AppTypography.captionSmall(color: Colors.black).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          TextButton(
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              await ref.read(authProvider.notifier).logout();
                            },
                            child: Text(
                              'Log Out',
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.white30,
        letterSpacing: 1.5,
      ),
    );
  }

  LinearGradient _getWoodPreviewGradient(String style) {
    switch (style) {
      case 'Oak':
        return const LinearGradient(colors: [Color(0xFFD7CCC8), Color(0xFF8D6E63)]);
      case 'Mahogany':
        return const LinearGradient(colors: [Color(0xFF8D6E63), Color(0xFF3E2723)]);
      case 'Walnut':
      default:
        return const LinearGradient(colors: [Color(0xFF5D4037), Color(0xFF2D1510)]);
    }
  }
}
