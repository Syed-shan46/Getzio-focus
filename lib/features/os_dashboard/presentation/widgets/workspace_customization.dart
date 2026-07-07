import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/os_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/screens/phone_login_screen.dart';
import '../../../vision_room/domain/models/vision_customization.dart';
import '../../../vision_room/presentation/providers/customization_provider.dart';

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
    final visionCust = ref.watch(visionCustomizationProvider);

    // Lists of options
    final woodStyles = ['Walnut', 'Oak', 'Mahogany'];
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
                        style: AppTypography.displayMedium(color: Colors.white)
                            .copyWith(
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
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white60,
                    ),
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
                              notifier.updateWorkspaceSettings(
                                woodTexture: val,
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accentBlue
                                      : Colors.white12,
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
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white60,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
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
                                notifier.updateWorkspaceSettings(
                                  ambientMode: val,
                                );
                              }
                            },
                            selectedColor: Colors.amberAccent.withValues(
                              alpha: 0.2,
                            ),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.03,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.amberAccent
                                  : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.amberAccent.withValues(alpha: 0.5)
                                    : Colors.white12,
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

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
                                user == null
                                    ? 'Cloud Backup & Sync'
                                    : 'Cloud Sync Connected',
                                style:
                                    AppTypography.bodyLarge(
                                      color: Colors.white,
                                    ).copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user == null
                                    ? 'Back up your habits, goals & settings online.'
                                    : 'Your workspace is secured to ${user.mobile}',
                                style: AppTypography.caption(
                                  color: Colors.white30,
                                ),
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
                                MaterialPageRoute(
                                  builder: (_) => const PhoneLoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Sign In',
                              style: AppTypography.captionSmall(
                                color: Colors.black,
                              ).copyWith(fontWeight: FontWeight.bold),
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
                              style: TextStyle(
                                color: context.colors.error,
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
        return const LinearGradient(
          colors: [Color(0xFFD7CCC8), Color(0xFF8D6E63)],
        );
      case 'Mahogany':
        return const LinearGradient(
          colors: [Color(0xFF8D6E63), Color(0xFF3E2723)],
        );
      case 'Walnut':
      default:
        return const LinearGradient(
          colors: [Color(0xFF5D4037), Color(0xFF2D1510)],
        );
    }
  }

  LinearGradient _sceneMiniGradient(VisionWindowScene scene) {
    return switch (scene) {
      VisionWindowScene.ocean => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF87CEEB), Color(0xFF1E90FF), Color(0xFF006994)],
      ),
      VisionWindowScene.forest => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF87CEEB), Color(0xFF228B22), Color(0xFF006400)],
      ),
      VisionWindowScene.mountains => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4A90D9), Color(0xFF6B8E23), Color(0xFF556B2F)],
      ),
      VisionWindowScene.rain => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4A5568), Color(0xFF6B7280), Color(0xFF374151)],
      ),
      VisionWindowScene.snow => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE8F0F8), Color(0xFFD6E4F0), Color(0xFFB0C4DE)],
      ),
      VisionWindowScene.city => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2C3E50), Color(0xFF34495E), Color(0xFF1A252F)],
      ),
      VisionWindowScene.garden => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF87CEEB), Color(0xFF98FB98), Color(0xFF3CB371)],
      ),
      VisionWindowScene.lake => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF89CFF0), Color(0xFF2E86C1), Color(0xFF1B4F72)],
      ),
      VisionWindowScene.sunrise => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF8C42), Color(0xFFFFB347), Color(0xFFFFD699)],
      ),
      VisionWindowScene.sunset => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF4500), Color(0xFFFF6B6B), Color(0xFF8B0000)],
      ),
      VisionWindowScene.nightSky => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F0F2E), Color(0xFF1A1A4E), Color(0xFF0B0B1A)],
      ),
      VisionWindowScene.desert => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF8C42), Color(0xFFE8B85A), Color(0xFFD4A050)],
      ),
      VisionWindowScene.aurora => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A0A2E), Color(0xFF1A3A4A), Color(0xFF0B2E1A)],
      ),
      VisionWindowScene.waterfall => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF6BB8E8), Color(0xFF3A9AD9), Color(0xFF1A6B3A)],
      ),
      VisionWindowScene.meadow => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF89CFF0), Color(0xFF7DD17D), Color(0xFF4A9A4A)],
      ),
      VisionWindowScene.canyon => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE07040), Color(0xFFC08050), Color(0xFF8B5A2B)],
      ),
      VisionWindowScene.village => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF87CEEB), Color(0xFF98D8C8), Color(0xFF6B8E6B)],
      ),
      VisionWindowScene.space => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF000011), Color(0xFF0B0B2E), Color(0xFF1A0B2E)],
      ),
      VisionWindowScene.tropical => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF0288D1)],
      ),
    };
  }

  String _sceneLabel(VisionWindowScene scene) {
    return switch (scene) {
      VisionWindowScene.ocean => 'Ocean View',
      VisionWindowScene.forest => 'Forest',
      VisionWindowScene.mountains => 'Mountains',
      VisionWindowScene.rain => 'Rainy Day',
      VisionWindowScene.snow => 'Snowfall',
      VisionWindowScene.city => 'City Skyline',
      VisionWindowScene.garden => 'Garden',
      VisionWindowScene.lake => 'Mountain Lake',
      VisionWindowScene.sunrise => 'Sunrise',
      VisionWindowScene.sunset => 'Sunset',
      VisionWindowScene.nightSky => 'Night Sky',
      VisionWindowScene.desert => 'Desert Dunes',
      VisionWindowScene.aurora => 'Northern Lights',
      VisionWindowScene.waterfall => 'Waterfall',
      VisionWindowScene.meadow => 'Green Meadow',
      VisionWindowScene.canyon => 'Grand Canyon',
      VisionWindowScene.village => 'Cozy Village',
      VisionWindowScene.space => 'Outer Space',
      VisionWindowScene.tropical => 'Tropical Beach',
    };
  }
}
