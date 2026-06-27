enum VisionBackground {
  scandinavianWall,
  oceanView,
  forestCabin,
  sunsetStudio,
  rainWindow,
  modernLoft,
  softClouds,
  walnutWood,
  matteBlack,
  minimalWhite,
  concreteWall,
  stoneWall,
  softGradient,
  customImage,
}

enum VisionBoardStyle {
  classicCork,
  glassInspiration,
  walnutWooden,
  magneticMetal,
  canvasWall,
  floatingGallery,
  scrapbook,
  custom,
}

enum VisionLighting {
  warm,
  neutral,
  cool,
  morning,
  goldenHour,
  sunset,
  evening,
  night,
}

enum VisionWindowScene {
  ocean,
  forest,
  mountains,
  rain,
  snow,
  city,
  garden,
  lake,
  sunrise,
  sunset,
  nightSky,
}

enum VisionLayoutMode {
  freeform,
  grid,
  masonry,
  timeline,
  moodBoard,
  gallery,
  storyboard,
}

enum PinStyle {
  gold,
  silver,
  black,
  wood,
  transparent,
  modernMagnetic,
  luxuryBrass,
  colored,
}

enum StickyNoteStyle {
  classicYellow,
  minimalWhite,
  pastel,
  glass,
  frosted,
  neon,
  handwritten,
  luxuryPaper,
  premiumKraft,
  gradientNotes,
}

enum QuoteStyle {
  elegantFrame,
  minimalCard,
  glassQuote,
  floatingText,
  paperStrip,
  handwrittenNote,
  posterStyle,
  luxuryPlaque,
}

enum ImageFrameStyle {
  noFrame,
  whitePolaroid,
  blackFrame,
  luxuryGold,
  wood,
  glass,
  rounded,
  shadowOnly,
  museumFrame,
}

enum BoardDecoration {
  stringLights,
  miniPlants,
  paperClips,
  pushPins,
  tape,
  ribbons,
  pressedFlowers,
  bookmarks,
  washiTape,
  minimalShelves,
}

enum VisionTheme {
  luxuryOffice,
  modernApartment,
  creativeStudio,
  japaneseZen,
  coastalHouse,
  minimalScandinavian,
  darkPremium,
  coffeeWorkspace,
  mountainCabin,
  natureRetreat,
}

class CardCustomization {
  final double cornerRadius;
  final double shadowIntensity;
  final double opacity;
  final bool glassMode;
  final bool paperMode;
  final bool roundedMode;
  final bool squareMode;
  final double borderThickness;
  final double texture;

  const CardCustomization({
    this.cornerRadius = 12,
    this.shadowIntensity = 0.5,
    this.opacity = 1.0,
    this.glassMode = false,
    this.paperMode = false,
    this.roundedMode = false,
    this.squareMode = false,
    this.borderThickness = 0.5,
    this.texture = 0,
  });

  CardCustomization copyWith({
    double? cornerRadius,
    double? shadowIntensity,
    double? opacity,
    bool? glassMode,
    bool? paperMode,
    bool? roundedMode,
    bool? squareMode,
    double? borderThickness,
    double? texture,
  }) {
    return CardCustomization(
      cornerRadius: cornerRadius ?? this.cornerRadius,
      shadowIntensity: shadowIntensity ?? this.shadowIntensity,
      opacity: opacity ?? this.opacity,
      glassMode: glassMode ?? this.glassMode,
      paperMode: paperMode ?? this.paperMode,
      roundedMode: roundedMode ?? this.roundedMode,
      squareMode: squareMode ?? this.squareMode,
      borderThickness: borderThickness ?? this.borderThickness,
      texture: texture ?? this.texture,
    );
  }

  Map<String, dynamic> toJson() => {
        'cornerRadius': cornerRadius,
        'shadowIntensity': shadowIntensity,
        'opacity': opacity,
        'glassMode': glassMode,
        'paperMode': paperMode,
        'roundedMode': roundedMode,
        'squareMode': squareMode,
        'borderThickness': borderThickness,
        'texture': texture,
      };

  factory CardCustomization.fromJson(Map<String, dynamic> json) => CardCustomization(
        cornerRadius: (json['cornerRadius'] as num?)?.toDouble() ?? 12,
        shadowIntensity: (json['shadowIntensity'] as num?)?.toDouble() ?? 0.5,
        opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
        glassMode: json['glassMode'] is bool ? json['glassMode'] as bool : false,
        paperMode: json['paperMode'] is bool ? json['paperMode'] as bool : false,
        roundedMode: json['roundedMode'] is bool ? json['roundedMode'] as bool : false,
        squareMode: json['squareMode'] is bool ? json['squareMode'] as bool : false,
        borderThickness: (json['borderThickness'] as num?)?.toDouble() ?? 0.5,
        texture: (json['texture'] as num?)?.toDouble() ?? 0,
      );
}

class VisionCustomization {
  final VisionBackground background;
  final VisionBoardStyle boardStyle;
  final VisionLighting lighting;
  final VisionWindowScene windowScene;
  final VisionLayoutMode layoutMode;
  final PinStyle defaultPinStyle;
  final StickyNoteStyle defaultStickyNoteStyle;
  final QuoteStyle defaultQuoteStyle;
  final ImageFrameStyle defaultImageFrame;
  final List<BoardDecoration> decorations;
  final VisionTheme? theme;
  final CardCustomization cardCustomization;
  final double ambientBrightness;

