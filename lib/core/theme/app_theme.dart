import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS — Premium Dark Glassmorphism Palette
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color bg1 = Color(0xFF050816);
  static const Color bg2 = Color(0xFF071423);
  static const Color bg3 = Color(0xFF000000);

  // Accent
  static const Color accentBlue = Color(0xFF4DA3FF);
  static const Color accentEmerald = Color(0xFF2CE38C);

  // Glass
  static const Color glass = Color.fromRGBO(255, 255, 255, 0.08);
  static const Color glassBorder = Color.fromRGBO(255, 255, 255, 0.12);
  static const Color glassHover = Color.fromRGBO(255, 255, 255, 0.14);

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Semantic
  static const Color success = Color(0xFF2CE38C);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Overlay
  static const Color darkOverlay = Color.fromRGBO(0, 0, 0, 0.25);
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
    Color color = AppColors.textPrimary,
    double? height,
    double letterSpacing = 0.0,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Large Titles — Bold
  static TextStyle displayLarge({Color? color}) => _inter(
        size: 34,
        weight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
        letterSpacing: -0.8,
        height: 1.15,
      );

  static TextStyle displayMedium({Color? color}) => _inter(
        size: 28,
        weight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
        letterSpacing: -0.6,
        height: 1.2,
      );

  // Section Titles — Semibold
  static TextStyle titleLarge({Color? color}) => _inter(
        size: 22,
        weight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
        letterSpacing: -0.4,
      );

  static TextStyle titleMedium({Color? color}) => _inter(
        size: 17,
        weight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
        letterSpacing: -0.2,
      );

  // Body — Medium
  static TextStyle bodyLarge({Color? color}) => _inter(
        size: 16,
        weight: FontWeight.w500,
        color: color ?? AppColors.textPrimary,
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
        color: color ?? AppColors.textPrimary,
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

  static BoxDecoration card({double radius = AppRadius.lg}) => BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration fab() => BoxDecoration(
        color: AppColors.glass,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withValues(alpha: 0.3),
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
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: AppColors.accentBlue,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentBlue,
        secondary: AppColors.accentEmerald,
        surface: AppColors.glass,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge(),
        titleLarge: AppTypography.titleLarge(),
        titleMedium: AppTypography.titleMedium(),
        bodyLarge: AppTypography.bodyLarge(),
        bodyMedium: AppTypography.bodyMedium(),
        labelSmall: AppTypography.caption(),
      ),
    );
  }
}
