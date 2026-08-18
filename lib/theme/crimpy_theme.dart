import 'package:crimpy/models/common.dart';
import 'package:flutter/material.dart';

// Export custom widgets
export 'widgets/widgets.dart';

/// Crimpy Theme - Radicle-inspired minimalist design system
/// Based on the clean, developer-focused aesthetic of Radicle.xyz
class CrimpyTheme {
  // ==================== CORE COLORS ====================

  /// Primary brand color - burnt orange from Radicle palette
  static const Color primaryOrange = Color(0xFFC6613F);

  /// Pure black for high contrast
  static const Color primaryBlack = Color(0xFF000000);

  /// Pure white for backgrounds
  static const Color primaryWhite = Color(0xFFFFFFFF);

  // ==================== ACCENT COLORS ====================
  // Harmonious palette for categorizing different training types

  /// Strength training - Primary orange
  static const Color accentOrange = Color(0xFFC6613F);

  /// Endurance training - Muted forest green
  static const Color accentGreen = Color(0xFF5A8C5A);

  /// Power training - Warm golden yellow
  static const Color accentYellow = Color(0xFFD4A644);

  /// Technique training - Soft purple
  static const Color accentPurple = Color(0xFF8B6B9E);

  /// Flexibility training - Dusty teal
  static const Color accentTeal = Color(0xFF5A8C8C);

  /// Everything that fits no other category - Slate blue
  static const Color accentBlue = Color(0xFF5B7FA6);

  // ==================== STATUS COLORS ====================

  /// Success state - Deep green
  static const Color statusSuccess = Color(0xFF4A7C4A);

  /// Error state - Muted red
  static const Color statusError = Color(0xFFB85450);

  /// Warning state - Same as accent yellow
  static const Color statusWarning = Color(0xFFD4A644);

  /// Info state - Same as accent teal
  static const Color statusInfo = Color(0xFF5A8C8C);

  // ==================== STATUS BACKGROUNDS ====================

  /// Light success background
  static const Color bgSuccess = Color(0xFFF0F8F0);

  /// Light error background
  static const Color bgError = Color(0xFFFDF5F5);

  /// Light warning background
  static const Color bgWarning = Color(0xFFFFFAF0);

  /// Light info background
  static const Color bgInfo = Color(0xFFF0F8F8);

  // ==================== BACKGROUND COLORS ====================

  /// Primary background - Pure white
  static const Color bgPrimary = Color(0xFFFFFFFF);

  /// Secondary background - Very light gray
  static const Color bgSecondary = Color(0xFFFAFAFA);

  /// Hover state background
  static const Color bgHover = Color(0xFFF5F5F5);

  // ==================== TEXT COLORS ====================

  /// Primary text - Black
  static const Color textPrimary = Color(0xFF000000);

  /// Secondary text - Medium gray
  static const Color textSecondary = Color(0xFF666666);

  /// Muted text - Light gray
  static const Color textMuted = Color(0xFF999999);

  /// Secondary text drawn over a filled surface - Translucent white
  static const Color textOnFillSecondary = Color(0xB3FFFFFF);

  // ==================== BORDER COLORS ====================

  /// Default border - Light gray
  static const Color borderDefault = Color.fromARGB(255, 29, 29, 29);

  /// Darker border for emphasis
  static const Color borderDark = Color(0xFFCCCCCC);

  // ==================== SEMANTIC COLOR MAPPING ====================
  // For backwards compatibility with existing code

  /// Assessment activities
  static const Color assessmentColor = accentOrange;

  /// Training activities
  static const Color trainingColor = accentYellow;

  /// Stretching/flexibility activities
  static const Color stretchingColor = accentTeal;

  /// Success/rest states
  static const Color successColor = statusSuccess;

  /// Error states
  static const Color errorColor = statusError;

  /// Warning states
  static const Color warningColor = statusWarning;

  // ==================== GRAY SCALE ====================
  // Maintained for backwards compatibility

  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = borderDefault;
  static const Color gray300 = borderDark;
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray500 = textSecondary;
  static const Color gray600 = Color(0xFF525252);
  static const Color gray700 = Color(0xFF404040);

  // ==================== SPACING CONSTANTS ====================

  /// No border radius for sharp, minimal look
  static const double radiusNone = 0.0;

