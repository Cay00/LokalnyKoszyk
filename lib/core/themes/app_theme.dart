import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  const AppColors._();

  /* <----------- Colors ------------> */
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF1F1F1);
  static const Color accent = Color(0xFFB4DB4A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A18);
  static const Color textSecondary = Color(0xFF4A4A42);
}

class AppTypography {
  const AppTypography._();

  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  /* <----------- Typography ------------> */
  static TextStyle get header => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get normal => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get normalBold => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get tinyCaption => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

class AppRadius {
  const AppRadius._();

  /* <----------- Radius ------------> */
  static const double sm = 8;
  static const double md = 12;
  static const double normal = 16;
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final TextTheme interTextTheme = GoogleFonts.interTextTheme();

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.accent,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      colorScheme: colorScheme.copyWith(
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      canvasColor: AppColors.background,
      textTheme: interTextTheme.copyWith(
        titleMedium: AppTypography.header,
        bodyMedium: AppTypography.normal,
        labelMedium: AppTypography.caption,
        labelSmall: AppTypography.tinyCaption,
      ),
      primaryTextTheme: interTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTypography.header,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTypography.header,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        selectedIconTheme: const IconThemeData(size: 20),
        unselectedIconTheme: const IconThemeData(size: 20),
        selectedLabelStyle: AppTypography.caption,
        unselectedLabelStyle: AppTypography.caption,
        showUnselectedLabels: false,
        elevation: 0,
      ),
    );
  }
}
