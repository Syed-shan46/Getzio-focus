import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/models/vision_customization.dart';

class VisionCustomizationNotifier extends StateNotifier<VisionCustomization> {
  final HiveDatabase _hiveDb;

  VisionCustomizationNotifier(this._hiveDb)
      : super(const VisionCustomization()) {
    _load();
  }

  void _load() {
    final data = _hiveDb.getVisionCustomization();
    if (data != null) {
      state = VisionCustomization.fromJson(
        Map<String, dynamic>.from(data),
      );
    }
  }

  void _save() {
    _hiveDb.saveVisionCustomization(state.toJson());
  }

  void setBackground(VisionBackground bg) {
    state = state.copyWith(background: bg, clearTheme: true);
    _save();
  }

  void setBoardStyle(VisionBoardStyle style) {
    state = state.copyWith(boardStyle: style, clearTheme: true);
    _save();
  }

  void setLighting(VisionLighting lighting) {
    state = state.copyWith(lighting: lighting, clearTheme: true);
    _save();
  }

  void setWindowScene(VisionWindowScene scene) {
    state = state.copyWith(windowScene: scene, clearTheme: true);
    _save();
  }

  void setLayoutMode(VisionLayoutMode mode) {
    state = state.copyWith(layoutMode: mode);
    _save();
  }

  void setDefaultPinStyle(PinStyle style) {
    state = state.copyWith(defaultPinStyle: style);
    _save();
  }

  void setDefaultStickyNoteStyle(StickyNoteStyle style) {
    state = state.copyWith(defaultStickyNoteStyle: style);
    _save();
  }

  void setDefaultQuoteStyle(QuoteStyle style) {
    state = state.copyWith(defaultQuoteStyle: style);
    _save();
  }

  void setDefaultImageFrame(ImageFrameStyle style) {
    state = state.copyWith(defaultImageFrame: style);
    _save();
  }

  void toggleDecoration(BoardDecoration decoration) {
    final decorations = List<BoardDecoration>.from(state.decorations);
    if (decorations.contains(decoration)) {
      decorations.remove(decoration);
    } else {
      decorations.add(decoration);
    }
    state = state.copyWith(decorations: decorations);
    _save();
  }

  void setTheme(VisionTheme theme) {
    final themeConfig = _themeConfigs[theme]!;
    state = VisionCustomization(
      background: themeConfig.background,
      boardStyle: themeConfig.boardStyle,
      lighting: themeConfig.lighting,
      windowScene: themeConfig.windowScene,
      layoutMode: state.layoutMode,
      defaultPinStyle: themeConfig.pinStyle,
      defaultStickyNoteStyle: themeConfig.stickyNoteStyle,
      defaultQuoteStyle: themeConfig.quoteStyle,
      defaultImageFrame: themeConfig.imageFrame,
      decorations: themeConfig.decorations,
      theme: theme,
      cardCustomization: themeConfig.cardCustomization,
      ambientBrightness: themeConfig.ambientBrightness,
    );
    _save();
  }

  void updateCardCustomization(CardCustomization cardCfg) {
    state = state.copyWith(cardCustomization: cardCfg);
    _save();
  }

  void setAmbientBrightness(double value) {
    state = state.copyWith(ambientBrightness: value);
    _save();
  }

  void resetToDefaults() {
    state = const VisionCustomization();
    _save();
  }
}

final visionCustomizationProvider =
    StateNotifierProvider<VisionCustomizationNotifier, VisionCustomization>(
        (ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  return VisionCustomizationNotifier(hiveDb);
});

class _ThemeConfig {
  final VisionBackground background;
  final VisionBoardStyle boardStyle;
  final VisionLighting lighting;
  final VisionWindowScene windowScene;
  final PinStyle pinStyle;
  final StickyNoteStyle stickyNoteStyle;
  final QuoteStyle quoteStyle;
  final ImageFrameStyle imageFrame;
  final List<BoardDecoration> decorations;
  final CardCustomization cardCustomization;
  final double ambientBrightness;

