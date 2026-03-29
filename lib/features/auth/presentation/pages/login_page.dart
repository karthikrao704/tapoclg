import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth/auth_cubit.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth/auth_state.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/login/login_bloc.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/login/login_event.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/login/login_state.dart';
import 'package:tapovana_mobile_app/features/auth/data/auth_api_repository.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(AuthApiRepository()),
      child: MultiBlocListener(
        listeners: [
          // Email login listener
          BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Login Successful")),
                );
                // Notify AuthCubit → triggers redirect to Home
                context.read<AuthCubit>().onEmailLoginSuccess(state.data);
              }

              if (state is LoginNeeds2FA) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("2FA enabled. OTP sent to your email."),
                  ),
                );
                // Navigate to login 2FA OTP page
                context.push(
                  RouteConstants.login2faOtp,
                  extra: {'email': state.email, 'password': state.password},
                );
              }

              if (state is LoginFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error)));
              }
            },
          ),
          // Google sign-in listener
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
          backgroundColor: const Color(0xFFFFFFFF),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 15),
                        Image.asset('assets/logo/logo.png', width: 190),
                        const SizedBox(height: 10),
                        Text(
                          "Log In",
                          style: AppFonts.headland(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Welcome back to your sanctuary",
                          style: AppFonts.poppinsRegular(color: AppColors.primaryBlack40, fontSize: 14),
                        ),
                        const SizedBox(height: 40),

                        // Email
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email",
                            style: AppFonts.poppinsSemiBold(fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: "your@email.com",
                            hintStyle: AppFonts.poppinsRegular(
                              color: AppColors.primaryBlack40,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: AppColors.backgroundColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Password",
                            style: AppFonts.poppinsSemiBold(fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            hintStyle: AppFonts.poppinsRegular(
                              color: AppColors.primaryBlack40,
                            ),
                            filled: true,
                            fillColor: AppColors.backgroundColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color(0xFF6B6B6B),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Sign In Button
                        BlocBuilder<LoginBloc, LoginState>(
                          builder: (context, state) {
                            final isLoading = state is LoginLoading;
                            return SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        context.read<LoginBloc>().add(
                                          LoginRequested(
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: AppColors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        "Sign In",
                                        style: AppFonts.poppinsSemiBold(fontSize: 20),
                                      ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // Divider
                            Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "OR CONNECT WITH",
                                style: AppFonts.poppinsMedium(
                                  fontSize: 12,
                                  color: AppColors.primaryBlack40,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Social Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                context.read<AuthCubit>().signInWithGoogle();
                              },
                              child: Container(
                                width: 70,
                                height: 70,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
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
                            Container(
                              width: 70,
                              height: 70,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
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

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ", style: AppFonts.poppinsRegular()),
                            GestureDetector(
                              onTap: () => context.push(RouteConstants.signup),
                              child: Text(
                                "Sign Up",
                                style: AppFonts.poppinsSemiBold(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
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
