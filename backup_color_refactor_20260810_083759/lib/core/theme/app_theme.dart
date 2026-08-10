import 'package:flutter/material.dart';

/// TRACÉ RAFFINÉ
/// Global application theme.
///
/// Brand direction:
/// - Deep Burgundy
/// - Burgundy
/// - Soft Rose Burgundy
/// - Warm Ivory
/// - No Gold
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Brand Colors
  // ---------------------------------------------------------------------------

  static const Color obsidian = Color(0xFF10090C);

  static const Color burgundyBlack = Color(0xFF1A0A11);

  static const Color deepBurgundy = Color(0xFF2A0D18);

  static const Color primaryBurgundy = Color(0xFF4A1024);

  static const Color richBurgundy = Color(0xFF641B35);

  static const Color roseBurgundy = Color(0xFF87364F);

  static const Color softRose = Color(0xFFB56A80);

  static const Color warmIvory = Color(0xFFF3ECE8);

  static const Color mutedIvory = Color(0xFFD6C9CD);

  static const Color mutedText = Color(0xFFA9979E);

  static const Color divider = Color(0xFF3A202B);

  // ---------------------------------------------------------------------------
  // Color Scheme
  // ---------------------------------------------------------------------------

  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: richBurgundy,
    onPrimary: warmIvory,
    primaryContainer: primaryBurgundy,
    onPrimaryContainer: warmIvory,
    secondary: softRose,
    onSecondary: obsidian,
    secondaryContainer: deepBurgundy,
    onSecondaryContainer: warmIvory,
    tertiary: roseBurgundy,
    onTertiary: warmIvory,
    tertiaryContainer: burgundyBlack,
    onTertiaryContainer: mutedIvory,
    error: Color(0xFFE57373),
    onError: Color(0xFF2B0A0A),
    errorContainer: Color(0xFF4A1518),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: burgundyBlack,
    onSurface: warmIvory,
    surfaceContainerHighest: deepBurgundy,
    onSurfaceVariant: mutedIvory,
    outline: Color(0xFF654450),
    outlineVariant: divider,
    inverseSurface: warmIvory,
    onInverseSurface: obsidian,
    inversePrimary: primaryBurgundy,
    shadow: Colors.black,
    scrim: Colors.black,
  );

  // ---------------------------------------------------------------------------
  // Text Theme
  // ---------------------------------------------------------------------------

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 34,
      fontWeight: FontWeight.w700,
      color: warmIvory,
      height: 1.25,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: warmIvory,
      height: 1.25,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: warmIvory,
      height: 1.3,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: warmIvory,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 21,
      fontWeight: FontWeight.w700,
      color: warmIvory,
      height: 1.35,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 19,
      fontWeight: FontWeight.w600,
      color: warmIvory,
      height: 1.4,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: warmIvory,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: warmIvory,
      height: 1.45,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: warmIvory,
      height: 1.45,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: warmIvory,
      height: 1.6,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: mutedIvory,
      height: 1.6,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: mutedText,
      height: 1.55,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: warmIvory,
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: mutedIvory,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: mutedText,
      height: 1.35,
    ),
  );

  // ---------------------------------------------------------------------------
  // Theme
  // ---------------------------------------------------------------------------

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: obsidian,
      fontFamily: 'Cairo',
      textTheme: textTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: burgundyBlack,
        foregroundColor: warmIvory,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: warmIvory,
        ),
      ),

      cardTheme: const CardThemeData(
        color: burgundyBlack,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: burgundyBlack,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: roseBurgundy, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE57373)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.4),
        ),
        hintStyle: const TextStyle(fontFamily: 'Cairo', color: mutedText),
        labelStyle: const TextStyle(fontFamily: 'Cairo', color: mutedIvory),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: richBurgundy,
          foregroundColor: warmIvory,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: warmIvory,
          minimumSize: const Size(0, 52),
          side: const BorderSide(color: roseBurgundy, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: softRose,
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: burgundyBlack,
        elevation: 0,
        indicatorColor: deepBurgundy,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: warmIvory,
          ),
        ),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: deepBurgundy,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: warmIvory,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          color: mutedIvory,
          height: 1.6,
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: deepBurgundy,
        contentTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          color: warmIvory,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
