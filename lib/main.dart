// lib/main.dart

import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/routing/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tapovana',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Theme(data: AppTheme.getLightTheme(context), child: child!);
      },
      routerConfig: AppRouter.router,
    );
  }
}