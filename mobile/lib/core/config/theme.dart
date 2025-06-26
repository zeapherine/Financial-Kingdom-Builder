import 'package:flutter/material.dart';
import 'duolingo_theme.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: DuolingoTheme.duoGreen,
        brightness: Brightness.light,
        primary: DuolingoTheme.duoGreen,
        secondary: DuolingoTheme.duoBlue,
        surface: DuolingoTheme.white,
      ),
      scaffoldBackgroundColor: DuolingoTheme.lightGray,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: DuolingoTheme.white,
        foregroundColor: DuolingoTheme.charcoal,
        titleTextStyle: DuolingoTheme.h4.copyWith(
          color: DuolingoTheme.charcoal,
        ),
        iconTheme: const IconThemeData(
          color: DuolingoTheme.charcoal,
          size: DuolingoTheme.iconMedium,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(DuolingoTheme.radiusLarge),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: DuolingoTheme.primaryButton,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: DuolingoTheme.outlineButton,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: DuolingoTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DuolingoTheme.white,
        selectedItemColor: DuolingoTheme.duoGreen,
        unselectedItemColor: DuolingoTheme.mediumGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: DuolingoTheme.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: DuolingoTheme.caption,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DuolingoTheme.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          borderSide: const BorderSide(color: DuolingoTheme.mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          borderSide: const BorderSide(color: DuolingoTheme.mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          borderSide: const BorderSide(color: DuolingoTheme.duoGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DuolingoTheme.spacingMd,
          vertical: DuolingoTheme.spacingMd,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: DuolingoTheme.h1,
        displayMedium: DuolingoTheme.h2,
        displaySmall: DuolingoTheme.h3,
        headlineMedium: DuolingoTheme.h4,
        bodyLarge: DuolingoTheme.bodyLarge,
        bodyMedium: DuolingoTheme.bodyMedium,
        bodySmall: DuolingoTheme.bodySmall,
        labelLarge: DuolingoTheme.button,
        labelSmall: DuolingoTheme.caption,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: DuolingoTheme.duoGreen,
        brightness: Brightness.dark,
        primary: DuolingoTheme.duoGreen,
        secondary: DuolingoTheme.duoBlue,
        surface: DuolingoTheme.charcoal,
      ),
      scaffoldBackgroundColor: DuolingoTheme.charcoal,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: DuolingoTheme.charcoal,
        foregroundColor: DuolingoTheme.white,
        titleTextStyle: DuolingoTheme.h4.copyWith(
          color: DuolingoTheme.white,
        ),
        iconTheme: const IconThemeData(
          color: DuolingoTheme.white,
          size: DuolingoTheme.iconMedium,
        ),
      ),
    );
  }
}