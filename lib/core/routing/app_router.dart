import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';
import 'package:tapovana_mobile_app/features/home_page/presentation/home_screen.dart';
import 'package:tapovana_mobile_app/features/services/presentation/service_screen.dart';
import 'package:tapovana_mobile_app/features/more/more_screen.dart';
import 'package:tapovana_mobile_app/features/profile/profile_screen.dart';

import 'package:tapovana_mobile_app/features/navigation/presentation/navigation.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => Navigation(child: child),
        routes: [
          GoRoute(
            path: RouteConstants.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteConstants.services,
            builder: (context, state) => const ServiceScreen(),
          ),
          GoRoute(
            path: RouteConstants.more,
            builder: (context, state) => const MoreScreen(),
          ),
          GoRoute(
            path: RouteConstants.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
