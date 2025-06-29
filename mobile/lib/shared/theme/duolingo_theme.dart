import 'package:flutter/material.dart';

class DuolingoTheme {
  // Primary colors from Duolingo brand
  static const Color duoGreen = Color(0xFF58CC02);
  static const Color duoBlue = Color(0xFF1CB0F6);
  static const Color duoRed = Color(0xFFFF4B4B);
  static const Color duoYellow = Color(0xFFFFD43B);
  static const Color duoOrange = Color(0xFFFF9600);
  static const Color duoPurple = Color(0xFFCE82FF);
  
  // Background colors
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color backgroundDark = Color(0xFF2C2C2C);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF3C3C3C);
  
  // Text colors
  static const Color textPrimary = Color(0xFF3C3C3C);
  static const Color textSecondary = Color(0xFF777777);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF3C3C3C);
  
  // Border and divider colors
  static const Color borderLight = Color(0xFFE5E5E5);
  static const Color borderDark = Color(0xFF5A5A5A);
  static const Color divider = Color(0xFFE5E5E5);
  
  // Status colors
  static const Color success = duoGreen;
  static const Color warning = duoYellow;
  static const Color error = duoRed;
  static const Color info = duoBlue;
  
  // Kingdom tier colors
  static const Color villageColor = Color(0xFF8B4513);
  static const Color townColor = Color(0xFF4682B4);
  static const Color cityColor = Color(0xFF6B46C1);
  static const Color kingdomColor = Color(0xFFDC2626);
  static const Color empireColor = Color(0xFFD97706);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [duoGreen, duoBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [duoGreen, Color(0xFF4ADE80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [duoYellow, duoOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [duoRed, Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Text styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textOnPrimary,
  );
  
  // Box decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceLight,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: duoGreen.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration get successButtonDecoration => BoxDecoration(
    gradient: successGradient,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: duoGreen.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  // Kingdom tier decorations
  static BoxDecoration getKingdomTierDecoration(String tier) {
    Color color;
    switch (tier.toLowerCase()) {
      case 'village':
        color = villageColor;
        break;
      case 'town':
        color = townColor;
        break;
      case 'city':
        color = cityColor;
        break;
      case 'kingdom':
        color = kingdomColor;
        break;
      case 'empire':
        color = empireColor;
        break;
      default:
        color = duoGreen;
    }
    
    return BoxDecoration(
      color: color.withValues(alpha: 0.1),
      border: Border.all(color: color.withValues(alpha: 0.3)),
      borderRadius: BorderRadius.circular(12),
    );
  }
  
  // Input decoration
  static InputDecoration getInputDecoration({
    required String label,
    IconData? prefixIcon,
    IconData? suffixIcon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: duoGreen) : null,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: textSecondary) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: duoGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      filled: true,
      fillColor: surfaceLight,
    );
  }
  
  // Theme data
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: duoGreen,
      secondary: duoBlue,
      surface: surfaceLight,
      error: error,
    ),
    textTheme: const TextTheme(
      headlineLarge: headingLarge,
      headlineMedium: headingMedium,
      headlineSmall: headingSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: duoGreen,
        foregroundColor: textOnPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: duoGreen, width: 2),
      ),
      filled: true,
      fillColor: surfaceLight,
    ),
  );
}