  /// Small border radius for subtle rounding
  static const double radiusSmall = 2.0;

  /// Medium border radius
  static const double radiusMedium = 4.0;

  // ==================== THEME DATA ====================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'JetBrainsMono', // Monospace font like Radicle
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: primaryOrange,
      secondary: accentGreen,
      tertiary: accentPurple,
      surface: bgPrimary,
      error: statusError,
      onPrimary: primaryWhite,
      onSecondary: primaryWhite,
      onSurface: textPrimary,
      onError: primaryWhite,
      outline: borderDefault,
      outlineVariant: borderDark,
    ),

    // Scaffold
    scaffoldBackgroundColor: bgPrimary,

    // AppBar with minimalist styling
    appBarTheme: const AppBarTheme(
      backgroundColor: bgPrimary,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'JetBrainsMono',
        color: textPrimary,
        fontSize: 38,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: textPrimary),
      actionsIconTheme: IconThemeData(color: textPrimary),
    ),

    // Card with sharp edges and double border effect
    cardTheme: const CardThemeData(
      color: bgPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: borderDefault, width: 2),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      shadowColor: borderDefault,
    ),

    // Primary button - Orange with sharp edges
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: primaryWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'JetBrainsMono',
        ),
      ),
    ),

    // Outlined button - Orange border
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryOrange,
        backgroundColor: bgPrimary,
        side: const BorderSide(color: primaryOrange, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'JetBrainsMono',
        ),
      ),
    ),

    // Text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryOrange,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'JetBrainsMono',
        ),
      ),
    ),

    // Input fields with sharp borders
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: bgPrimary,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: borderDefault, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: borderDefault, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: primaryOrange, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: statusError, width: 1),
      ),
      labelStyle: TextStyle(
        color: textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        fontFamily: 'JetBrainsMono',
        letterSpacing: 0.5,
      ),
      hintStyle: TextStyle(color: textMuted, fontFamily: 'JetBrainsMono'),
    ),

    // Chip theme with minimal styling
    chipTheme: ChipThemeData(
      backgroundColor: bgSecondary,
      selectedColor: primaryOrange,
      disabledColor: gray200,
      labelStyle: const TextStyle(
        color: textPrimary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        fontFamily: 'JetBrainsMono',
      ),
      side: const BorderSide(color: borderDefault, width: 1),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),

    // Bottom navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgSecondary,
      selectedItemColor: primaryOrange,
      unselectedItemColor: textPrimary,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: bgSecondary,
      indicatorColor: primaryOrange,
      elevation: 0,
    ),

    // FAB with sharp corners
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryOrange,
      foregroundColor: primaryWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),

    // Typography - Monospace font throughout
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: textPrimary,
        fontFamily: 'JetBrainsMono',
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: textPrimary,
        fontFamily: 'JetBrainsMono',
      ),
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontFamily: 'JetBrainsMono',
      ),
      headlineLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontFamily: 'JetBrainsMono',
      ),
      headlineMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontFamily: 'JetBrainsMono',
      ),
      headlineSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontFamily: 'JetBrainsMono',
      ),
      titleLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontFamily: 'JetBrainsMono',
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        fontFamily: 'JetBrainsMono',
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        fontFamily: 'JetBrainsMono',
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        fontFamily: 'JetBrainsMono',
        height: 1.6,
      ),
      labelLarge: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textSecondary,
        fontFamily: 'JetBrainsMono',
        textBaseline: TextBaseline.alphabetic,
      ),
      labelMedium: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textSecondary,
        fontFamily: 'JetBrainsMono',
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textMuted,
        fontFamily: 'JetBrainsMono',
      ),
    ),

    // Divider with minimal styling
    dividerTheme: const DividerThemeData(
      color: borderDefault,
      thickness: 1,
      space: 16,
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryWhite;
        }
        return borderDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryOrange;
        }
        return bgSecondary;
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryOrange;
        }
        return bgPrimary;
      }),
      checkColor: WidgetStateProperty.all(primaryWhite),
      side: const BorderSide(color: borderDefault, width: 1),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryOrange;
        }
        return borderDefault;
      }),
    ),

    // Slider theme
    sliderTheme: const SliderThemeData(
      activeTrackColor: primaryOrange,
      inactiveTrackColor: borderDefault,
      thumbColor: primaryOrange,
      overlayColor: Color(0x1FC6613F), // 12% opacity orange
      valueIndicatorColor: primaryOrange,
    ),

    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryOrange,
      linearTrackColor: borderDefault,
      circularTrackColor: borderDefault,
    ),

    // Tab bar theme
    tabBarTheme: const TabBarThemeData(
      labelColor: primaryOrange,
      unselectedLabelColor: textSecondary,
      indicatorColor: primaryOrange,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontFamily: 'JetBrainsMono',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        fontFamily: 'JetBrainsMono',
      ),
    ),

    // Snack bar theme
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: primaryBlack,
      contentTextStyle: TextStyle(
        color: primaryWhite,
        fontFamily: 'JetBrainsMono',
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ==================== CUSTOM DECORATIONS ====================

  /// Basic card decoration with double border effect
  static BoxDecoration cardDecoration = BoxDecoration(
    color: bgPrimary,
    border: Border.all(color: borderDefault, width: 2),
    boxShadow: [
      BoxShadow(
        color: borderDefault,
        offset: const Offset(4, 4),
        blurRadius: 0, // Sharp shadow for double border effect
        spreadRadius: 0,
      ),
    ],
  );

  /// Hover effect decoration
  static BoxDecoration hoverDecoration = BoxDecoration(
    color: bgHover,
    border: Border.all(color: primaryOrange, width: 1),
    boxShadow: [
      BoxShadow(
        color: primaryOrange.withValues(alpha: 0.1),
        offset: const Offset(0, 2),
        blurRadius: 8,
      ),
    ],
  );

  /// Category-specific card decoration with colored left border and double border effect
  static BoxDecoration categoryCardDecoration(Color categoryColor) =>
      BoxDecoration(
        color: bgPrimary,
        border: Border(
          left: BorderSide(color: categoryColor, width: 4),
          top: BorderSide(color: borderDefault, width: 2),
          right: BorderSide(color: borderDefault, width: 2),
          bottom: BorderSide(color: borderDefault, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: borderDefault,
            offset: const Offset(4, 4),
            blurRadius: 0, // Sharp shadow for double border effect
            spreadRadius: 0,
          ),
        ],
      );

  /// Status background decoration
  static BoxDecoration statusDecoration(
    Color statusColor,
    Color backgroundColor,
  ) => BoxDecoration(
    color: backgroundColor,
    border: Border.all(color: statusColor, width: 1),
  );

  // ==================== CATEGORY HELPERS ====================

  /// Accent color a session is drawn with, from what was trained.
  ///
  /// The web portal paints the same activities with the same values, so these
  /// are a contract across the two clients rather than a local styling choice.
  static Color activityColor(SessionActivity activity) => switch (activity) {
    SessionActivity.hangboard => accentOrange,
    SessionActivity.climbing => accentYellow,
    SessionActivity.stretching => accentGreen,
    SessionActivity.workout => accentPurple,
    SessionActivity.other => accentBlue,
  };

  /// Get category color for training types
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
      case 'assessment':
        return accentOrange;
      case 'endurance':
        return accentGreen;
      case 'power':
      case 'training':
        return accentYellow;
      case 'technique':
        return accentPurple;
      case 'flexibility':
      case 'stretching':
        return accentTeal;
      default:
        return accentOrange;
    }
  }

  /// Get status decoration for different states
  static BoxDecoration getStatusDecoration(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return statusDecoration(statusSuccess, bgSuccess);
      case 'error':
      case 'failed':
        return statusDecoration(statusError, bgError);
      case 'warning':
      case 'pending':
        return statusDecoration(statusWarning, bgWarning);
      case 'info':
      case 'active':
        return statusDecoration(statusInfo, bgInfo);
      default:
        return cardDecoration;
    }
  }

  // ==================== BACKWARDS COMPATIBILITY ====================
  // Aliases for existing code that uses old naming conventions

  static const Color background = bgSecondary;
  static const Color accentCardDecoration = accentOrange; // For method calls

  /// Legacy method for accent card decoration
  static BoxDecoration getAccentCardDecoration(Color accentColor) =>
      categoryCardDecoration(accentColor);

  /// Legacy shadow decorations
  static BoxDecoration get cardShadow => cardDecoration;
  static BoxDecoration get buttonShadow => hoverDecoration;
}
