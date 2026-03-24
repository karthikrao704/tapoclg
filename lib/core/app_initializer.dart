// lib/core/app_initializer.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Initialization result — holds initialized services
class InitResult {
  final bool dotenvLoaded;
  final String? errorMessage;

  const InitResult({required this.dotenvLoaded, this.errorMessage});
}

/// Centralized initialization logic
class AppInitializer {
  AppInitializer._();

  /// Initialize all critical services before app runs
  static Future<InitResult> initializeCritical() async {
    try {
      // ✅ Step 1: Load .env file (ONLY PLACE IT'S LOADED)
      await dotenv.load(fileName: ".env");

      // ✅ Debug: Verify token loaded
      final token = dotenv.env['MAPBOX_ACCESS_TOKEN'];
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ AppInitializer: MAPBOX_ACCESS_TOKEN not found in .env');
        return const InitResult(
          dotenvLoaded: false,
          errorMessage: 'Missing MAPBOX_ACCESS_TOKEN in .env',
        );
      }

      debugPrint('✅ AppInitializer: .env loaded successfully');
      debugPrint(
        '✅ AppInitializer: Token starts with ${token.substring(0, 10)}...',
      );

      // ✅ Step 2: Initialize other services here if needed
      // e.g., Firebase, Analytics, SharedPreferences, etc.

      return const InitResult(dotenvLoaded: true);
    } catch (e) {
      debugPrint('❌ AppInitializer Error: $e');
      return InitResult(dotenvLoaded: false, errorMessage: e.toString());
    }
  }
}
