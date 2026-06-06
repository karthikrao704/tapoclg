import 'package:flutter/gestures.dart'; // Required for TapGestureRecognizer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth/auth_cubit.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth/auth_state.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/signup/signup_bloc.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/signup/signup_event.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/signup/signup_state.dart';
import 'package:tapovana_mobile_app/features/auth/data/auth_api_repository.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _obscurePassword = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 1. Fetch screen dimensions and set the breakpoint
    final size = MediaQuery.sizeOf(context);
    final bool isSmallScreen = size.height < 650;

    return BlocProvider(
      create: (context) => SignupBloc(AuthApiRepository()),
      child: MultiBlocListener(
        listeners: [
          // Email signup: OTP sent successfully
          BlocListener<SignupBloc, SignupState>(
            listener: (context, state) {
              if (state is SignupSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("OTP Sent Successfully")),
                );
                context.push(
                  RouteConstants.otp,
                  extra: {
                    'email': emailController.text.trim(),
                    'password': passwordController.text.trim(),
                  },
                );
              }
              if (state is SignupFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error)));
              }
            },
          ),
          // Google sign-in errors
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    // 2. Relative horizontal padding matching the login screen
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.06,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: isSmallScreen ? 10 : 15),
                        // 3. Responsive logo capped safely
                        Image.asset(
                          'assets/logo/logo.png',
                          width: size.width * 0.45 > 190
                              ? 190
                              : size.width * 0.45,
                        ),
                        SizedBox(height: isSmallScreen ? 5 : 10),
                        Text(
                          "Sign Up",
                          style: AppFonts.headland(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 8),
                        Text(
                          "Welcome to your sanctuary",
                          style: AppFonts.poppinsRegular(
                            color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 25 : 40),

                        // Email
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email",
                            style: AppFonts.poppinsSemiBold(
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: emailController,
                          style: AppFonts.poppinsRegular(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          decoration: InputDecoration(
                            hintText: "your@email.com",
                            hintStyle: AppFonts.poppinsRegular(
                              color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1E293B)
                                : AppColors.backgroundColor,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: isSmallScreen ? 12 : 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withAlpha(20)
                                    : const Color(0xFFE0E0E0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withAlpha(20)
                                    : const Color(0xFFE0E0E0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 30),

                        // Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Password",
                            style: AppFonts.poppinsSemiBold(
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          style: AppFonts.poppinsRegular(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            hintStyle: AppFonts.poppinsRegular(
                              color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1E293B)
                                : AppColors.backgroundColor,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: isSmallScreen ? 12 : 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withAlpha(20)
                                    : const Color(0xFFE0E0E0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withAlpha(20)
                                    : const Color(0xFFE0E0E0),
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: isSmallScreen ? 20 : 24,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 4 : 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: const Color(0xFF6B6B6B),
                                fontSize: isSmallScreen ? 11 : 13,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 5 : 10),

                        // Get OTP Button
                        BlocBuilder<SignupBloc, SignupState>(
                          builder: (context, state) {
                            final isLoading = state is SignupLoading;
                            return SizedBox(
                              width: double.infinity,
                              // 4. Removed hardcoded height restriction
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        context.read<SignupBloc>().add(
                                          SignupRequested(
                                            email: emailController.text.trim(),
                                            password: passwordController.text
                                                .trim(),
                                          ),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: AppColors.white,
                                  elevation: 3,
                                  // 5. Utilized minimumSize for text scaling flexibility
                                  minimumSize: Size(
                                    double.infinity,
                                    isSmallScreen ? 50 : 60,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        width: isSmallScreen ? 20 : 24,
                                        height: isSmallScreen ? 20 : 24,
                                        child: const CircularProgressIndicator(
                                          color: AppColors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        "Get OTP",
                                        style: AppFonts.poppinsSemiBold(
                                          fontSize: isSmallScreen ? 16 : 20,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: isSmallScreen ? 20 : 30),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                "OR CONNECT WITH",
                                style: AppFonts.poppinsMedium(
                                  fontSize: isSmallScreen ? 10 : 12,
                                  color: AppColors.primaryBlack40,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 20 : 30),

                        // Social Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                context.read<AuthCubit>().signInWithGoogle();
                              },
                              child: Container(
                                // 6. Scale down bounds for smaller devices
                                width: isSmallScreen ? 55 : 70,
                                height: isSmallScreen ? 55 : 70,
                                padding: EdgeInsets.all(
                                  isSmallScreen ? 10 : 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: Theme.of(context).brightness == Brightness.dark
                                      ? null
                                      : const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6,
                                          ),
                                        ],
                                ),
                                child: Image.asset('assets/images/google.png'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Apple
                            Container(
                              width: isSmallScreen ? 55 : 70,
                              height: isSmallScreen ? 55 : 70,
                              padding: EdgeInsets.all(isSmallScreen ? 10 : 14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: Theme.of(context).brightness == Brightness.dark
                                    ? null
                                    : const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                        ),
                                      ],
                              ),
                              child: Image.asset('assets/images/apple.png'),
                            ),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 20 : 30),

                        // 7. Replaced Row with Text.rich to eliminate the right-side overflow bug
                        Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: AppFonts.poppinsRegular(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            children: [
                              TextSpan(
                                text: "Log In",
                                style: AppFonts.poppinsSemiBold(
                                  color: AppColors.primaryColor,
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () =>
                                      context.push(RouteConstants.login),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: isSmallScreen ? 25 : 40),
                      ],
                    ),
                  ),
                ),

                // Google loading overlay
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Container(
                        color: Colors.black.withAlpha(30),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFC9A14A),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
