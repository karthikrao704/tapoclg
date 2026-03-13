import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';
import 'package:tapovana_mobile_app/features/home_page/presentation/home_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/body_care_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/hair_care_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/nail_care_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/skin_care_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/styling_makeover_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/service_screen.dart';
import 'package:tapovana_mobile_app/features/more/more_screen.dart';
import 'package:tapovana_mobile_app/features/profile/profile_screen.dart';
import 'package:tapovana_mobile_app/features/navigation/presentation/navigation.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Pass the navigationShell instead of the child widget
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
              // Sub-pages kept in the Services branch to maintain bottom nav state
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
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