  const VisionCustomization({
    this.background = VisionBackground.scandinavianWall,
    this.boardStyle = VisionBoardStyle.classicCork,
    this.lighting = VisionLighting.warm,
    this.windowScene = VisionWindowScene.ocean,
    this.layoutMode = VisionLayoutMode.freeform,
    this.defaultPinStyle = PinStyle.gold,
    this.defaultStickyNoteStyle = StickyNoteStyle.classicYellow,
    this.defaultQuoteStyle = QuoteStyle.elegantFrame,
    this.defaultImageFrame = ImageFrameStyle.noFrame,
    this.decorations = const [],
    this.theme,
    this.cardCustomization = const CardCustomization(),
    this.ambientBrightness = 0.5,
  });

  VisionCustomization copyWith({
    VisionBackground? background,
    VisionBoardStyle? boardStyle,
    VisionLighting? lighting,
    VisionWindowScene? windowScene,
    VisionLayoutMode? layoutMode,
    PinStyle? defaultPinStyle,
    StickyNoteStyle? defaultStickyNoteStyle,
    QuoteStyle? defaultQuoteStyle,
    ImageFrameStyle? defaultImageFrame,
    List<BoardDecoration>? decorations,
    VisionTheme? theme,
    CardCustomization? cardCustomization,
    double? ambientBrightness,
    bool clearTheme = false,
  }) {
    return VisionCustomization(
      background: background ?? this.background,
      boardStyle: boardStyle ?? this.boardStyle,
      lighting: lighting ?? this.lighting,
      windowScene: windowScene ?? this.windowScene,
      layoutMode: layoutMode ?? this.layoutMode,
      defaultPinStyle: defaultPinStyle ?? this.defaultPinStyle,
      defaultStickyNoteStyle:
          defaultStickyNoteStyle ?? this.defaultStickyNoteStyle,
      defaultQuoteStyle: defaultQuoteStyle ?? this.defaultQuoteStyle,
      defaultImageFrame: defaultImageFrame ?? this.defaultImageFrame,
      decorations: decorations ?? this.decorations,
      theme: clearTheme ? null : (theme ?? this.theme),
      cardCustomization: cardCustomization ?? this.cardCustomization,
      ambientBrightness: ambientBrightness ?? this.ambientBrightness,
    );
  }

  Map<String, dynamic> toJson() => {
        'background': background.name,
        'boardStyle': boardStyle.name,
        'lighting': lighting.name,
        'windowScene': windowScene.name,
        'layoutMode': layoutMode.name,
        'defaultPinStyle': defaultPinStyle.name,
        'defaultStickyNoteStyle': defaultStickyNoteStyle.name,
        'defaultQuoteStyle': defaultQuoteStyle.name,
        'defaultImageFrame': defaultImageFrame.name,
        'decorations': decorations.map((d) => d.name).toList(),
        'theme': theme?.name,
        'cardCustomization': cardCustomization.toJson(),
        'ambientBrightness': ambientBrightness,
      };

  factory VisionCustomization.fromJson(Map<String, dynamic> json) {
    return VisionCustomization(
      background: VisionBackground.values.firstWhere(
        (e) => e.name == json['background'],
        orElse: () => VisionBackground.scandinavianWall,
      ),
      boardStyle: VisionBoardStyle.values.firstWhere(
        (e) => e.name == json['boardStyle'],
        orElse: () => VisionBoardStyle.classicCork,
      ),
      lighting: VisionLighting.values.firstWhere(
        (e) => e.name == json['lighting'],
        orElse: () => VisionLighting.warm,
      ),
      windowScene: VisionWindowScene.values.firstWhere(
        (e) => e.name == json['windowScene'],
        orElse: () => VisionWindowScene.ocean,
      ),
      layoutMode: VisionLayoutMode.values.firstWhere(
        (e) => e.name == json['layoutMode'],
        orElse: () => VisionLayoutMode.freeform,
      ),
      defaultPinStyle: PinStyle.values.firstWhere(
        (e) => e.name == json['defaultPinStyle'],
        orElse: () => PinStyle.gold,
      ),
      defaultStickyNoteStyle: StickyNoteStyle.values.firstWhere(
        (e) => e.name == json['defaultStickyNoteStyle'],
        orElse: () => StickyNoteStyle.classicYellow,
      ),
      defaultQuoteStyle: QuoteStyle.values.firstWhere(
        (e) => e.name == json['defaultQuoteStyle'],
        orElse: () => QuoteStyle.elegantFrame,
      ),
      defaultImageFrame: ImageFrameStyle.values.firstWhere(
        (e) => e.name == json['defaultImageFrame'],
        orElse: () => ImageFrameStyle.noFrame,
      ),
      decorations: (json['decorations'] as List<dynamic>?)
              ?.map((d) => BoardDecoration.values.firstWhere(
                    (e) => e.name == d,
                    orElse: () => BoardDecoration.stringLights,
                  ))
              .toList() ??
          [],
      theme: json['theme'] != null
          ? VisionTheme.values.firstWhere(
              (e) => e.name == json['theme'],
              orElse: () => VisionTheme.darkPremium,
            )
          : null,
      cardCustomization: json['cardCustomization'] != null
          ? CardCustomization.fromJson(
              Map<String, dynamic>.from(json['cardCustomization'] as Map))
          : const CardCustomization(),
      ambientBrightness:
          (json['ambientBrightness'] as num?)?.toDouble() ?? 0.5,
    );
  }
}
