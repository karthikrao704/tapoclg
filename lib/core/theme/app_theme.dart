// lib/presentation/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // --- Core Colors ---
  static const Color primaryAction = Color(
    0xFFD9A04B,
  ); // Book Service, Active Icons
  static const Color primaryText = Color(0xFF191F38); // Headers, Titles
  static const Color secondaryText = Color(0xFF6F7894); // Subtitles, Durations
  static const Color cardSurface = Color(0xFFFBFBFB); // White/Light Grey Cards
  static const Color appBackground = Color(0xFFFFFFFF); // Main App Background

  // Specific UI Elements
  static const Color wellnessTipBg = Color.fromARGB(
    30,
    88,
    184,
    20,
  ); // Light greenish background
  static const Color wellnessTipText = Color(0xFFAE8F50); // Olive Tan Title
  static const Color outlineColor = Color.fromARGB(
    255,
    167,
    167,
    167,
  ); // Borders (e.g., Support button)
  // tertiary color is used for the appointment card background, which is a light grey tone
  static const Color tertiaryColor = Color.fromARGB(
    255,
    236,
    236,
    236,
  ); // Used for the appointment card background

  // --- Light Theme Definition ---
  static ThemeData get lightTheme {
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

      // Typography / Text Theme
      textTheme: const TextTheme(
        // Used for "Featured Services", "Upcoming Appointments"
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryText,
        ),
        // Used for Service Names, User Name
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: primaryText,
        ),
        // Used for Body Text (e.g., Wellness tip description)
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: primaryText,
        ),
        // Used for Subtitles (e.g., durations, "with Dr. Sarah Wilson")
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
        // Used for Labels (e.g., "Good Morning", "View all")
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: secondaryText,
        ),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: appBackground,
        foregroundColor: primaryText,
        elevation: 0,
        scrolledUnderElevation: 0, // Prevents color change on scroll in M3
        centerTitle: false,
      ),

      // Elevated Button Theme (The "Book Service" button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAction,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      // Outlined Button Theme (The "Support" button)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryText,
          side: const BorderSide(color: outlineColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: appBackground,
        selectedItemColor: primaryAction,
        unselectedItemColor: secondaryText,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
