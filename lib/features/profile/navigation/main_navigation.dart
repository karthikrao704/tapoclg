import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/profile/pages/profile/profile_screen.dart';
import '../pages/personal_info/personal_info_page.dart';
import '../pages/notification_settings/notification_settings_page.dart';
import '../pages/privacy_security/privacy_security_page.dart';
import '../pages/support_center/support_center_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 3;

  final List<Widget> _pages = [
    const ProfilePage(),
    const PersonalInfoPage(),
    const NotificationSettingsPage(),
    const PrivacySecurityPage(),
    const SupportCenterPage(),
  ];

  final List<BottomNavigationBarItem> _bottomNavBarItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.spa_outlined),
      activeIcon: Icon(Icons.spa),
      label: 'Services',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.credit_card_outlined),
      activeIcon: Icon(Icons.credit_card),
      label: 'More',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: _bottomNavBarItems,
        selectedItemColor: const Color(0xFFCFA644), // Exact Gold
        unselectedItemColor: const Color(0xFF333333), // Darker grey
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, fontFamily: 'Poppins'),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13, fontFamily: 'Poppins'),
      ),
    );
  }
}