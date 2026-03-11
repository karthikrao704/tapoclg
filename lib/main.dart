import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/splash/splash_screen.dart';


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

      /// Start with Splash Screen
      home: const SplashScreen(),
    );
  }
}