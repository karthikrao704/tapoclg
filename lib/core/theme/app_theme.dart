// lib/presentation/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // --- Core Colors ---
  static const Color primaryAction = Color(0xFFD9A04B);
  static const Color primaryText = Color(0xFF191F38);
  static const Color secondaryText = Color(0xFF6F7894);
  static const Color cardSurface = Color(0xFFFBFBFB);
  static const Color appBackground = Color(0xFFFFFFFF);

  // Specific UI Elements
  static const Color wellnessTipBg = Color.fromARGB(30, 88, 184, 20);
  static const Color wellnessTipText = Color(0xFFAE8F50);
  static const Color outlineColor = Color.fromARGB(255, 167, 167, 167);
  static const Color tertiaryColor = Color.fromARGB(255, 236, 236, 236);

  // --- Responsive Light Theme Definition ---
  // We now pass BuildContext to determine the screen size
  static ThemeData getLightTheme(BuildContext context) {
    // Standard design draft width (e.g., standard mobile screen)
    const double baseDesignWidth = 375.0;
    
    // Get the current screen width
    final double screenWidth = MediaQuery.sizeOf(context).width;

    // Calculate scale factor. Clamped between 0.8 and 1.3 to prevent 
    // extreme sizing on very small or very large (tablet/desktop) screens.
    final double scaleFactor = (screenWidth / baseDesignWidth).clamp(0.8, 1.3);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: appBackground,

      // Color Scheme Mapping
      colorScheme: const ColorScheme.light(
        primary: primaryAction,
        onPrimary: Colors.white,
        surface: appBackground,
        onSurface: primaryText,
        secondary: wellnessTipBg,
        onSecondary: wellnessTipText,
        outline: outlineColor,
        tertiary: tertiaryColor,
      ),

      // Typography / Text Theme (Scaled Dynamically)
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 20 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: primaryText,
        ),
        titleMedium: TextStyle(
          fontSize: 16 * scaleFactor,
          fontWeight: FontWeight.w700,
          color: primaryText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14 * scaleFactor,
          fontWeight: FontWeight.w400,
          color: primaryText,
        ),
        bodySmall: TextStyle(
          fontSize: 13 * scaleFactor,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
        labelLarge: TextStyle(
          fontSize: 14 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: secondaryText,
        ),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: appBackground,
        foregroundColor: primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      // Elevated Button Theme (Scaled Padding & Text)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAction,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 16 * scaleFactor), // Scaled height
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * scaleFactor), // Scaled radius
          ),
          textStyle: TextStyle(
            fontSize: 16 * scaleFactor, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Outlined Button Theme (Scaled Padding & Text)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryText,
          side: const BorderSide(color: outlineColor, width: 1.5),
          padding: EdgeInsets.symmetric(vertical: 16 * scaleFactor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * scaleFactor),
          ),
          textStyle: TextStyle(
            fontSize: 16 * scaleFactor, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: appBackground,
        selectedItemColor: primaryAction,
        unselectedItemColor: secondaryText,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12 * scaleFactor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12 * scaleFactor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}