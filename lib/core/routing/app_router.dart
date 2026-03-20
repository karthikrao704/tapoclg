// lib/core/routing/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth_cubit.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth_state.dart';

// Auth flow screens
import 'package:tapovana_mobile_app/features/splash/splash_screen.dart';
import 'package:tapovana_mobile_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:tapovana_mobile_app/features/auth/presentation/pages/login_page.dart';
import 'package:tapovana_mobile_app/features/auth/presentation/pages/signup_page.dart';
import 'package:tapovana_mobile_app/features/auth/presentation/pages/data_entry_page.dart';

// Main app screens
import 'package:tapovana_mobile_app/features/home_page/presentation/home_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/body_care_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/hair_care_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/nail_care_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/skin_care_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/styling_makeover_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/service_screen.dart';
import 'package:tapovana_mobile_app/features/more/more_screen.dart';
import 'package:tapovana_mobile_app/features/navigation/presentation/navigation.dart';

// Profile screens
import 'package:tapovana_mobile_app/features/profile/pages/profile_screen.dart';
import 'package:tapovana_mobile_app/features/profile/pages/personal_info_page.dart';
import 'package:tapovana_mobile_app/features/profile/pages/notification_settings_page.dart';
import 'package:tapovana_mobile_app/features/profile/pages/privacy_security_page.dart';
import 'package:tapovana_mobile_app/features/profile/pages/support_center_page.dart';

import 'go_router_refresh_stream.dart';

class AppRouter {
  // Converted to a method to accept the AuthCubit
  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: RouteConstants.splash,

      // 1. Re-evaluate routes whenever AuthCubit emits a new state
      refreshListenable: GoRouterRefreshStream(authCubit.stream),

      // 2. Global redirect logic (Auth Guards)
      redirect: (context, state) {
        final authState = authCubit.state;

        // Define which routes are meant for unauthenticated users
        final isAuthRoute = [
          RouteConstants.splash,
          RouteConstants.welcome,
          RouteConstants.login,
          RouteConstants.signup,
          RouteConstants.dataEntry,
        ].contains(state.matchedLocation);

        // State 1: App is booting up. Go to Splash to hide the transition.
        if (authState is AuthInitial) {
          return state.matchedLocation == RouteConstants.splash
              ? null
              : RouteConstants.splash;
        }

        // State 2: Active login/logout in progress.
        // Do NOTHING (return null). Let the current page display its own loading UI.
        if (authState is AuthLoading) {
          return null;
        }

        // State 3: User is NOT authenticated
        if (authState is Unauthenticated || authState is AuthError) {
          // If they try to access a protected route (e.g. Home), send them to Welcome
          return isAuthRoute ? null : RouteConstants.welcome;
        }

        // State 4: User IS authenticated
        if (authState is Authenticated) {
          // If they are on an auth route (Splash, Login, etc.), send them Home
          if (isAuthRoute) {
            return RouteConstants.home;
          }
        }

        // No redirection needed
        return null;
      },

      routes: [
        // ==========================================
        // AUTH FLOW (outside bottom navigation)
        // ==========================================
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
          path: RouteConstants.dataEntry,
          builder: (context, state) => const DataEntryPage(),
        ),

        // ==========================================
        // MAIN APP (with bottom navigation)
        // ==========================================
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Navigation(navigationShell: navigationShell);
          },
          branches: [
            // --- Branch 0: Home ---
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteConstants.home,
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),

            // --- Branch 1: Services ---
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

            // --- Branch 2: More ---
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteConstants.more,
                  builder: (context, state) => const MoreScreen(),
                ),
              ],
            ),

            // --- Branch 3: Profile ---
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
