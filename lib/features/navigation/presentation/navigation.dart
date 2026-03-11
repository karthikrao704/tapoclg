import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';
import 'package:tapovana_mobile_app/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:tapovana_mobile_app/features/navigation/presentation/widgets/custom_bottom_navbar.dart';

class Navigation extends StatelessWidget {
  final Widget child;
  const Navigation({super.key, required this.child});

  static const List<String> _routes = [
    RouteConstants.home,
    RouteConstants.services,
    RouteConstants.more,
    RouteConstants.profile,
  ];

  int _routeToIndex(String location) {
    final idx = _routes.indexWhere((r) => location.startsWith(r));
    return idx >= 0 ? idx : 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _routeToIndex(location);

    // Evaluate if the current route is the services page
    final showMainAppBar = location.startsWith(RouteConstants.services);

    return Scaffold(
      appBar: showMainAppBar
          ? null
          : CustomAppBar(
              greetingMessage: "Good Morning",
              userName: "Shelton Coutinho",
            ),
      body: child,
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: selectedIndex,
        onTap: (index) {
          context.go(_routes[index]);
        },
      ),
    );
  }
}
