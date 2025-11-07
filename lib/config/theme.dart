import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// APP THEME CONFIGURATION
/// Defines colors, fonts, and text styles for the entire app
/// ═══════════════════════════════════════════════════════════════

class AppTheme {
  // ───────────────────────────────────────────────────────────────
  // COLOR PALETTE
  // ───────────────────────────────────────────────────────────────

  // Primary Colors (Islamic/Spiritual theme - Green)
  static const Color primaryColor = Color(0xFF2E7D32); // Dark Green
  static const Color primaryLightColor = Color(0xFF4CAF50); // Light Green
  static const Color primaryDarkColor = Color(0xFF1B5E20); // Very Dark Green

  // Accent Colors (Gold/Amber for highlights)
  static const Color accentColor = Color(0xFFFFB300); // Amber
  static const Color accentLightColor = Color(0xFFFFD54F);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Gray
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color cardColor = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF212121); // Almost Black
  static const Color textSecondaryColor = Color(0xFF757575); // Gray
  static const Color textOnPrimaryColor = Color(0xFFFFFFFF); // White

  // Utility Colors
  static const Color errorColor = Color(0xFFD32F2F); // Red
  static const Color successColor = Color(0xFF388E3C); // Green
  static const Color warningColor = Color(0xFFF57C00); // Orange
  static const Color infoColor = Color(0xFF1976D2); // Blue

  // Icon Colors
  static const Color iconActiveColor = Color(0xFF2E7D32);
  static const Color iconInactiveColor = Color(0xFF9E9E9E);

  // Divider & Border
  static const Color dividerColor = Color(0xFFBDBDBD);
  static const Color borderColor = Color(0xFFE0E0E0);

  // ───────────────────────────────────────────────────────────────
  // FONT FAMILIES
  // ───────────────────────────────────────────────────────────────

  // You'll need to add these fonts to pubspec.yaml
  static const String urduFontFamily = 'NafeesNastaleeq'; // Beautiful Urdu font
  static const String englishFontFamily = 'Roboto'; // Default Flutter font
  static const String arabicFontFamily = 'Amiri'; // For Arabic text

  // ───────────────────────────────────────────────────────────────
  // LIGHT THEME
  // ───────────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    return ThemeData(
      // Primary Theme
      primaryColor: primaryColor,
      primaryColorLight: primaryLightColor,
      primaryColorDark: primaryDarkColor,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: textOnPrimaryColor,
        onSecondary: textPrimaryColor,
        onSurface: textPrimaryColor,
        onBackground: textPrimaryColor,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: backgroundColor,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimaryColor,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: textOnPrimaryColor),
        titleTextStyle: TextStyle(
          color: textOnPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: englishFontFamily,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: textPrimaryColor,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: iconActiveColor,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: iconInactiveColor,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Text Theme (will be overridden based on language)
      textTheme: _buildTextTheme(englishFontFamily),

      // Input Decoration (for search, forms)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // DARK THEME (Optional - for future)
  // ───────────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryLightColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      // Add dark theme properties here
      textTheme: _buildTextTheme(englishFontFamily),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // TEXT THEME BUILDER
  // Creates text styles for different font families
  // ───────────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme(String fontFamily) {
    return TextTheme(
      // Display styles (large titles)
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),

      // Headline styles (section headers)
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),

      // Title styles (card titles, list titles)
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
      ),

      // Body styles (main content)
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: textPrimaryColor,
        height: 1.8, // Line height for readability (important for Urdu)
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimaryColor,
        height: 1.8,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textSecondaryColor,
        height: 1.6,
      ),

      // Label styles (buttons, tags)
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondaryColor,
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Get font family based on language
  // ───────────────────────────────────────────────────────────────

  static String getFontFamily(String languageCode) {
    switch (languageCode) {
      case 'ur': // Urdu
        return urduFontFamily;
      case 'ar': // Arabic (if you add it)
        return arabicFontFamily;
      case 'en': // English
      case 'bn': // Bangla
      case 'hi': // Hindi
      default:
        return englishFontFamily;
    }
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Get text theme for specific language
  // ───────────────────────────────────────────────────────────────

  static TextTheme getTextThemeForLanguage(String languageCode) {
    return _buildTextTheme(getFontFamily(languageCode));
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHY separate font families?
   - Urdu needs special Nastaleeq font for proper calligraphy
   - English/Hindi/Bangla work fine with Roboto
   - Each language has different aesthetic needs

2. WHY height: 1.8 in bodyText?
   - Urdu text needs more vertical spacing
   - Makes verses easier to read
   - Prevents text overlap in RTL languages

3. WHY ThemeData?
   - Single source of truth for all styling
   - Change one place, entire app updates
   - Consistent look throughout app

4. WHAT'S NEXT?
   We need to add fonts to pubspec.yaml:
   
   fonts:
     - family: NafeesNastaleeq
       fonts:
         - asset: assets/fonts/NafeesNastaleeq.ttf
     - family: Amiri
       fonts:
         - asset: assets/fonts/Amiri-Regular.ttf

5. HOW to use this in code?
   
   // Access colors:
   AppTheme.primaryColor
   
   // Access text styles:
   Text(
     'مصطفیٰ',
     style: Theme.of(context).textTheme.bodyLarge,
   )
   
   // Get font for language:
   String font = AppTheme.getFontFamily('ur');

═══════════════════════════════════════════════════════════════
*/