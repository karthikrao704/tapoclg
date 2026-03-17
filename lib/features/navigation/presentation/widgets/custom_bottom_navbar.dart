import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Resolve colors based on your mappings
    final activeColor = theme.colorScheme.primary;
    final inactiveColor =
        theme.textTheme.bodySmall?.color ?? theme.colorScheme.outline;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,

      // Theme Mappings
      backgroundColor: theme.scaffoldBackgroundColor,
      selectedItemColor: activeColor,
      unselectedItemColor: inactiveColor,
      selectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
        color: activeColor,
      ),
      unselectedLabelStyle: theme.textTheme.bodySmall,

      items: [
        _buildNavItem(
          assetPath: 'assets/icons/home_icon.svg',
          label: 'Home',
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
        _buildNavItem(
          assetPath: 'assets/icons/service_icon.svg',
          label: 'Services',
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
        _buildNavItem(
          assetPath: 'assets/icons/more_icon.svg',
          label: 'More',
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
        _buildNavItem(
          assetPath: 'assets/icons/profile_icon.svg',
          label: 'Profile',
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
      ],
    );
  }

  // Helper method to keep the code DRY and handle SVG coloring
  BottomNavigationBarItem _buildNavItem({
    required String assetPath,
    required String label,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        assetPath,
        colorFilter: ColorFilter.mode(inactiveColor, BlendMode.srcIn),
      ),
      activeIcon: SvgPicture.asset(
        assetPath,
        colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn),
      ),
      label: label,
    );
  }
}


