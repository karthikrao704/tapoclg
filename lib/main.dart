import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/features/navigation/presentation/navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tapovana',
      debugShowCheckedModeBanner: false,

      // --- Theme ---
      theme: AppTheme.lightTheme,

      home: Navigation(),
    );
  }
}
