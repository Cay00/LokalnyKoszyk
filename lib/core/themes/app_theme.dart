import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  const AppColors._();

  /* <----------- Colors ------------> */
  static const Color leafGreen = Color(0xFF8FB83A);
  static const Color warmBrown = Color(0xFF4A4A42);
  static const Color softSage = Color(0xFFD4EBA0);
  static const Color lightSage = Color(0xFFE8F5C8);

  /// Main Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF1F1F1);
  static const Color primary = Color(0xFFB4DB4A);
  static const Color primaryLight = Color(0xFFC5E56E);
  static const Color accent = Color(0xFFB4DB4A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A18);
  static const Color textSecondary = Color(0xFF4A4A42);
  static const Color textLight = Color(0xFF4A4A42);
  static const Color textOnDark = Color(0xFF1A1A18);
  static const Color border = Color(0xFFE5E5E5);
}

class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'Inter';

  /* <----------- Typography ------------> */
  static const TextStyle header = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle normal = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle tinyCaption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
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
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        selectedIconTheme: IconThemeData(size: 20),
        unselectedIconTheme: IconThemeData(size: 20),
        selectedLabelStyle: AppTypography.caption,
        unselectedLabelStyle: AppTypography.caption,
        showUnselectedLabels: false,
        elevation: 0,
      ),
    );
  }
}