  const _ThemeConfig({
    required this.background,
    required this.boardStyle,
    required this.lighting,
    required this.windowScene,
    this.pinStyle = PinStyle.gold,
    this.stickyNoteStyle = StickyNoteStyle.classicYellow,
    this.quoteStyle = QuoteStyle.elegantFrame,
    this.imageFrame = ImageFrameStyle.noFrame,
    this.decorations = const [],
    this.cardCustomization = const CardCustomization(),
    this.ambientBrightness = 0.5,
  });
}

final Map<VisionTheme, _ThemeConfig> _themeConfigs = {
  VisionTheme.luxuryOffice: _ThemeConfig(
    background: VisionBackground.modernLoft,
    boardStyle: VisionBoardStyle.walnutWooden,
    lighting: VisionLighting.goldenHour,
    windowScene: VisionWindowScene.city,
    pinStyle: PinStyle.luxuryBrass,
    stickyNoteStyle: StickyNoteStyle.luxuryPaper,
    quoteStyle: QuoteStyle.luxuryPlaque,
    imageFrame: ImageFrameStyle.luxuryGold,
    decorations: [BoardDecoration.miniPlants, BoardDecoration.bookmarks],
    cardCustomization: CardCustomization(
      cornerRadius: 8,
      shadowIntensity: 0.7,
      borderThickness: 1.0,
    ),
    ambientBrightness: 0.6,
  ),
  VisionTheme.modernApartment: _ThemeConfig(
    background: VisionBackground.softClouds,
    boardStyle: VisionBoardStyle.glassInspiration,
    lighting: VisionLighting.neutral,
    windowScene: VisionWindowScene.city,
    pinStyle: PinStyle.silver,
    stickyNoteStyle: StickyNoteStyle.glass,
    quoteStyle: QuoteStyle.glassQuote,
    imageFrame: ImageFrameStyle.glass,
    decorations: [BoardDecoration.miniPlants],
    cardCustomization: CardCustomization(
      cornerRadius: 16,
      shadowIntensity: 0.3,
      glassMode: true,
    ),
    ambientBrightness: 0.7,
  ),
  VisionTheme.creativeStudio: _ThemeConfig(
    background: VisionBackground.sunsetStudio,
    boardStyle: VisionBoardStyle.canvasWall,
    lighting: VisionLighting.morning,
    windowScene: VisionWindowScene.sunrise,
    pinStyle: PinStyle.colored,
    stickyNoteStyle: StickyNoteStyle.pastel,
    quoteStyle: QuoteStyle.posterStyle,
    imageFrame: ImageFrameStyle.whitePolaroid,
    decorations: [
      BoardDecoration.stringLights,
      BoardDecoration.washiTape,
      BoardDecoration.pushPins,
    ],
    cardCustomization: CardCustomization(
      cornerRadius: 4,
      shadowIntensity: 0.6,
      paperMode: true,
    ),
    ambientBrightness: 0.8,
  ),
  VisionTheme.japaneseZen: _ThemeConfig(
    background: VisionBackground.forestCabin,
    boardStyle: VisionBoardStyle.canvasWall,
    lighting: VisionLighting.morning,
    windowScene: VisionWindowScene.forest,
    pinStyle: PinStyle.wood,
    stickyNoteStyle: StickyNoteStyle.premiumKraft,
    quoteStyle: QuoteStyle.handwrittenNote,
    imageFrame: ImageFrameStyle.wood,
    decorations: [BoardDecoration.pressedFlowers, BoardDecoration.miniPlants],
    cardCustomization: CardCustomization(
      cornerRadius: 2,
      shadowIntensity: 0.2,
      texture: 0.3,
    ),
    ambientBrightness: 0.6,
  ),
  VisionTheme.coastalHouse: _ThemeConfig(
    background: VisionBackground.oceanView,
    boardStyle: VisionBoardStyle.floatingGallery,
    lighting: VisionLighting.morning,
    windowScene: VisionWindowScene.ocean,
    pinStyle: PinStyle.transparent,
    stickyNoteStyle: StickyNoteStyle.minimalWhite,
    quoteStyle: QuoteStyle.floatingText,
    imageFrame: ImageFrameStyle.shadowOnly,
    decorations: [BoardDecoration.washiTape, BoardDecoration.pressedFlowers],
    cardCustomization: CardCustomization(
      cornerRadius: 20,
      shadowIntensity: 0.4,
      glassMode: true,
    ),
    ambientBrightness: 0.8,
  ),
  VisionTheme.minimalScandinavian: _ThemeConfig(
    background: VisionBackground.scandinavianWall,
    boardStyle: VisionBoardStyle.floatingGallery,
    lighting: VisionLighting.neutral,
    windowScene: VisionWindowScene.lake,
    pinStyle: PinStyle.silver,
    stickyNoteStyle: StickyNoteStyle.minimalWhite,
    quoteStyle: QuoteStyle.minimalCard,
    imageFrame: ImageFrameStyle.noFrame,
    decorations: [BoardDecoration.miniPlants],
    cardCustomization: CardCustomization(
      cornerRadius: 4,
      shadowIntensity: 0.2,
      borderThickness: 0,
    ),
    ambientBrightness: 0.9,
  ),
  VisionTheme.darkPremium: _ThemeConfig(
    background: VisionBackground.matteBlack,
    boardStyle: VisionBoardStyle.magneticMetal,
    lighting: VisionLighting.night,
    windowScene: VisionWindowScene.nightSky,
    pinStyle: PinStyle.black,
    stickyNoteStyle: StickyNoteStyle.neon,
    quoteStyle: QuoteStyle.elegantFrame,
    imageFrame: ImageFrameStyle.blackFrame,
    decorations: [],
    cardCustomization: CardCustomization(
      cornerRadius: 8,
      shadowIntensity: 0.8,
      borderThickness: 1.5,
    ),
    ambientBrightness: 0.3,
  ),
  VisionTheme.coffeeWorkspace: _ThemeConfig(
    background: VisionBackground.walnutWood,
    boardStyle: VisionBoardStyle.classicCork,
    lighting: VisionLighting.warm,
    windowScene: VisionWindowScene.rain,
    pinStyle: PinStyle.wood,
    stickyNoteStyle: StickyNoteStyle.premiumKraft,
    quoteStyle: QuoteStyle.paperStrip,
    imageFrame: ImageFrameStyle.wood,
    decorations: [
      BoardDecoration.stringLights,
      BoardDecoration.miniPlants,
      BoardDecoration.bookmarks,
    ],
    cardCustomization: CardCustomization(
      cornerRadius: 2,
      shadowIntensity: 0.5,
      paperMode: true,
    ),
    ambientBrightness: 0.5,
  ),
  VisionTheme.mountainCabin: _ThemeConfig(
    background: VisionBackground.forestCabin,
    boardStyle: VisionBoardStyle.walnutWooden,
    lighting: VisionLighting.morning,
    windowScene: VisionWindowScene.mountains,
    pinStyle: PinStyle.wood,
    stickyNoteStyle: StickyNoteStyle.classicYellow,
    quoteStyle: QuoteStyle.handwrittenNote,
    imageFrame: ImageFrameStyle.wood,
    decorations: [BoardDecoration.stringLights, BoardDecoration.miniPlants],
    cardCustomization: CardCustomization(
      cornerRadius: 6,
      shadowIntensity: 0.5,
      texture: 0.2,
    ),
    ambientBrightness: 0.6,
  ),
  VisionTheme.natureRetreat: _ThemeConfig(
    background: VisionBackground.oceanView,
    boardStyle: VisionBoardStyle.canvasWall,
    lighting: VisionLighting.goldenHour,
    windowScene: VisionWindowScene.garden,
    pinStyle: PinStyle.wood,
    stickyNoteStyle: StickyNoteStyle.pastel,
    quoteStyle: QuoteStyle.paperStrip,
    imageFrame: ImageFrameStyle.shadowOnly,
    decorations: [
      BoardDecoration.pressedFlowers,
      BoardDecoration.ribbons,
      BoardDecoration.stringLights,
    ],
    cardCustomization: CardCustomization(
      cornerRadius: 12,
      shadowIntensity: 0.4,
      texture: 0.1,
    ),
    ambientBrightness: 0.7,
  ),
};

final lightOnProvider = StateProvider<bool>((ref) => true);


