import 'package:flutter/material.dart';

class CrimpyTheme {
  // Colors
  static const Color primaryBlack = Color(0xFF1A1A1A);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F8F8);

  // Muted Accent Colors
  static const Color accentOrange = Color(0xFFC4653A);
  static const Color accentYellow = Color(0xFFB8924A);
  static const Color accentPurple = Color(0xFF8B7EC8);

  // Gray Scale
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFE8E8E8);
  static const Color gray300 = Color(0xFFD4D4D4);
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray500 = Color(0xFF737373);
  static const Color gray600 = Color(0xFF525252);
  static const Color gray700 = Color(0xFF404040);

  // Semantic Colors
  static const Color assessmentColor = accentOrange;
  static const Color trainingColor = accentYellow;
  static const Color stretchingColor = accentPurple;
  static const Color successColor = Color(
    0xFF22C55E,
  ); // Green for rest/success states
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = accentYellow;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: primaryBlack,
      secondary: accentOrange,
      tertiary: accentPurple,
      surface: primaryWhite,
      error: errorColor,
      onPrimary: primaryWhite,
      onSecondary: primaryWhite,
      onSurface: primaryBlack,
    ),

    // Scaffold
    scaffoldBackgroundColor: background,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: primaryBlack,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: primaryBlack,
        fontSize: 32,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: primaryBlack),
      actionsIconTheme: IconThemeData(color: primaryBlack),
    ),

    // Card Theme with Shadows
    cardTheme: CardThemeData(
      color: primaryWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: primaryBlack, width: 2),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    // Elevated Button with Shadow
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlack,
        foregroundColor: primaryWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: primaryBlack, width: 2),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined Button with Shadow
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlack,
        backgroundColor: primaryWhite,
        side: const BorderSide(color: primaryBlack, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentOrange,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Input Decoration with Shadow
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: primaryWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlack, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlack, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accentOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: const TextStyle(
        color: gray500,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      hintStyle: const TextStyle(color: gray400),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: gray100,
      selectedColor: accentYellow,
      disabledColor: gray200,
      labelStyle: const TextStyle(
        color: primaryBlack,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: primaryBlack, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: background,
      selectedItemColor: primaryBlack,
      unselectedItemColor: gray500,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: background,
      indicatorColor: CrimpyTheme.accentOrange,
      elevation: 0,
    ),

    // Floating Action Button with Shadow
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlack,
      foregroundColor: primaryWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: primaryBlack, width: 2),
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        color: primaryBlack,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: primaryBlack,
      ),
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryBlack,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primaryBlack,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryBlack,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryBlack,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryBlack,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryBlack,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryBlack,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: primaryBlack,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: gray300,
      thickness: 2,
      space: 24,
    ),
  );

  // Custom Shadow Decorations
  static BoxDecoration cardShadow = BoxDecoration(
    color: primaryWhite,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: gray200, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );

  static BoxDecoration buttonShadow = BoxDecoration(
    borderRadius: BorderRadius.circular(6),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        offset: const Offset(0, 2),
        blurRadius: 8,
      ),
    ],
  );

  // Custom Widget Styles
  static BoxDecoration accentCardDecoration(Color accentColor) => BoxDecoration(
    color: primaryWhite,
    borderRadius: BorderRadius.circular(8),
    border: Border(
      left: BorderSide(color: accentColor, width: 4),
      top: BorderSide(color: gray300, width: 1),
      right: BorderSide(color: gray300, width: 1),
      bottom: BorderSide(color: gray300, width: 1),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );
}
