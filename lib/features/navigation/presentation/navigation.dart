import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';
import 'package:tapovana_mobile_app/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:tapovana_mobile_app/features/navigation/presentation/widgets/custom_bottom_navbar.dart';

class Navigation extends StatelessWidget {
  // 1. Change from `Widget child` to `StatefulNavigationShell`
  final StatefulNavigationShell navigationShell;

  const Navigation({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    final exactPathsWithAppBar = [
      RouteConstants.home,
      RouteConstants.more,
    ];

    final shouldShowAppBar = exactPathsWithAppBar.contains(location);

    return Scaffold(
      appBar: shouldShowAppBar
          ? const CustomAppBar(
              greetingMessage: "Good Morning",
              userName: "Shelton Coutinho",
            )
          : null,
      // 2. The body is simply the shell itself
      body: navigationShell,
      bottomNavigationBar: CustomBottomNavbar(
        // 3. Use the shell's built-in index manager
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          // 4. Use goBranch instead of context.go()
          navigationShell.goBranch(
            index,
            // Highly recommended: restores branch to its initial location
            // if tapping the currently active tab.
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
