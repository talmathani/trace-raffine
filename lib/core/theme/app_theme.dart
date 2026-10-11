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
  static const Color cardSurface = Color(0xFF241017);
  static const Color secondarySurface = Color(0xFF2A1017);

  static const Color secondaryText = Color(0xFFBFA9AE);

  static const Color editorialIvory = Color(0xFFE8D6C5);

  static const Color imagePlaceholder = Color(0xFF722F37);

  static const Color mutedText = Color(0xFFA9979E);

  static const Color divider = Color(0xFF3A202B);
  static const Color productAccent = Color(0xFFC28A9A);

  static const Color unavailableRose = Color(0xFFE8A0A8);
  static const Color statusSuccess = Color(0xFF75B798);
  static const Color statusRejected = Color(0xFFD47A7A);

  // ---------------------------------------------------------------------------
  // Design Tokens
  //
  // Central spatial, surface, typography, radius, and touch language.
  // Existing public color tokens above remain unchanged for compatibility.

  // Spacing
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 24;
  static const double space2Xl = 32;
  static const double space3Xl = 48;
  static const double space4Xl = 64;

  // Layout
  static const double pageHorizontal = 20;
  static const double sectionGap = 32;
  static const double contentMaxWidth = 760;

  // Radii
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 22;
  static const double radiusEditorial = 28;

  // Touch Targets
  static const double touchTargetMin = 48;
  static const double touchTargetComfort = 52;

  // Typography
  static const String fontArabic = 'Cairo';
  static const String fontEditorial = 'CormorantGaramond';
  static const String fontTechnical = 'Inter';

  static const TextStyle editorialDisplay = TextStyle(
    fontFamily: fontEditorial,
    fontSize: 42,
    fontWeight: FontWeight.w600,
    color: warmIvory,
    height: 1.05,
    letterSpacing: 0.4,
  );

  static const TextStyle editorialTitle = TextStyle(
    fontFamily: fontEditorial,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: warmIvory,
    height: 1.12,
    letterSpacing: 0.25,
  );

  static const TextStyle arabicTitle = TextStyle(
    fontFamily: fontArabic,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: warmIvory,
    height: 1.3,
  );

  static const TextStyle arabicBody = TextStyle(
    fontFamily: fontArabic,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: mutedIvory,
    height: 1.65,
  );

  static const TextStyle technical = TextStyle(
    fontFamily: fontTechnical,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: warmIvory,
    height: 1.4,
  );

  // Login-derived editorial tokens
  //
  // These values are extracted from the protected Login screen and become
  // centralized design tokens for the rest of the Maison.
  //
  // Login remains the visual source of truth; this block does not modify it.

  // Editorial Typography
  static const double editorialHeroSize = 58;
  static const double editorialHeroCompactSize = 42;
  static const double editorialSectionSize = 28;
  static const double editorialCompactSize = 16;

  // Arabic Typography
  static const double arabicLargeSize = 19;
  static const double arabicBodySize = 16;
  static const double arabicMediumSize = 14;
  static const double arabicSmallSize = 13;
  static const double arabicMetaSize = 11.5;
  static const double arabicMicroSize = 10.5;

  // Editorial Geometry
  static const double controlHeight = 56;
  static const double compactControlHeight = 54;
  static const double editorialPanelRadius = 26;
  static const double editorialControlRadius = 24;
  static const double editorialFieldRadius = 14;
  static const double editorialListRadius = 16;

  // Login-derived spacing
  static const double spaceLoginXs = 5;
  static const double spaceLoginSm = 10;
  static const double spaceLoginMd = 12;
  static const double spaceLoginLg = 18;
  static const double spaceLoginXl = 24;
  static const double spaceLogin2Xl = 34;
  static const double spaceLogin3Xl = 42;

  // Editorial Motion
  static const Duration editorialFast = Duration(milliseconds: 220);
  static const Duration editorialReveal = Duration(milliseconds: 300);
  static const Duration editorialFluid = Duration(milliseconds: 420);
  // Semantic Surfaces
  static const Color surfacePrimary = obsidian;
  static const Color surfaceSecondary = burgundyBlack;
  static const Color surfaceElevated = deepBurgundy;
  static const Color surfaceAccent = primaryBurgundy;
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
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: warmIvory,
      height: 1.25,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: warmIvory,
      height: 1.25,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: warmIvory,
      height: 1.3,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: warmIvory,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: warmIvory,
      height: 1.35,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: warmIvory,
      height: 1.4,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: warmIvory,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: warmIvory,
      height: 1.45,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: warmIvory,
      height: 1.45,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: warmIvory,
      height: 1.6,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 13,
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
      fontSize: 13,
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
          fontSize: 17,
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
          side: BorderSide(color: divider),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 13),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: roseBurgundy, width: 1.4),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE57373)),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE57373), width: 1.4),
        ),
        hintStyle: TextStyle(fontFamily: 'Cairo', color: mutedText),
        labelStyle: TextStyle(fontFamily: 'Cairo', color: mutedIvory),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: richBurgundy,
          foregroundColor: warmIvory,
          elevation: 0,
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: warmIvory,
          minimumSize: const Size(0, 46),
          side: const BorderSide(color: roseBurgundy, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: softRose,
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: richBurgundy,
          foregroundColor: warmIvory,
          disabledBackgroundColor: deepBurgundy,
          disabledForegroundColor: mutedText,
          elevation: 0,
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: fontArabic,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: burgundyBlack,
        selectedColor: deepBurgundy,
        disabledColor: obsidian,
        side: const BorderSide(color: divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelStyle: const TextStyle(
          fontFamily: fontArabic,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: mutedIvory,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: fontArabic,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: warmIvory,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: mutedIvory,
          minimumSize: const Size(touchTargetMin, touchTargetMin),
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: obsidian,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: deepBurgundy,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(editorialControlRadius),
          side: const BorderSide(color: divider),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? warmIvory : mutedIvory,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? softRose : mutedIvory,
            size: selected ? 23 : 21,
          );
        }),
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
          fontSize: 13,
          color: mutedIvory,
          height: 1.6,
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: deepBurgundy,
        contentTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          color: warmIvory,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
