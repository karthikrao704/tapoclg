// lib/core/routing/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';

// Auth flow screens
import 'package:tapovana_mobile_app/features/splash/splash_screen.dart';
import 'package:tapovana_mobile_app/features/auth/pages/welcome_page.dart';
import 'package:tapovana_mobile_app/features/auth/pages/login_page.dart';
import 'package:tapovana_mobile_app/features/auth/pages/signup_page.dart';
import 'package:tapovana_mobile_app/features/auth/pages/data_entry_page.dart';

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
import 'package:tapovana_mobile_app/features/profile/pages/profile/profile_screen.dart';
import 'package:tapovana_mobile_app/features/profile/pages/personal_info/personal_info_page.dart';
import 'package:tapovana_mobile_app/features/profile/pages/notification_settings/notification_settings_page.dart';
import 'package:tapovana_mobile_app/features/profile/pages/privacy_security/privacy_security_page.dart';
import 'package:tapovana_mobile_app/features/profile/pages/support_center/support_center_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.splash,
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