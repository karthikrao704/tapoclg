// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/routing/app_router.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth_cubit.dart';
import 'package:tapovana_mobile_app/features/auth/data/firebase_auth_repo.dart';
import 'package:tapovana_mobile_app/features/auth/domain/repos/auth_repository.dart';
import 'package:tapovana_mobile_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = AuthRepositoryImpl();

  runApp(MyApp(authRepository: authRepository));
}

// 1. Change MyApp to a StatefulWidget
class MyApp extends StatefulWidget {
  final AuthRepository authRepository;

  const MyApp({super.key, required this.authRepository});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 2. Declare your Cubit and Router as late final variables
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // 3. Initialize them exactly ONCE when the app starts
    _authCubit = AuthCubit(authRepository: widget.authRepository);
    _router = AppRouter.createRouter(_authCubit);
  }

  @override
  void dispose() {
    // 4. Clean up the cubit when the app is destroyed
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5. Use BlocProvider.value since we are managing the Cubit's lifecycle manually in this state
    return BlocProvider.value(
      value: _authCubit,
      child: MaterialApp.router(
        title: 'Tapovana',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Theme(data: AppTheme.getLightTheme(context), child: child!);
        },
        // 6. Pass the cached router instance!
        routerConfig: _router,
      ),
    );
  }
}
