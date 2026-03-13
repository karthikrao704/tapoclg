import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/home_page/presentation/home_screen.dart';
import 'package:tapovana_mobile_app/features/more/more_screen.dart';
import 'package:tapovana_mobile_app/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:tapovana_mobile_app/features/navigation/presentation/widgets/custom_bottom_navbar.dart';
import 'package:tapovana_mobile_app/features/profile/profile_screen.dart';
import 'package:tapovana_mobile_app/features/services/service_screen.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // Placeholder widgets for each tab
    HomeScreen(),
    ServiceScreen(),
    MoreScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        greetingMessage: "Good Morning",
        userName: "Shelton Coutinho",
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
