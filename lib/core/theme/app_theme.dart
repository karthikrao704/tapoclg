// lib/presentation/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

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

  // --- Dark Mode Colors ---
  static const Color primaryActionDark = Color(0xFFE5B368);
  static const Color primaryTextDark = Color(0xFFF8FAFC);
  static const Color secondaryTextDark = Color(0xFF94A3B8);
  static const Color cardSurfaceDark = Color(0xFF1E293B);
  static const Color appBackgroundDark = Color(0xFF0F172A);

  static const Color wellnessTipBgDark = Color.fromARGB(40, 229, 179, 104);
  static const Color wellnessTipTextDark = Color(0xFFE5B368);
  static const Color outlineColorDark = Color(0xFF334155);
  static const Color tertiaryColorDark = Color(0xFF1E293B);

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
        titleLarge: AppFonts.headland(
          fontSize: 20 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: primaryText,
        ),
        titleMedium: AppFonts.poppinsSemiBold(
          fontSize: 16 * scaleFactor,
          color: primaryText,
        ),
        bodyMedium: AppFonts.poppinsRegular(
          fontSize: 14 * scaleFactor,
          color: primaryText,
        ),
        bodySmall: AppFonts.poppinsRegular(
          fontSize: 13 * scaleFactor,
          color: secondaryText,
        ),
        labelLarge: AppFonts.poppinsMedium(
          fontSize: 14 * scaleFactor,
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

  // --- Responsive Dark Theme Definition ---
  static ThemeData getDarkTheme(BuildContext context) {
    const double baseDesignWidth = 375.0;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scaleFactor = (screenWidth / baseDesignWidth).clamp(0.8, 1.3);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: appBackgroundDark,

      colorScheme: const ColorScheme.dark(
        primary: primaryActionDark,
        onPrimary: Colors.black,
        surface: appBackgroundDark,
        onSurface: primaryTextDark,
        secondary: wellnessTipBgDark,
        onSecondary: wellnessTipTextDark,
        outline: outlineColorDark,
        tertiary: tertiaryColorDark,
      ),

      textTheme: TextTheme(
        titleLarge: AppFonts.headland(
          fontSize: 20 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: primaryTextDark,
        ),
        titleMedium: AppFonts.poppinsSemiBold(
          fontSize: 16 * scaleFactor,
          color: primaryTextDark,
        ),
        bodyMedium: AppFonts.poppinsRegular(
          fontSize: 14 * scaleFactor,
          color: primaryTextDark,
        ),
        bodySmall: AppFonts.poppinsRegular(
          fontSize: 13 * scaleFactor,
          color: secondaryTextDark,
        ),
        labelLarge: AppFonts.poppinsMedium(
          fontSize: 14 * scaleFactor,
          color: secondaryTextDark,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: appBackgroundDark,
        foregroundColor: primaryTextDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryActionDark,
          foregroundColor: Colors.black,
          elevation: 0,
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

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTextDark,
          side: const BorderSide(color: outlineColorDark, width: 1.5),
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

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: appBackgroundDark,
        selectedItemColor: primaryActionDark,
        unselectedItemColor: secondaryTextDark,
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