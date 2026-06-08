import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/app_initializer.dart';
import 'package:tapovana_mobile_app/core/storage/secure_storage.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/routing/app_router.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth/auth_cubit.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth/auth_state.dart';
import 'package:tapovana_mobile_app/features/auth/data/auth_api_repository.dart';
import 'package:tapovana_mobile_app/features/auth/data/firebase_auth_repo.dart';
import 'package:tapovana_mobile_app/features/profile/bloc/profile/profile_bloc.dart';
import 'package:tapovana_mobile_app/features/profile/bloc/profile/profile_event.dart';
import 'package:tapovana_mobile_app/firebase_options.dart';
import 'package:tapovana_mobile_app/core/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final initResult = await AppInitializer.initializeCritical();
  if (!initResult.dotenvLoaded) {
    debugPrint('⚠️ Initialization failed: ${initResult.errorMessage}');
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firebaseAuthRepo = FirebaseAuthRepository();
  final apiAuthRepo = AuthApiRepository();
  final secureStorage = SecureStorage();

  runApp(MyApp(
    firebaseAuthRepo: firebaseAuthRepo,
    apiAuthRepo: apiAuthRepo,
    secureStorage: secureStorage,
  ));
}

class MyApp extends StatefulWidget {
  final FirebaseAuthRepository firebaseAuthRepo;
  final AuthApiRepository apiAuthRepo;
  final SecureStorage secureStorage;

  const MyApp({
    super.key,
    required this.firebaseAuthRepo,
    required this.apiAuthRepo,
    required this.secureStorage,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(
      firebaseAuthRepo: widget.firebaseAuthRepo,
      apiAuthRepo: widget.apiAuthRepo,
      secureStorage: widget.secureStorage,
    );
    _router = AppRouter.createRouter(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider(create: (context) => ProfileBloc()..add(LoadProfile())),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final isDark = themeMode == ThemeMode.dark;
          return BlocListener<AuthCubit, AuthState>(
            listener: (context, authState) {
              if (authState is Authenticated) {
                context.read<ProfileBloc>().add(LoadProfile());
              }
            },
            child: MaterialApp.router(
              title: 'Tapovana',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.getLightTheme(context),
              darkTheme: AppTheme.getDarkTheme(context),
              themeMode: themeMode,
              builder: (context, child) {
                return Theme(
                  data: isDark
                      ? AppTheme.getDarkTheme(context)
                      : AppTheme.getLightTheme(context),
                  child: child!,
                );
              },
              routerConfig: _router,
            ),
          );
        },
      ),
    );
  }
}