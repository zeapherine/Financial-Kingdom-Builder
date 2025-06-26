import 'package:flutter/material.dart';

/// Duolingo-inspired design system theme
/// Based on styles.json configuration
class DuolingoTheme {
  // Color Palette from styles.json
  static const Color duoGreen = Color(0xFF58CC02);
  static const Color duoGreenDark = Color(0xFF46A302);
  static const Color duoGreenLight = Color(0xFF89E219);
  
  static const Color duoBlue = Color(0xFF1CB0F6);
  static const Color duoBlueDark = Color(0xFF1899D6);
  static const Color duoBlueLight = Color(0xFF84D8FF);
  
  static const Color duoYellow = Color(0xFFFFC800);
  static const Color duoOrange = Color(0xFFFF9600);
  static const Color duoRed = Color(0xFFFF4B4B);
  static const Color duoPurple = Color(0xFFCE82FF);
  
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF7F7F7);
  static const Color mediumGray = Color(0xFFAFAFAF);
  static const Color darkGray = Color(0xFF777777);
  static const Color charcoal = Color(0xFF4B4B4B);
  static const Color black = Color(0xFF000000);

  // Spacing values from styles.json
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;
  static const double spacingXxxl = 64.0;

  // Border radius values from styles.json
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXlarge = 24.0;
  static const double radiusPill = 999.0;

  // Typography from styles.json
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  // Button styles from styles.json
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: duoGreen,
    foregroundColor: white,
    elevation: 4.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 24.0,
      vertical: 16.0,
    ),
    textStyle: button,
  );

  static final ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: duoBlue,
    foregroundColor: white,
    elevation: 4.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 24.0,
      vertical: 16.0,
    ),
    textStyle: button,
  );

  static final ButtonStyle outlineButton = OutlinedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: duoGreen,
    side: const BorderSide(color: duoGreen, width: 2.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 24.0,
      vertical: 16.0,
    ),
    textStyle: button,
  );

  // Card styles from styles.json
  static final BoxDecoration lessonCard = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: const [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 4.0,
        offset: Offset(0, 2),
      ),
    ],
    border: Border.all(color: const Color(0xFFF0F0F0), width: 1.0),
  );

  static final BoxDecoration achievementCard = BoxDecoration(
    color: duoYellow,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: const [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 6.0,
        offset: Offset(0, 3),
      ),
    ],
  );

  static final BoxDecoration streakCard = BoxDecoration(
    color: duoOrange,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: const [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 4.0,
        offset: Offset(0, 2),
      ),
    ],
  );

  // Gamification elements from styles.json
  static final BoxDecoration streakCounter = BoxDecoration(
    color: duoOrange,
    borderRadius: BorderRadius.circular(20.0),
  );

  static final BoxDecoration xpBadge = BoxDecoration(
    color: duoYellow,
    borderRadius: BorderRadius.circular(radiusLarge),
  );

  static final BoxDecoration levelBadge = BoxDecoration(
    color: duoPurple,
    borderRadius: BorderRadius.circular(radiusPill),
  );

  // Animation durations from styles.json
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration buttonPressAnimation = Duration(milliseconds: 100);

  // Icon sizes from styles.json
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXlarge = 48.0;

  // Common shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4.0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8.0,
      offset: Offset(0, 4),
    ),
  ];
}