import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Kid-friendly color palette
  static const Color labibGreen = Color(0xFF66BB6A); // Labib's main color
  static const Color darkGreen = Color(0xFF4CAF50); // Darker green for contrast
  static const Color skyBlue = Color(0xFF42A5F5); // Bright blue for sky/water
  static const Color sunYellow = Color(0xFFFFD54F); // Warm yellow for accents
  static const Color earthBrown = Color(0xFF8D6E63); // Soft brown for earth
  static const Color lightBackground = Color(0xFFF1F8E9); // Very light green tint
  static const Color pureWhite = Color(0xFFFFFFFF);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: labibGreen,
      primary: labibGreen,
      secondary: skyBlue,
      tertiary: sunYellow,
      background: lightBackground,
      surface: pureWhite,
      onPrimary: pureWhite,
      onSecondary: pureWhite,
      onBackground: darkGreen,
      onSurface: darkGreen,
    ),
    
    // Kid-friendly Arabic font
    textTheme: GoogleFonts.cairoTextTheme().copyWith(
      // Extra large for headings
      headlineLarge: GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkGreen,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkGreen,
      ),
      // Large body text for readability
      bodyLarge: GoogleFonts.cairo(
        fontSize: 18,
        color: darkGreen,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 16,
        color: darkGreen,
      ),
      // Button text
      labelLarge: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: pureWhite,
      ),
    ),
    
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: labibGreen,
      foregroundColor: pureWhite,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: pureWhite,
      ),
    ),
    
    // Extra large, rounded buttons for kids
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: labibGreen,
        foregroundColor: pureWhite,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Very rounded
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        textStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        // Minimum size for easy tapping
        minimumSize: const Size(200, 56),
      ),
    ),
    
    // Playful text buttons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: skyBlue,
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    
    // Rounded, friendly input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: pureWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: labibGreen.withOpacity(0.3), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: labibGreen, width: 3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 3),
      ),
      contentPadding: const EdgeInsets.all(20),
      // Large, colorful icons
      prefixIconColor: labibGreen,
      suffixIconColor: labibGreen,
      labelStyle: GoogleFonts.cairo(
        fontSize: 16,
        color: darkGreen,
      ),
      hintStyle: GoogleFonts.cairo(
        fontSize: 16,
        color: darkGreen.withOpacity(0.5),
      ),
    ),
    
    // Card theme for containers
    cardTheme: CardTheme(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: pureWhite,
    ),
    
    // Snackbar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkGreen,
      contentTextStyle: GoogleFonts.cairo(
        fontSize: 16,
        color: pureWhite,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
