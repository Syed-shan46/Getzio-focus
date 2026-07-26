import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS EXTENSION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color bg1;
  final Color bg2;
  final Color bg3;
  final Color accentBlue;
  final Color accentEmerald;
  final Color glass;
  final Color glassBorder;
  final Color glassHover;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color error;
  final Color warning;
  final Color darkOverlay;

  const AppColorsExtension({
    required this.bg1,
    required this.bg2,
    required this.bg3,
    required this.accentBlue,
    required this.accentEmerald,
    required this.glass,
    required this.glassBorder,
    required this.glassHover,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.error,
    required this.warning,
    required this.darkOverlay,
  });

  @override
  AppColorsExtension copyWith({
    Color? bg1,
    Color? bg2,
    Color? bg3,
    Color? accentBlue,
    Color? accentEmerald,
    Color? glass,
    Color? glassBorder,
    Color? glassHover,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? error,
    Color? warning,
    Color? darkOverlay,
  }) {
    return AppColorsExtension(
      bg1: bg1 ?? this.bg1,
      bg2: bg2 ?? this.bg2,
      bg3: bg3 ?? this.bg3,
      accentBlue: accentBlue ?? this.accentBlue,
      accentEmerald: accentEmerald ?? this.accentEmerald,
      glass: glass ?? this.glass,
      glassBorder: glassBorder ?? this.glassBorder,
      glassHover: glassHover ?? this.glassHover,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      darkOverlay: darkOverlay ?? this.darkOverlay,
    );
  }

  @override
  AppColorsExtension lerp(covariant ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      bg1: Color.lerp(bg1, other.bg1, t)!,
      bg2: Color.lerp(bg2, other.bg2, t)!,
      bg3: Color.lerp(bg3, other.bg3, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      accentEmerald: Color.lerp(accentEmerald, other.accentEmerald, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassHover: Color.lerp(glassHover, other.glassHover, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      darkOverlay: Color.lerp(darkOverlay, other.darkOverlay, t)!,
    );
  }
}

extension AppThemeContextExtension on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS — Palettes
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppColors {
  AppColors._();

  static const dark = AppColorsExtension(
    bg1: Color(0xFF050816),
    bg2: Color(0xFF071423),
    bg3: Color(0xFF000000),
    accentBlue: Color(0xFF4DA3FF),
    accentEmerald: Color(0xFF2CE38C),
    glass: Color.fromRGBO(255, 255, 255, 0.08),
    glassBorder: Color.fromRGBO(255, 255, 255, 0.12),
    glassHover: Color.fromRGBO(255, 255, 255, 0.14),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    success: Color(0xFF2CE38C),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    darkOverlay: Color.fromRGBO(0, 0, 0, 0.25),
  );

  static const light = AppColorsExtension(
    bg1: Color(0xFFFAF7F2),
    bg2: Color(0xFFF4ECE1),
    bg3: Color(0xFFFFFFFF),
    accentBlue: Color(0xFF3888FF),
    accentEmerald: Color(0xFF1CB06B),
    glass: Color.fromRGBO(0, 0, 0, 0.04),
    glassBorder: Color.fromRGBO(0, 0, 0, 0.08),
    glassHover: Color.fromRGBO(0, 0, 0, 0.06),
    textPrimary: Color(0xFF2C251C), // Deep brownish black
    textSecondary: Color(0xFF5C4E35), // Medium brown
    textMuted: Color(0xFF8B7355), // Muted brown
    success: Color(0xFF1CB06B),
    error: Color(0xFFD93838),
    warning: Color(0xFFD97706),
    darkOverlay: Color.fromRGBO(0, 0, 0, 0.15),
  );

  static bool _isDarkTheme() {
    try {
      if (Hive.isBoxOpen('todo_personal_settings')) {
        final box = Hive.box('todo_personal_settings');
        final savedMode = box.get('app_theme_mode', defaultValue: 'system') as String;
        if (savedMode == 'dark') return true;
        if (savedMode == 'light') return false;
      }
    } catch (_) {}

    try {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    } catch (_) {}

    return true; // Default to dark theme
  }

  // Backward compatibility aliases (use context.colors instead in widgets!)
  static Color get bg1 => _isDarkTheme() ? dark.bg1 : light.bg1;
  static Color get bg2 => _isDarkTheme() ? dark.bg2 : light.bg2;
  static Color get bg3 => _isDarkTheme() ? dark.bg3 : light.bg3;
  static Color get accentBlue => _isDarkTheme() ? dark.accentBlue : light.accentBlue;
  static Color get accentEmerald => _isDarkTheme() ? dark.accentEmerald : light.accentEmerald;
  static Color get glass => _isDarkTheme() ? dark.glass : light.glass;
  static Color get glassBorder => _isDarkTheme() ? dark.glassBorder : light.glassBorder;
  static Color get glassHover => _isDarkTheme() ? dark.glassHover : light.glassHover;
  static Color get textPrimary => _isDarkTheme() ? dark.textPrimary : light.textPrimary;
  static Color get textSecondary => _isDarkTheme() ? dark.textSecondary : light.textSecondary;
  static Color get textMuted => _isDarkTheme() ? dark.textMuted : light.textMuted;
  static Color get success => _isDarkTheme() ? dark.success : light.success;
  static Color get error => _isDarkTheme() ? dark.error : light.error;
  static Color get warning => _isDarkTheme() ? dark.warning : light.warning;
  static Color get darkOverlay => _isDarkTheme() ? dark.darkOverlay : light.darkOverlay;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SPACING — 8-Point Grid System
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RADIUS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppRadius {
  AppRadius._();

  static const double sm = 12.0;
  static const double md = 20.0;
  static const double lg = 26.0;
  static const double xl = 32.0;
  static const double round = 999.0;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TYPOGRAPHY — Inter
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppTypography {
  AppTypography._();

  static TextStyle _inter({
    required double size,
    required FontWeight weight,
    Color? color,
    double? height,
    double letterSpacing = 0.0,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Large Titles — Bold
  static TextStyle displayLarge({Color? color}) => _inter(
        size: 34,
        weight: FontWeight.w700,
        color: color,
        letterSpacing: -0.8,
        height: 1.15,
      );

  static TextStyle displayMedium({Color? color}) => _inter(
        size: 28,
        weight: FontWeight.w700,
        color: color,
        letterSpacing: -0.6,
        height: 1.2,
      );

  // Section Titles — Semibold
  static TextStyle titleLarge({Color? color}) => _inter(
        size: 22,
        weight: FontWeight.w600,
        color: color,
        letterSpacing: -0.4,
      );

  static TextStyle titleMedium({Color? color}) => _inter(
        size: 17,
        weight: FontWeight.w600,
        color: color,
        letterSpacing: -0.2,
      );

  // Body — Medium
  static TextStyle bodyLarge({Color? color}) => _inter(
        size: 16,
        weight: FontWeight.w500,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyMedium({Color? color}) => _inter(
        size: 14,
        weight: FontWeight.w500,
        color: color ?? AppColors.textSecondary,
        height: 1.5,
      );

  // Captions — Regular
  static TextStyle caption({Color? color}) => _inter(
        size: 13,
        weight: FontWeight.w400,
        color: color ?? AppColors.textMuted,
      );

  static TextStyle captionSmall({Color? color}) => _inter(
        size: 11,
        weight: FontWeight.w500,
        color: color ?? AppColors.textMuted,
        letterSpacing: 0.3,
      );

  // Progress Ring Numbers
  static TextStyle progressNumber({Color? color}) => _inter(
        size: 18,
        weight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle progressLabel({Color? color}) => _inter(
        size: 10,
        weight: FontWeight.w500,
        color: color ?? AppColors.textMuted,
        letterSpacing: 0.5,
      );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GLASS DECORATION HELPERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class GlassDecoration {
  GlassDecoration._();

  static BoxDecoration card({
    BuildContext? context,
    double radius = AppRadius.lg,
  }) {
    final colors = context?.colors ?? AppColors.dark;
    return BoxDecoration(
      color: colors.glass,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: colors.glassBorder, width: 0.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration fab({BuildContext? context}) {
    final colors = context?.colors ?? AppColors.dark;
    return BoxDecoration(
      color: colors.glass,
      shape: BoxShape.circle,
      border: Border.all(color: colors.glassBorder, width: 0.5),
      boxShadow: [
        BoxShadow(
          color: colors.accentBlue.withValues(alpha: 0.3),
          blurRadius: 24,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static const double blurSigma = 22.0;
  static const double backgroundBlurSigma = 20.0;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// THEME
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.dark.bg1,
      primaryColor: AppColors.dark.accentBlue,
      extensions: <ThemeExtension<dynamic>>[AppColors.dark],
      colorScheme: ColorScheme.dark(
        primary: AppColors.dark.accentBlue,
        secondary: AppColors.dark.accentEmerald,
        surface: AppColors.dark.bg2,
        error: AppColors.dark.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge(color: AppColors.dark.textPrimary),
        titleLarge: AppTypography.titleLarge(color: AppColors.dark.textPrimary),
        titleMedium: AppTypography.titleMedium(color: AppColors.dark.textPrimary),
        bodyLarge: AppTypography.bodyLarge(color: AppColors.dark.textPrimary),
        bodyMedium: AppTypography.bodyMedium(color: AppColors.dark.textSecondary),
        labelSmall: AppTypography.caption(color: AppColors.dark.textMuted),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.light.bg1,
      primaryColor: AppColors.light.accentBlue,
      extensions: <ThemeExtension<dynamic>>[AppColors.light],
      colorScheme: ColorScheme.light(
        primary: AppColors.light.accentBlue,
        secondary: AppColors.light.accentEmerald,
        surface: AppColors.light.bg2,
        error: AppColors.light.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF2C251C)),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge(color: AppColors.light.textPrimary),
        titleLarge: AppTypography.titleLarge(color: AppColors.light.textPrimary),
        titleMedium: AppTypography.titleMedium(color: AppColors.light.textPrimary),
        bodyLarge: AppTypography.bodyLarge(color: AppColors.light.textPrimary),
        bodyMedium: AppTypography.bodyMedium(color: AppColors.light.textSecondary),
        labelSmall: AppTypography.caption(color: AppColors.light.textMuted),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHADOWS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = [];
  
  static final List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static final List<BoxShadow> floating = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> popup = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  static final List<BoxShadow> bottomSheet = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BORDERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppBorders {
  AppBorders._();

  static Border thin(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Border.all(
      color: isDark 
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.05),
      width: 1.0,
    );
  }

  static Border medium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Border.all(
      color: isDark 
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.black.withValues(alpha: 0.08),
      width: 1.5,
    );
  }

  static Border thick(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Border.all(
      color: isDark 
          ? Colors.white.withValues(alpha: 0.18)
          : Colors.black.withValues(alpha: 0.12),
      width: 2.0,
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DURATIONS & EASING
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

class AppAnimations {
  AppAnimations._();

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GRADIENTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppGradients {
  AppGradients._();

  static const LinearGradient orangeToPurple = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient cardOverlay = LinearGradient(
    colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static LinearGradient glass(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark 
          ? [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.02)]
          : [Colors.black.withValues(alpha: 0.03), Colors.black.withValues(alpha: 0.01)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ICONS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppIcons {
  AppIcons._();

  static const double small = 16.0;
  static const double medium = 24.0;
  static const double large = 32.0;
}
