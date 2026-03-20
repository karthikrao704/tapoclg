import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/app_initializer.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/routing/app_router.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth_cubit.dart';
import 'package:tapovana_mobile_app/features/auth/data/firebase_auth_repo.dart';
import 'package:tapovana_mobile_app/features/auth/domain/repos/auth_repository.dart';
import 'package:tapovana_mobile_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dotenv and other critical services
  final initResult = await AppInitializer.initializeCritical();
  if (!initResult.dotenvLoaded) {
    debugPrint('⚠️ Initialization failed: ${initResult.errorMessage}');
  }

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = AuthRepositoryImpl();

  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatefulWidget {
  final AuthRepository authRepository;

  const MyApp({super.key, required this.authRepository});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(authRepository: widget.authRepository);
    _router = AppRouter.createRouter(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: MaterialApp.router(
        title: 'Tapovana',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Theme(data: AppTheme.getLightTheme(context), child: child!);
        },
        routerConfig: _router,
      ),
    );
  }
}