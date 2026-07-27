import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/vision_customization.dart';
import '../providers/customization_provider.dart';

class VisionCustomizationSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => const _CustomizationSheetContent(),
    );
  }
}

class _CustomizationSheetContent extends ConsumerStatefulWidget {
  const _CustomizationSheetContent();

  @override
  ConsumerState<_CustomizationSheetContent> createState() =>
      _CustomizationSheetContentState();
}

class _CustomizationSheetContentState
    extends ConsumerState<_CustomizationSheetContent> {
  late PageController _pageController;
  int _currentSection = 0;

  final List<_SectionInfo> _sections = [
    _SectionInfo('Themes', Icons.palette_rounded),
    _SectionInfo('Board Style', Icons.grid_view_rounded),
    _SectionInfo('Cards', Icons.style_rounded),
    _SectionInfo('Pins', Icons.push_pin_rounded),
    _SectionInfo('Sticky Notes', Icons.sticky_note_2_rounded),
    _SectionInfo('Quotes', Icons.format_quote_rounded),
    _SectionInfo('Frames', Icons.image_rounded),
    _SectionInfo('Window', Icons.window_rounded),
    _SectionInfo('Decorations', Icons.auto_awesome_rounded),
    _SectionInfo('Layout', Icons.dashboard_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0A0F1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(
                top: BorderSide(color: Colors.white10, width: 1),
              ),
            ),
            child: Stack(
              children: [
                // Hidden scroll view to attach the draggable scroll controller to avoid "not attached" exception
                Positioned(
                  left: 0,
                  top: 0,
                  width: 0,
                  height: 0,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: const SizedBox(height: 10),
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    children: [
                      _buildHandle(),
                      _buildSectionNav(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (i) {
                            setState(() => _currentSection = i);
                          },
                          children: [
                            _buildThemesPage(),
                            _buildBoardStylePage(),
                            _buildCardCustomizationPage(),
                            _buildPinsPage(),
                            _buildStickyNotesPage(),
                            _buildQuotesPage(),
                            _buildFramesPage(),
                            _buildWindowPage(),
                            _buildDecorationsPage(),
                            _buildLayoutPage(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Center(
        child: Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionNav() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _sections.length,
        separatorBuilder: (_, _) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final section = _sections[index];
          final isSelected = _currentSection == index;
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.accentBlue.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? context.colors.accentBlue.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    section.icon,
                    size: 18,
                    color: isSelected
                        ? context.colors.accentBlue
                        : Colors.white54,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    section.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return TextButton.icon(
      onPressed: () {
        ref.read(visionCustomizationProvider.notifier).resetToDefaults();
      },
      icon: const Icon(Icons.refresh_rounded, size: 16),
      label: const Text('Reset', style: TextStyle(fontSize: 12)),
      style: TextButton.styleFrom(foregroundColor: Colors.white38),
    );
  }

  // ─── THEMES ─────────────────────────────────────────────────────────────

  Widget _buildThemesPage() {
    final currentTheme = ref.watch(visionCustomizationProvider).theme;
    return SingleChildScrollView(
      controller: ScrollController(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Themes'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Instantly transform your entire Vision Room',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: VisionTheme.values.map((theme) {
                final isSelected = currentTheme == theme;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(visionCustomizationProvider.notifier)
                        .setTheme(theme);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.accentBlue.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.accentBlue
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Text(
                      _themeLabel(theme),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Center(child: _buildResetButton()),
        ],
      ),
    );
  }

  String _themeLabel(VisionTheme theme) {
    return switch (theme) {
      VisionTheme.luxuryOffice => 'Luxury Office',
      VisionTheme.modernApartment => 'Modern Apartment',
      VisionTheme.creativeStudio => 'Creative Studio',
      VisionTheme.japaneseZen => 'Japanese Zen',
      VisionTheme.coastalHouse => 'Coastal House',
      VisionTheme.minimalScandinavian => 'Minimal Scandinavian',
      VisionTheme.darkPremium => 'Midnight Gold',
      VisionTheme.coffeeWorkspace => 'Coffee Workspace',
      VisionTheme.mountainCabin => 'Mountain Cabin',
      VisionTheme.natureRetreat => 'Nature Retreat',
    };
  }

  // ─── BACKGROUND ─────────────────────────────────────────────────────────

  Widget _buildBackgroundPage() {
    final currentBg = ref.watch(visionCustomizationProvider).background;
    return SingleChildScrollView(
      controller: ScrollController(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Background'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: VisionBackground.values.length,
              itemBuilder: (context, index) {
                final bg = VisionBackground.values[index];
                final isSelected = currentBg == bg;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(visionCustomizationProvider.notifier)
                        .setBackground(bg);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.accentBlue
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: context.colors.accentBlue
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                              )
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          _buildBgPreview(bg),
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: context.colors.accentBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                              child: Text(
                                _bgLabel(bg),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBgPreview(VisionBackground bg) {
    return Container(
      decoration: BoxDecoration(
        gradient: _bgGradient(bg),
      ),
      child: Center(
        child: Icon(
          _bgIcon(bg),
          color: Colors.white.withValues(alpha: 0.3),
          size: 32,
        ),
      ),
    );
  }

  IconData _bgIcon(VisionBackground bg) {
    return switch (bg) {
      VisionBackground.scandinavianWall => Icons.home_rounded,
      VisionBackground.oceanView => Icons.water_rounded,
      VisionBackground.forestCabin => Icons.forest_rounded,
      VisionBackground.sunsetStudio => Icons.wb_sunny_rounded,
      VisionBackground.rainWindow => Icons.water_drop_rounded,
      VisionBackground.modernLoft => Icons.apartment_rounded,
      VisionBackground.softClouds => Icons.cloud_rounded,
      VisionBackground.walnutWood => Icons.park_rounded,
      VisionBackground.matteBlack => Icons.dark_mode_rounded,
      VisionBackground.minimalWhite => Icons.light_mode_rounded,
      VisionBackground.concreteWall => Icons.business_rounded,
      VisionBackground.stoneWall => Icons.terrain_rounded,
      VisionBackground.softGradient => Icons.blur_on_rounded,
      VisionBackground.customImage => Icons.image_rounded,
    };
  }

  LinearGradient _bgGradient(VisionBackground bg) {
    return switch (bg) {
      VisionBackground.scandinavianWall => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F0E8), Color(0xFFE8E0D0)],
        ),
      VisionBackground.oceanView => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F4C75), Color(0xFF1A7BA0)],
        ),
      VisionBackground.forestCabin => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
        ),
      VisionBackground.sunsetStudio => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B6B), Color(0xFFFFA751)],
        ),
      VisionBackground.rainWindow => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A5568), Color(0xFF718096)],
        ),
      VisionBackground.modernLoft => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
        ),
      VisionBackground.softClouds => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB0C4DE), Color(0xFFE0E8F0)],
        ),
      VisionBackground.walnutWood => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5C4033), Color(0xFF8B6914)],
        ),
      VisionBackground.matteBlack => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      VisionBackground.minimalWhite => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
        ),
      VisionBackground.concreteWall => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
        ),
      VisionBackground.stoneWall => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF78716C), Color(0xFFA8A29E)],
        ),
      VisionBackground.softGradient => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      VisionBackground.customImage => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF374151), Color(0xFF4B5563)],
        ),
    };
  }

  String _bgLabel(VisionBackground bg) {
    return switch (bg) {
      VisionBackground.scandinavianWall => 'Scandinavian',
      VisionBackground.oceanView => 'Ocean View',
      VisionBackground.forestCabin => 'Forest Cabin',
      VisionBackground.sunsetStudio => 'Sunset Studio',
      VisionBackground.rainWindow => 'Rain Window',
      VisionBackground.modernLoft => 'Modern Loft',
      VisionBackground.softClouds => 'Soft Clouds',
      VisionBackground.walnutWood => 'Walnut Wood',
      VisionBackground.matteBlack => 'Matte Black',
      VisionBackground.minimalWhite => 'Minimal White',
      VisionBackground.concreteWall => 'Concrete',
      VisionBackground.stoneWall => 'Stone Wall',
      VisionBackground.softGradient => 'Soft Gradient',
      VisionBackground.customImage => 'Custom Image',
    };
  }

  // ─── BOARD STYLE ────────────────────────────────────────────────────────

  Widget _buildBoardStylePage() {
    final currentStyle =
        ref.watch(visionCustomizationProvider).boardStyle;
    return SingleChildScrollView(
      controller: ScrollController(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Board Style'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Choose how your vision board looks and feels',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: VisionBoardStyle.values.map((style) {
                final isSelected = currentStyle == style;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(visionCustomizationProvider.notifier)
                          .setBoardStyle(style);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colors.accentBlue.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? context.colors.accentBlue.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.colors.accentBlue.withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _boardStyleIcon(style),
                              color: isSelected
                                  ? context.colors.accentBlue
                                  : Colors.white54,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _boardStyleLabel(style),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _boardStyleDesc(style),
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: context.colors.accentBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded,
                                  size: 16, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _boardStyleIcon(VisionBoardStyle style) {
    return switch (style) {
      VisionBoardStyle.classicCork => Icons.push_pin_rounded,
      VisionBoardStyle.glassInspiration => Icons.gradient_rounded,
      VisionBoardStyle.walnutWooden => Icons.park_rounded,
      VisionBoardStyle.magneticMetal => Icons.square_rounded,
      VisionBoardStyle.canvasWall => Icons.brush_rounded,
      VisionBoardStyle.floatingGallery => Icons.view_carousel_rounded,
      VisionBoardStyle.scrapbook => Icons.collections_bookmark_rounded,
      VisionBoardStyle.custom => Icons.tune_rounded,
    };
  }

  String _boardStyleLabel(VisionBoardStyle style) {
    return switch (style) {
      VisionBoardStyle.classicCork => 'Classic Cork Board',
      VisionBoardStyle.glassInspiration => 'Glass Inspiration Board',
      VisionBoardStyle.walnutWooden => 'Walnut Wooden Board',
      VisionBoardStyle.magneticMetal => 'Magnetic Metal Board',
      VisionBoardStyle.canvasWall => 'Canvas Wall',
      VisionBoardStyle.floatingGallery => 'Floating Gallery',
      VisionBoardStyle.scrapbook => 'Scrapbook Style',
      VisionBoardStyle.custom => 'Custom',
    };
  }

  String _boardStyleDesc(VisionBoardStyle style) {
    return switch (style) {
      VisionBoardStyle.classicCork => 'Real cork texture, wood frame, natural pins',
      VisionBoardStyle.glassInspiration => 'Frosted glass, transparent notes, modern office',
      VisionBoardStyle.walnutWooden => 'Luxury walnut finish, warm lighting, brass pins',
      VisionBoardStyle.magneticMetal => 'Minimal matte metal, magnetic cards, industrial',
      VisionBoardStyle.canvasWall => 'Dream images pinned on soft canvas texture',
      VisionBoardStyle.floatingGallery => 'Cards float on blurred gallery wall, museum aesthetic',
      VisionBoardStyle.scrapbook => 'Layered papers, polaroids, tape, handcrafted feeling',
      VisionBoardStyle.custom => 'Design your own board style',
    };
  }

  // ─── LIGHTING ───────────────────────────────────────────────────────────

  Widget _buildLightingPage() {
    final cust = ref.watch(visionCustomizationProvider);
    return SingleChildScrollView(
      controller: ScrollController(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Lighting'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Set the mood and atmosphere',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: VisionLighting.values.map((lighting) {
                final isSelected = cust.lighting == lighting;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(visionCustomizationProvider.notifier)
                        .setLighting(lighting);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _lightingColor(lighting).withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? _lightingColor(lighting)
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _lightingIcon(lighting),
                          size: 16,
                          color: isSelected
                              ? _lightingColor(lighting)
                              : Colors.white54,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _lightingLabel(lighting),
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white : Colors.white70,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ambient Brightness',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: context.colors.accentBlue,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                    thumbColor: context.colors.accentBlue,
                    overlayColor:
                        context.colors.accentBlue.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: cust.ambientBrightness,
                    onChanged: (v) {
                      ref
                          .read(visionCustomizationProvider.notifier)
                          .setAmbientBrightness(v);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _lightingColor(VisionLighting lighting) {
    return switch (lighting) {
      VisionLighting.warm => const Color(0xFFFFB347),
      VisionLighting.neutral => const Color(0xFFE8E0D0),
      VisionLighting.cool => const Color(0xFF89CFF0),
      VisionLighting.morning => const Color(0xFFFFC194),
      VisionLighting.goldenHour => const Color(0xFFFF8C42),
      VisionLighting.sunset => const Color(0xFFFF6B6B),
      VisionLighting.evening => const Color(0xFF6C5B7B),
      VisionLighting.night => const Color(0xFF1A1A40),
    };
  }

  IconData _lightingIcon(VisionLighting lighting) {
    return switch (lighting) {
      VisionLighting.warm => Icons.whatshot_rounded,
      VisionLighting.neutral => Icons.light_mode_rounded,
      VisionLighting.cool => Icons.ac_unit_rounded,
      VisionLighting.morning => Icons.wb_sunny_rounded,
      VisionLighting.goldenHour => Icons.wb_twilight_rounded,
      VisionLighting.sunset => Icons.wb_twilight_rounded,
      VisionLighting.evening => Icons.bedtime_rounded,
      VisionLighting.night => Icons.nightlight_round_rounded,
    };
  }

  String _lightingLabel(VisionLighting lighting) {
    return switch (lighting) {
      VisionLighting.warm => 'Warm',
      VisionLighting.neutral => 'Neutral',
      VisionLighting.cool => 'Cool',
      VisionLighting.morning => 'Morning',
      VisionLighting.goldenHour => 'Golden Hour',
      VisionLighting.sunset => 'Sunset',
      VisionLighting.evening => 'Evening',
      VisionLighting.night => 'Night',
    };
  }

  // ─── WINDOW ─────────────────────────────────────────────────────────────

  Widget _buildWindowPage() {
    final currentScene =
        ref.watch(visionCustomizationProvider).windowScene;
    return SingleChildScrollView(
      controller: ScrollController(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Window Scene'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Change the view outside your window',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          // Live preview of the selected scene
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  children: [
                    // Sky gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: _windowSkyGradient(currentScene),
                      ),
                    ),
                    // Celestial body
                    Positioned(
                      top: 8,
                      right: 16,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentScene == VisionWindowScene.nightSky
                              ? const Color(0xFFF0F0F0)
                              : const Color(0xFFFFF8E1),
                          boxShadow: [
                            BoxShadow(
                              color: currentScene == VisionWindowScene.nightSky
                                  ? const Color(0xFFE0E0FF).withValues(alpha: 0.4)
                                  : const Color(0xFFFFD700).withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Ground/treeline silhouette
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 30,
                      child: CustomPaint(
                        painter: _PreviewGroundPainter(scene: currentScene),
                      ),
                    ),
                    // Glass reflection
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.12),
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.06),
                              ],
                              stops: const [0.0, 0.4, 0.7],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: VisionWindowScene.values.map((scene) {
                final isSelected = currentScene == scene;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(visionCustomizationProvider.notifier)
                        .setWindowScene(scene);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.accentBlue.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.accentBlue
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Text(
                      _windowSceneLabel(scene),
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _windowSkyGradient(VisionWindowScene scene) {
    return switch (scene) {
      VisionWindowScene.ocean => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF87CEEB), Color(0xFF1E90FF), Color(0xFF006994)],
      ),
      VisionWindowScene.forest => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF87CEEB), Color(0xFF228B22), Color(0xFF006400)],
      ),
      VisionWindowScene.mountains => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF4A90D9), Color(0xFF6B8E23), Color(0xFF556B2F)],
      ),
      VisionWindowScene.rain => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF4A5568), Color(0xFF6B7280), Color(0xFF374151)],
      ),
      VisionWindowScene.snow => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFFE8F0F8), Color(0xFFD6E4F0), Color(0xFFB0C4DE)],
      ),
      VisionWindowScene.city => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF2C3E50), Color(0xFF34495E), Color(0xFF1A252F)],
      ),
      VisionWindowScene.garden => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF87CEEB), Color(0xFF98FB98), Color(0xFF3CB371)],
      ),
      VisionWindowScene.lake => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF89CFF0), Color(0xFF2E86C1), Color(0xFF1B4F72)],
      ),
      VisionWindowScene.sunrise => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFFFF8C42), Color(0xFFFFB347), Color(0xFFFFD699)],
      ),
      VisionWindowScene.sunset => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFFFF4500), Color(0xFFFF6B6B), Color(0xFF8B0000)],
      ),
      VisionWindowScene.nightSky => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF0F0F2E), Color(0xFF1A1A4E), Color(0xFF0B0B1A)],
      ),
      VisionWindowScene.desert => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFFFF8C42), Color(0xFFE8B85A), Color(0xFFD4A050)],
      ),
      VisionWindowScene.aurora => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF0A0A2E), Color(0xFF1A3A4A), Color(0xFF0B2E1A)],
      ),
      VisionWindowScene.waterfall => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF6BB8E8), Color(0xFF3A9AD9), Color(0xFF1A6B3A)],
      ),
      VisionWindowScene.meadow => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF89CFF0), Color(0xFF7DD17D), Color(0xFF4A9A4A)],
      ),
      VisionWindowScene.canyon => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFFE07040), Color(0xFFC08050), Color(0xFF8B5A2B)],
      ),
      VisionWindowScene.village => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF87CEEB), Color(0xFF98D8C8), Color(0xFF6B8E6B)],
      ),
      VisionWindowScene.space => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF000011), Color(0xFF0B0B2E), Color(0xFF1A0B2E)],
      ),
      VisionWindowScene.tropical => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF0288D1)],
      ),
    };
  }

  String _windowSceneLabel(VisionWindowScene scene) {
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

  // ─── CARD CUSTOMIZATION ─────────────────────────────────────────────────

  Widget _buildCardCustomizationPage() {
    final cardCfg = ref.watch(visionCustomizationProvider).cardCustomization;
    return SingleChildScrollView(
      controller: ScrollController(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Card Style'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Customize how cards appear on your board',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          _buildSliderControl(
            label: 'Corner Radius',
            value: cardCfg.cornerRadius,
            min: 0,
            max: 40,
            onChanged: (v) {
              ref
                  .read(visionCustomizationProvider.notifier)
                  .updateCardCustomization(
                    cardCfg.copyWith(cornerRadius: v),
                  );
            },
          ),
          _buildSliderControl(
            label: 'Shadow Intensity',
            value: cardCfg.shadowIntensity,
            min: 0,
            max: 1,
            onChanged: (v) {
              ref
                  .read(visionCustomizationProvider.notifier)
                  .updateCardCustomization(
                    cardCfg.copyWith(shadowIntensity: v),
                  );
            },
          ),
          _buildSliderControl(
            label: 'Opacity',
            value: cardCfg.opacity,
            min: 0.1,
            max: 1,
            onChanged: (v) {
              ref
                  .read(visionCustomizationProvider.notifier)
                  .updateCardCustomization(
                    cardCfg.copyWith(opacity: v),
                  );
            },
          ),
          _buildSliderControl(
            label: 'Border Thickness',
            value: cardCfg.borderThickness,
            min: 0,
            max: 3,
            onChanged: (v) {
              ref
                  .read(visionCustomizationProvider.notifier)
                  .updateCardCustomization(
                    cardCfg.copyWith(borderThickness: v),
                  );
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildToggleChip('Glass Mode', cardCfg.glassMode, () {
                  ref
                      .read(visionCustomizationProvider.notifier)
                      .updateCardCustomization(
                        cardCfg.copyWith(
                          glassMode: !cardCfg.glassMode,
                          paperMode: false,
                        ),
                      );
                }),
                _buildToggleChip('Paper Mode', cardCfg.paperMode, () {
                  ref
                      .read(visionCustomizationProvider.notifier)
                      .updateCardCustomization(
                        cardCfg.copyWith(
                          paperMode: !cardCfg.paperMode,
                          glassMode: false,
                        ),
                      );
                }),
                _buildToggleChip('Rounded', cardCfg.roundedMode, () {
                  ref
                      .read(visionCustomizationProvider.notifier)
                      .updateCardCustomization(
                        cardCfg.copyWith(
                          roundedMode: !cardCfg.roundedMode,
                          squareMode: false,
                        ),
                      );
                }),
                _buildToggleChip('Square', cardCfg.squareMode, () {
                  ref
                      .read(visionCustomizationProvider.notifier)
                      .updateCardCustomization(
                        cardCfg.copyWith(
                          squareMode: !cardCfg.squareMode,
                          roundedMode: false,
                        ),
                      );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderControl({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                    color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: context.colors.accentBlue,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: context.colors.accentBlue,
              overlayColor:
                  context.colors.accentBlue.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? context.colors.accentBlue.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? context.colors.accentBlue.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ─── PINS ───────────────────────────────────────────────────────────────

  Widget _buildPinsPage() {
    final currentPin =
        ref.watch(visionCustomizationProvider).defaultPinStyle;
    return SingleChildScrollView(
      controller: ScrollController(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Pin Style'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Choose your default pin style for new items',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: PinStyle.values.map((pin) {
                final isSelected = currentPin == pin;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(visionCustomizationProvider.notifier)
                        .setDefaultPinStyle(pin);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.accentBlue.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.accentBlue
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Text(
                      _pinLabel(pin),
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _pinLabel(PinStyle pin) {
    return switch (pin) {
      PinStyle.gold => 'Gold',
      PinStyle.silver => 'Silver',
      PinStyle.black => 'Black',
      PinStyle.wood => 'Wood',
      PinStyle.transparent => 'Transparent',
      PinStyle.modernMagnetic => 'Magnetic',
      PinStyle.luxuryBrass => 'Luxury Brass',
      PinStyle.colored => 'Colored',
    };
  }

  // ─── STICKY NOTES ───────────────────────────────────────────────────────

  Widget _buildStickyNotesPage() {
    final currentStyle =
        ref.watch(visionCustomizationProvider).defaultStickyNoteStyle;
    return SingleChildScrollView(
      controller: ScrollController(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Sticky Note Style'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Default style for new sticky notes',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: StickyNoteStyle.values.map((style) {
                final isSelected = currentStyle == style;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(visionCustomizationProvider.notifier)
                        .setDefaultStickyNoteStyle(style);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.accentBlue.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.accentBlue
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Text(
                      _stickyNoteLabel(style),
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _stickyNoteLabel(StickyNoteStyle style) {
    return switch (style) {
      StickyNoteStyle.classicYellow => 'Classic Yellow',
      StickyNoteStyle.minimalWhite => 'Minimal White',
      StickyNoteStyle.pastel => 'Pastel',
      StickyNoteStyle.glass => 'Glass',
      StickyNoteStyle.frosted => 'Frosted',
      StickyNoteStyle.neon => 'Neon',
      StickyNoteStyle.handwritten => 'Handwritten',
      StickyNoteStyle.luxuryPaper => 'Luxury Paper',
      StickyNoteStyle.premiumKraft => 'Classic Kraft',
      StickyNoteStyle.gradientNotes => 'Gradient Notes',
    };
  }

  // ─── QUOTES ─────────────────────────────────────────────────────────────

  Widget _buildQuotesPage() {
    final currentStyle =
        ref.watch(visionCustomizationProvider).defaultQuoteStyle;
    return SingleChildScrollView(
      controller: ScrollController(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Quote Style'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Default presentation style for quotes',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: QuoteStyle.values.map((style) {
                final isSelected = currentStyle == style;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(visionCustomizationProvider.notifier)
                        .setDefaultQuoteStyle(style);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.accentBlue.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.accentBlue
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Text(
                      _quoteLabel(style),
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _quoteLabel(QuoteStyle style) {
    return switch (style) {
      QuoteStyle.elegantFrame => 'Elegant Frame',
      QuoteStyle.minimalCard => 'Minimal Card',
      QuoteStyle.glassQuote => 'Glass Quote',
      QuoteStyle.floatingText => 'Floating Text',
      QuoteStyle.paperStrip => 'Paper Strip',
      QuoteStyle.handwrittenNote => 'Handwritten Note',
      QuoteStyle.posterStyle => 'Poster Style',
      QuoteStyle.luxuryPlaque => 'Luxury Plaque',
    };
  }

  // ─── IMAGE FRAMES ──────────────────────────────────────────────────────

  Widget _buildFramesPage() {
    final currentFrame =
        ref.watch(visionCustomizationProvider).defaultImageFrame;
    return SingleChildScrollView(
      controller: ScrollController(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Image Frames'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Choose how images are framed on your board',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ImageFrameStyle.values.map((frame) {
                final isSelected = currentFrame == frame;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(visionCustomizationProvider.notifier)
                        .setDefaultImageFrame(frame);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.accentBlue.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.accentBlue
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Text(
                      _frameLabel(frame),
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _frameLabel(ImageFrameStyle frame) {
    return switch (frame) {
      ImageFrameStyle.noFrame => 'No Frame',
      ImageFrameStyle.whitePolaroid => 'White Polaroid',
      ImageFrameStyle.blackFrame => 'Black Frame',
      ImageFrameStyle.luxuryGold => 'Luxury Gold',
      ImageFrameStyle.wood => 'Wood',
      ImageFrameStyle.glass => 'Glass',
      ImageFrameStyle.rounded => 'Rounded',
      ImageFrameStyle.shadowOnly => 'Shadow Only',
      ImageFrameStyle.museumFrame => 'Museum Frame',
    };
  }

  // ─── DECORATIONS ───────────────────────────────────────────────────────

  Widget _buildDecorationsPage() {
    final decorations =
        ref.watch(visionCustomizationProvider).decorations;
    return SingleChildScrollView(
      controller: ScrollController(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Board Decorations'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Add small decorative elements to your board',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: BoardDecoration.values.map((decoration) {
                final isActive = decorations.contains(decoration);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(visionCustomizationProvider.notifier)
                          .toggleDecoration(decoration);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isActive
                            ? context.colors.accentBlue.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isActive
                              ? context.colors.accentBlue
                                  .withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _decorationIcon(decoration),
                            size: 20,
                            color: isActive
                                ? context.colors.accentBlue
                                : Colors.white38,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _decorationLabel(decoration),
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : Colors.white54,
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? context.colors.accentBlue
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isActive
                                    ? context.colors.accentBlue
                                    : Colors.white24,
                                width: 2,
                              ),
                            ),
                            child: isActive
                                ? const Icon(Icons.check_rounded,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _decorationIcon(BoardDecoration decoration) {
    return switch (decoration) {
      BoardDecoration.stringLights => Icons.emoji_events_rounded,
      BoardDecoration.miniPlants => Icons.eco_rounded,
      BoardDecoration.paperClips => Icons.attach_file_rounded,
      BoardDecoration.pushPins => Icons.push_pin_rounded,
      BoardDecoration.tape => Icons.horizontal_rule_rounded,
      BoardDecoration.ribbons => Icons.redeem_rounded,
      BoardDecoration.pressedFlowers => Icons.local_florist_rounded,
      BoardDecoration.bookmarks => Icons.bookmark_rounded,
      BoardDecoration.washiTape => Icons.auto_awesome_rounded,
      BoardDecoration.minimalShelves => Icons.menu_rounded,
    };
  }

  String _decorationLabel(BoardDecoration decoration) {
    return switch (decoration) {
      BoardDecoration.stringLights => 'String Lights',
      BoardDecoration.miniPlants => 'Mini Plants',
      BoardDecoration.paperClips => 'Paper Clips',
      BoardDecoration.pushPins => 'Push Pins',
      BoardDecoration.tape => 'Tape',
      BoardDecoration.ribbons => 'Ribbons',
      BoardDecoration.pressedFlowers => 'Pressed Flowers',
      BoardDecoration.bookmarks => 'Bookmarks',
      BoardDecoration.washiTape => 'Washi Tape',
      BoardDecoration.minimalShelves => 'Minimal Shelves',
    };
  }

  // ─── LAYOUT ─────────────────────────────────────────────────────────────

  Widget _buildLayoutPage() {
    final currentLayout =
        ref.watch(visionCustomizationProvider).layoutMode;
    return SingleChildScrollView(
      controller: ScrollController(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Layout Mode'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Choose how items are arranged on your board',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: VisionLayoutMode.values.map((mode) {
                final isSelected = currentLayout == mode;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(visionCustomizationProvider.notifier)
                          .setLayoutMode(mode);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colors.accentBlue.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? context.colors.accentBlue.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.colors.accentBlue
                                      .withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _layoutIcon(mode),
                              color: isSelected
                                  ? context.colors.accentBlue
                                  : Colors.white54,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _layoutLabel(mode),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _layoutDesc(mode),
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: context.colors.accentBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded,
                                  size: 16, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _layoutIcon(VisionLayoutMode mode) {
    return switch (mode) {
      VisionLayoutMode.freeform => Icons.drag_indicator_rounded,
      VisionLayoutMode.grid => Icons.grid_view_rounded,
      VisionLayoutMode.masonry => Icons.window_rounded,
      VisionLayoutMode.timeline => Icons.timeline_rounded,
      VisionLayoutMode.moodBoard => Icons.auto_awesome_mosaic_rounded,
      VisionLayoutMode.gallery => Icons.view_carousel_rounded,
      VisionLayoutMode.storyboard => Icons.view_column_rounded,
    };
  }

  String _layoutLabel(VisionLayoutMode mode) {
    return switch (mode) {
      VisionLayoutMode.freeform => 'Freeform',
      VisionLayoutMode.grid => 'Grid',
      VisionLayoutMode.masonry => 'Masonry',
      VisionLayoutMode.timeline => 'Timeline',
      VisionLayoutMode.moodBoard => 'Mood Board',
      VisionLayoutMode.gallery => 'Gallery',
      VisionLayoutMode.storyboard => 'Storyboard',
    };
  }

  String _layoutDesc(VisionLayoutMode mode) {
    return switch (mode) {
      VisionLayoutMode.freeform => 'Place items anywhere, freely arrange',
      VisionLayoutMode.grid => 'Items snap to an even grid',
      VisionLayoutMode.masonry => 'Pinterest-style staggered layout',
      VisionLayoutMode.timeline => 'Items arranged chronologically',
      VisionLayoutMode.moodBoard => 'Themed sections for curated collections',
      VisionLayoutMode.gallery => 'Cards displayed in a horizontal carousel',
      VisionLayoutMode.storyboard => 'Sequential frame-by-frame layout',
    };
  }
}

class _SectionInfo {
  final String label;
  final IconData icon;

  const _SectionInfo(this.label, this.icon);
}

class _PreviewGroundPainter extends CustomPainter {
  final VisionWindowScene scene;

  _PreviewGroundPainter({required this.scene});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    switch (scene) {
      case VisionWindowScene.city:
      case VisionWindowScene.nightSky:
        paint.color = const Color(0xFF1A252F).withValues(alpha: 0.7);
        final buildings = [0.0, 0.12, 0.28, 0.45, 0.6, 0.78, 0.88];
        for (final bx in buildings) {
          final bh = 10.0 + (bx * 17) % 15;
          canvas.drawRect(Rect.fromLTWH(bx * size.width, size.height - bh, 12, bh), paint);
        }
        break;
      case VisionWindowScene.space:
        paint.color = const Color(0xFF1A1A3A).withValues(alpha: 0.8);
        final path = Path()
          ..moveTo(0, size.height)
          ..lineTo(0, size.height - 4)
          ..lineTo(size.width * 0.2, size.height - 6)
          ..lineTo(size.width * 0.4, size.height - 3)
          ..lineTo(size.width * 0.6, size.height - 7)
          ..lineTo(size.width * 0.8, size.height - 4)
          ..lineTo(size.width, size.height - 5)
          ..lineTo(size.width, size.height)
          ..close();
        canvas.drawPath(path, paint);
        paint.color = Colors.white.withValues(alpha: 0.15);
        for (int i = 0; i < 3; i++) {
          canvas.drawCircle(Offset(size.width * (0.15 + i * 0.3), size.height * (0.2 + i * 0.15)), 1, paint);
        }
        break;
      case VisionWindowScene.desert:
        paint.color = const Color(0xFFD4A050).withValues(alpha: 0.6);
        final dPath = Path()
          ..moveTo(0, size.height)
          ..lineTo(0, size.height - 8)
          ..quadraticBezierTo(size.width * 0.2, size.height - 18, size.width * 0.35, size.height - 6)
          ..quadraticBezierTo(size.width * 0.5, size.height - 2, size.width * 0.65, size.height - 10)
          ..quadraticBezierTo(size.width * 0.8, size.height - 20, size.width, size.height - 5)
          ..lineTo(size.width, size.height)
          ..close();
        canvas.drawPath(dPath, paint);
        paint.color = const Color(0xFF2D5A1E).withValues(alpha: 0.4);
        canvas.drawCircle(Offset(size.width * 0.2, size.height - 10), 3, paint);
        canvas.drawCircle(Offset(size.width * 0.75, size.height - 12), 2.5, paint);
        break;
      case VisionWindowScene.aurora:
        paint.color = const Color(0xFF0A2E1A).withValues(alpha: 0.7);
        final aPath = Path()
          ..moveTo(0, size.height)
          ..lineTo(0, size.height - 6)
          ..lineTo(size.width * 0.3, size.height - 8)
          ..lineTo(size.width * 0.5, size.height - 4)
          ..lineTo(size.width * 0.7, size.height - 9)
          ..lineTo(size.width, size.height - 5)
          ..lineTo(size.width, size.height)
          ..close();
        canvas.drawPath(aPath, paint);
        break;
      case VisionWindowScene.waterfall:
        paint.color = const Color(0xFF1A5A3A).withValues(alpha: 0.7);
        final wPath = Path()
          ..moveTo(0, size.height)
          ..lineTo(0, size.height - 5)
          ..lineTo(size.width * 0.25, size.height - 7)
          ..lineTo(size.width * 0.35, size.height - 20)
          ..lineTo(size.width * 0.4, size.height - 22)
          ..lineTo(size.width * 0.45, size.height - 20)
          ..lineTo(size.width * 0.55, size.height - 8)
          ..lineTo(size.width * 0.7, size.height - 6)
          ..lineTo(size.width, size.height - 4)
          ..lineTo(size.width, size.height)
          ..close();
        canvas.drawPath(wPath, paint);
        paint.color = Colors.white.withValues(alpha: 0.3);
        canvas.drawRect(Rect.fromLTWH(size.width * 0.38, size.height * 0.3, 4, size.height * 0.7), paint);
        break;
      case VisionWindowScene.canyon:
        paint.color = const Color(0xFF8B5A2B).withValues(alpha: 0.7);
        final cPath = Path()
          ..moveTo(0, size.height)
          ..lineTo(0, size.height - 12)
          ..lineTo(size.width * 0.15, size.height - 18)
          ..lineTo(size.width * 0.25, size.height - 8)
          ..lineTo(size.width * 0.4, size.height - 25)
          ..lineTo(size.width * 0.5, size.height - 22)
          ..lineTo(size.width * 0.6, size.height - 26)
          ..lineTo(size.width * 0.75, size.height - 10)
          ..lineTo(size.width * 0.85, size.height - 16)
          ..lineTo(size.width, size.height - 8)
          ..lineTo(size.width, size.height)
          ..close();
        canvas.drawPath(cPath, paint);
        break;
      case VisionWindowScene.village:
        paint.color = const Color(0xFF4A7A4A).withValues(alpha: 0.7);
        final vPath = Path()
          ..moveTo(0, size.height)
          ..lineTo(0, size.height - 8)
          ..lineTo(size.width * 0.2, size.height - 10)
          ..lineTo(size.width * 0.28, size.height - 18)
          ..lineTo(size.width * 0.36, size.height - 10)
          ..lineTo(size.width * 0.5, size.height - 12)
          ..lineTo(size.width * 0.58, size.height - 16)
          ..lineTo(size.width * 0.66, size.height - 10)
          ..lineTo(size.width * 0.8, size.height - 8)
          ..lineTo(size.width, size.height - 6)
          ..lineTo(size.width, size.height)
          ..close();
        canvas.drawPath(vPath, paint);
        paint.color = const Color(0xFFFFD700).withValues(alpha: 0.3);
        canvas.drawCircle(Offset(size.width * 0.3, size.height - 16), 1.5, paint);
        canvas.drawCircle(Offset(size.width * 0.55, size.height - 14), 1.5, paint);
        break;
      case VisionWindowScene.tropical:
        paint.color = const Color(0xFF1A6B3A).withValues(alpha: 0.7);
        final tPath = Path()
          ..moveTo(0, size.height)
          ..lineTo(0, size.height - 8)
          ..lineTo(size.width * 0.2, size.height - 12)
          ..lineTo(size.width * 0.3, size.height - 6)
          ..lineTo(size.width * 0.5, size.height - 14)
          ..lineTo(size.width * 0.65, size.height - 5)
          ..lineTo(size.width * 0.8, size.height - 10)
          ..lineTo(size.width, size.height - 6)
          ..lineTo(size.width, size.height)
          ..close();
        canvas.drawPath(tPath, paint);
        paint.color = const Color(0xFF2D8A4E).withValues(alpha: 0.5);
        canvas.drawCircle(Offset(size.width * 0.25, size.height - 10), 4, paint);
        canvas.drawCircle(Offset(size.width * 0.7, size.height - 8), 3.5, paint);
        break;
      case VisionWindowScene.meadow:
        paint.color = const Color(0xFF3A8A3A).withValues(alpha: 0.7);
        final mPath = Path()
          ..moveTo(0, size.height)
          ..lineTo(0, size.height - 6)
          ..quadraticBezierTo(size.width * 0.2, size.height - 14, size.width * 0.35, size.height - 5)
          ..quadraticBezierTo(size.width * 0.5, size.height - 3, size.width * 0.65, size.height - 8)
          ..quadraticBezierTo(size.width * 0.8, size.height - 16, size.width, size.height - 4)
          ..lineTo(size.width, size.height)
          ..close();
        canvas.drawPath(mPath, paint);
        break;
      default:
        paint.color = const Color(0xFF2D5A1E).withValues(alpha: 0.6);
        final defPath = Path()
          ..moveTo(0, size.height)
          ..lineTo(0, size.height - 6)
          ..lineTo(size.width * 0.3, size.height - 8)
          ..lineTo(size.width * 0.5, size.height - 4)
          ..lineTo(size.width * 0.7, size.height - 9)
          ..lineTo(size.width, size.height - 5)
          ..lineTo(size.width, size.height)
          ..close();
        canvas.drawPath(defPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PreviewGroundPainter old) => old.scene != scene;
}
