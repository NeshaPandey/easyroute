import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  EasyRoute Design System
//  Philosophy: Calm confidence. Readable at a glance.
//  Navigation for everyone — no map literacy required.
// ─────────────────────────────────────────────

class AppColors {
  // Primary palette — deep teal, accessible & calming
  static const primary = Color(0xFF0A7EA4);
  static const primaryLight = Color(0xFF38B2D4);
  static const primaryDark = Color(0xFF065E7C);
  static const primaryContainer = Color(0xFFD6F0F7);

  // Accent — warm amber for actions and highlights
  static const accent = Color(0xFFFF8C00);
  static const accentLight = Color(0xFFFFB347);
  static const accentContainer = Color(0xFFFFF3E0);

  // Semantic colors
  static const success = Color(0xFF2E7D32);
  static const successContainer = Color(0xFFE8F5E9);
  static const warning = Color(0xFFF57F17);
  static const warningContainer = Color(0xFFFFFDE7);
  static const error = Color(0xFFC62828);
  static const errorContainer = Color(0xFFFFEBEE);

  // SOS / Emergency
  static const sos = Color(0xFFD32F2F);
  static const sosContainer = Color(0xFFFFCDD2);

  // Transport type colors
  static const walking = Color(0xFF43A047);
  static const bus = Color(0xFF1565C0);
  static const metro = Color(0xFF6A1B9A);
  static const auto = Color(0xFFFF6F00);

  // Neutral light
  static const background = Color(0xFFF8FAFB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F5F8);
  static const outline = Color(0xFFCDD5DC);
  static const onSurface = Color(0xFF1A2530);
  static const onSurfaceMuted = Color(0xFF607585);
  static const onSurfaceLight = Color(0xFF9EB0BC);

  // Neutral dark
  static const darkBackground = Color(0xFF0D1B2A);
  static const darkSurface = Color(0xFF162535);
  static const darkSurfaceVariant = Color(0xFF1E3347);
  static const darkOutline = Color(0xFF2C4358);
  static const darkOnSurface = Color(0xFFE8F1F8);
  static const darkOnSurfaceMuted = Color(0xFF8AABBF);
}

class AppTypography {
  static const fontFamily = 'Inter';

  static const displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static const headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: AppTypography.fontFamily,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.primaryDark,
          secondary: AppColors.accent,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.accentContainer,
          onSecondaryContainer: AppColors.accent,
          error: AppColors.error,
          onError: Colors.white,
          errorContainer: AppColors.errorContainer,
          onErrorContainer: AppColors.error,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          surfaceContainerHighest: AppColors.surfaceVariant,
          outline: AppColors.outline,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          titleTextStyle: AppTypography.headlineMedium,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outline, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: AppTypography.labelLarge,
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            textStyle: AppTypography.labelLarge,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.outline, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: AppTypography.bodyLarge
              .copyWith(color: AppColors.onSurfaceLight),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          showUnselectedLabels: true,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.outline,
          thickness: 1,
          space: 1,
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: const BorderSide(color: AppColors.outline),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        fontFamily: AppTypography.fontFamily,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primaryLight,
          onPrimary: AppColors.darkBackground,
          primaryContainer: AppColors.primaryDark,
          onPrimaryContainer: AppColors.primaryLight,
          secondary: AppColors.accentLight,
          onSecondary: AppColors.darkBackground,
          secondaryContainer: Color(0xFF4A2800),
          onSecondaryContainer: AppColors.accentLight,
          error: Color(0xFFFF6B6B),
          onError: AppColors.darkBackground,
          errorContainer: Color(0xFF5C1212),
          onErrorContainer: Color(0xFFFF6B6B),
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkOnSurface,
          surfaceContainerHighest: AppColors.darkSurfaceVariant,
          outline: AppColors.darkOutline,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkOnSurface,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkOnSurface,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.darkOutline, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
      );
}
