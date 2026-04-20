import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color cream = Color(0xFFF5F0E8);
  static const Color darkGreen = Color(0xFF1C3A2A);
  static const Color midGreen = Color(0xFF2D5A3D);
  static const Color leafGreen = Color(0xFF4A7C59);
  //static const Color accentGold = Color(0xFFC8923A);
  static const Color warmBrown = Color(0xFF8B5E3C);
  static const Color softSage = Color(0xFFA8C5A0);
  static const Color lightSage = Color(0xFFD4E8CD);
  //static const Color textDark = Color(0xFF1A1A18);
  //static const Color textMid = Color(0xFF4A4A42);
  // static const Color textLight = Color(0xFF7A7A6A);
  static const Color white = Color(0xFFFFFFFF);

  // Aliasy semantyczne do użycia w ThemeData i UI.
  static const Color background = Color(0xFFF5F0E8);
  static const Color primary = Color(0xFF1C3A2A);
  static const Color primaryLight = Color(0xFF2D5A3D);
  static const Color accent = Color(0xFFC8923A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A18);
  static const Color textSecondary = Color(0xFF4A4A42);
  static const Color textLight = Color(0xFF7A7A6A);
  static const Color textOnDark = Color(0xFFC6D8BC);
  static const Color border = lightSage;
}

class AppTypography {
  const AppTypography._();

  static const TextStyle h1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}

class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double normal = 16;
}

class AppSpacing {
  const AppSpacing._();

  //static const double xs = 4;
  //static const double sm = 8;
  //static const double md = 12;
  static const double normal = 16;
  //static const double xl = 24;
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        displayLarge: AppTypography.h1,
        headlineLarge: AppTypography.h2,
        titleMedium: AppTypography.title,
        bodyMedium: AppTypography.body,
        labelMedium: AppTypography.caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
      ),
    );
  }
}
