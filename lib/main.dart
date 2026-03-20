// lib/main.dart

import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/app_initializer.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/routing/app_router.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    final initResult = await AppInitializer.initializeCritical();
     if (!initResult.dotenvLoaded) {
    debugPrint('⚠️ Initialization failed: ${initResult.errorMessage}');
  }


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