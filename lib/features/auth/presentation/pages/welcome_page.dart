import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool isCreateSelected = true;

  @override
  Widget build(BuildContext context) {
    // 1. Fetch screen dimensions to calculate relative sizes
    final size = MediaQuery.sizeOf(context);

    // 2. Define a breakpoint for small screens (e.g., iPhone SE is ~667px height)
    final bool isSmallScreen = size.height < 650;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_signin.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            // 3. SingleChildScrollView acts as a safeguard against pixel overflow
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                // 4. Responsive padding relative to screen size
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.04,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                // 5. SafeArea ensures content isn't hidden by device bezels or home indicators
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 6. Scale logo based on screen width, capped at 250px
                      Image.asset(
                        'assets/logo/logo.png',
                        width: size.width * 0.6 > 250 ? 250 : size.width * 0.6,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 18),
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 50 : 60,
                        child: ElevatedButton(
                          onPressed: () => context.push(RouteConstants.signup),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: AppColors.white,
                            // 1. Remove default padding to maximize internal space
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          // 2. Wrap Text in FittedBox to auto-scale down on overflow
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                "Create Account",
                                style: AppFonts.poppinsSemiBold(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  height:
                                      1.2, // 3. Explicitly set a tight line-height
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 18),
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 50 : 60,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => isCreateSelected = false);
                            context.push(RouteConstants.login);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isCreateSelected
                                ? AppColors.primaryColor
                                : AppColors.white,
                            foregroundColor: !isCreateSelected
                                ? AppColors.white
                                : AppColors.primaryColor,
                            elevation: !isCreateSelected ? 3 : 0,
                            side: const BorderSide(
                              color: AppColors.primaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                "Log In",
                                style: AppFonts.poppinsMedium(
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 30),
                      Text(
                        "By continuing, you agree to our Terms of Service and Privacy Policy.",
                        textAlign: TextAlign.center,
                        style: AppFonts.poppinsRegular(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: AppColors.primaryBlack40,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 5 : 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
