import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';
import 'package:tapovana_mobile_app/core/routing/go_router_refresh_stream.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth/auth_cubit.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth/auth_state.dart';

import 'package:tapovana_mobile_app/features/splash/splash_screen.dart';
import 'package:tapovana_mobile_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:tapovana_mobile_app/features/auth/presentation/pages/login_page.dart';
import 'package:tapovana_mobile_app/features/auth/presentation/pages/signup_page.dart';
import 'package:tapovana_mobile_app/features/auth/presentation/pages/otp_page.dart';
import 'package:tapovana_mobile_app/features/auth/presentation/pages/data_entry_page.dart';
import 'package:tapovana_mobile_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/forgot_password/forgot_password_cubit.dart';
import 'package:tapovana_mobile_app/features/auth/data/auth_api_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tapovana_mobile_app/features/home_page/presentation/home_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/body_care_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/hair_care_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/nail_care_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/skin_care_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/styling_makeover_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/service_screen.dart';
import 'package:tapovana_mobile_app/features/more/more_screen.dart';
import 'package:tapovana_mobile_app/features/navigation/presentation/navigation.dart';

import 'package:tapovana_mobile_app/features/profile/pages/profile_screen.dart';
import 'package:tapovana_mobile_app/features/profile/pages/personal_info_page.dart';
import 'package:tapovana_mobile_app/features/profile/pages/notification_settings_page.dart';
import 'package:tapovana_mobile_app/features/profile/pages/privacy_security_page.dart';
import 'package:tapovana_mobile_app/features/profile/pages/support_center_page.dart';

class AppRouter {
  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: RouteConstants.splash,
      refreshListenable: GoRouterRefreshStream(authCubit.stream),

      redirect: (context, state) {
        final authState = authCubit.state;
        final currentLocation = state.matchedLocation;

        final authRoutes = [
          RouteConstants.splash,
          RouteConstants.welcome,
          RouteConstants.login,
          RouteConstants.signup,
          RouteConstants.otp,
          RouteConstants.dataEntry,
          RouteConstants.login2faOtp,
          RouteConstants.googleDataEntry,
          RouteConstants.google2faOtp,
          RouteConstants.forgotPassword,
        ];

        final isAuthRoute = authRoutes.contains(currentLocation);
        final isSplash = currentLocation == RouteConstants.splash;

        final intermediateRoutes = [
          RouteConstants.otp,
          RouteConstants.dataEntry,
          RouteConstants.login2faOtp,
          RouteConstants.googleDataEntry,
          RouteConstants.google2faOtp,
        ];
        final isIntermediateRoute = intermediateRoutes.contains(
          currentLocation,
        );

        // Stay on splash ONLY during AuthInitial
        if (authState is AuthInitial) {
          return isSplash ? null : RouteConstants.splash;
        }

        if (authState is AuthLoading) return null;

        // Google NEW user → Data Entry
        if (authState is GoogleNewUser) {
          if (currentLocation == RouteConstants.googleDataEntry) return null;
          return RouteConstants.googleDataEntry;
        }

        // Google 2FA
        if (authState is GoogleNeeds2FA) {
          if (currentLocation == RouteConstants.google2faOtp) return null;
          return RouteConstants.google2faOtp;
        }

        // ✅ FIX: When Unauthenticated, redirect FROM splash TO welcome
        if (authState is Unauthenticated || authState is AuthError) {
          if (isSplash) return RouteConstants.welcome; // <-- THIS IS THE FIX
          if (isIntermediateRoute) return null;
          return isAuthRoute ? null : RouteConstants.welcome;
        }

        if (authState is Authenticated) {
          if (isAuthRoute) return RouteConstants.home;
        }

        return null;
      },

      routes: [
        GoRoute(
          path: RouteConstants.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RouteConstants.welcome,
          builder: (context, state) => const WelcomePage(),
        ),
        GoRoute(
          path: RouteConstants.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: RouteConstants.signup,
          builder: (context, state) => const SignupPage(),
        ),
        GoRoute(
          path: RouteConstants.forgotPassword,
          builder: (context, state) => BlocProvider(
            create: (context) => ForgotPasswordCubit(AuthApiRepository()),
            child: const ForgotPasswordPage(),
          ),
        ),

        // Email signup OTP
        GoRoute(
          path: RouteConstants.otp,
          builder: (context, state) {
            final extra = state.extra as Map<String, String>;
            return OtpPage(
              email: extra['email']!,
              password: extra['password']!,
              otpType: OtpType.emailSignup,
            );
          },
        ),

        // Email signup data entry
        GoRoute(
          path: RouteConstants.dataEntry,
          builder: (context, state) {
            final extra = state.extra as Map<String, String>;
            return DataEntryPage(
              email: extra['email']!,
              password: extra['password']!,
              authMethod: 'email',
            );
          },
        ),

        // Email login 2FA OTP
        GoRoute(
          path: RouteConstants.login2faOtp,
          builder: (context, state) {
            final extra = state.extra as Map<String, String>;
            return OtpPage(
              email: extra['email']!,
              password: extra['password']!,
              otpType: OtpType.emailLogin2FA,
            );
          },
        ),

        // Google data entry (NO OTP needed)
        GoRoute(
          path: RouteConstants.googleDataEntry,
          builder: (context, state) {
            final authState = authCubit.state;
            if (authState is GoogleNewUser) {
              return DataEntryPage(
                email: authState.user.email,
                password: '',
                authMethod: 'google',
                googleUser: authState.user,
                firebaseUid: authState.firebaseUid,
              );
            }
            return const WelcomePage();
          },
        ),

        // Google 2FA OTP
        GoRoute(
          path: RouteConstants.google2faOtp,
          builder: (context, state) {
            final authState = authCubit.state;
            if (authState is GoogleNeeds2FA) {
              return OtpPage(
                email: authState.email,
                password: '',
                otpType: OtpType.googleLogin2FA,
                googleUser: authState.user,
              );
            }
            return const WelcomePage();
          },
        ),

        // MAIN APP
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Navigation(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteConstants.home,
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteConstants.services,
                  builder: (context, state) => const ServiceScreen(),
                ),
                GoRoute(
                  path: RouteConstants.bodyCare,
                  builder: (context, state) => const BodyCareScreen(),
                ),
                GoRoute(
                  path: RouteConstants.skinCare,
                  builder: (context, state) => const SkinCareScreen(),
                ),
                GoRoute(
                  path: RouteConstants.hairCare,
                  builder: (context, state) => const HairCareScreen(),
                ),
                GoRoute(
                  path: RouteConstants.nailCare,
                  builder: (context, state) => const NailCareScreen(),
                ),
                GoRoute(
                  path: RouteConstants.styling,
                  builder: (context, state) => const StylingMakeoverScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteConstants.more,
                  builder: (context, state) => const MoreScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteConstants.profile,
                  builder: (context, state) => const ProfilePage(),
                  routes: [
                    GoRoute(
                      path: 'personal-info',
                      builder: (context, state) => const PersonalInfoPage(),
                    ),
                    GoRoute(
                      path: 'notification-settings',
                      builder: (context, state) =>
                          const NotificationSettingsPage(),
                    ),
                    GoRoute(
                      path: 'privacy-security',
                      builder: (context, state) => const PrivacySecurityPage(),
                    ),
                    GoRoute(
                      path: 'support-center',
                      builder: (context, state) => const SupportCenterPage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
