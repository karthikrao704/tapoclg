// lib/features/auth/pages/welcome_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool isCreateSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_signin.png',
              fit: BoxFit.cover,
            ),
          ),

          /// BOTTOM CARD
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 30,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// LOGO
                  Image.asset(
                    'assets/logo/logo.png',
                    width: 250,
                  ),
                  const SizedBox(height: 18),

                  /// CREATE ACCOUNT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // ✅ Changed from Navigator.push to go_router
                        context.push(RouteConstants.signup);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9A14A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isCreateSelected = false;
                        });

                        // ✅ Changed from Navigator.push to go_router
                        context.push(RouteConstants.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isCreateSelected
                            ? const Color(0xFFC9A14A)
                            : Colors.white,
                        foregroundColor: !isCreateSelected
                            ? Colors.white
                            : const Color(0xFFC9A14A),
                        elevation: !isCreateSelected ? 3 : 0,
                        side: const BorderSide(
                          color: Color(0xFFC9A14A),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// TERMS TEXT
                  const Text(
                    "By continuing, you agree to our Terms of Service and Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}