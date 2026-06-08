import 'package:flutter/gestures.dart';
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
    // 1. Fetch screen dimensions and set a breakpoint
    final size = MediaQuery.sizeOf(context);
    final bool isSmallScreen = size.height < 650;

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
                context.read<AuthCubit>().onEmailLoginSuccess(state.data);
              }

              if (state is LoginNeeds2FA) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("2FA enabled. OTP sent to your email."),
                  ),
                );
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    // 2. Responsive horizontal padding
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.06,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: isSmallScreen ? 10 : 15),
                        // 3. Responsive logo sizing capped at 190px
                        Image.asset(
                          'assets/logo/logo.png',
                          width: size.width * 0.45 > 190
                              ? 190
                              : size.width * 0.45,
                        ),
                        SizedBox(height: isSmallScreen ? 5 : 10),
                        Text(
                          "Log In",
                          style: AppFonts.headland(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 8),
                        Text(
                          "Welcome back to your sanctuary",
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
                            onPressed: () => _showForgotPasswordDialog(context),
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

                        // Sign In Button
                        BlocBuilder<LoginBloc, LoginState>(
                          builder: (context, state) {
                            final isLoading = state is LoginLoading;
                            return SizedBox(
                              width: double.infinity,
                              // 4. Removed strict height, used minimumSize in style
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
                                  // 5. Use minimumSize so it can expand if text scales
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
                                        "Sign In",
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
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                context.read<AuthCubit>().signInWithGoogle();
                              },
                              child: Container(
                                // 6. Scale down social buttons on small screens
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

                        Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: AppFonts.poppinsRegular(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Theme.of(context).colorScheme.onSurface, // Ensure default color is set
                            ),
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: AppFonts.poppinsSemiBold(
                                  color: AppColors.primaryColor,
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                                // Recognizer handles the tap event inside the text flow
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () =>
                                      context.push(RouteConstants.signup),
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

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ForgotPasswordDialog(apiRepository: AuthApiRepository());
      },
    );
  }
}

class ForgotPasswordDialog extends StatefulWidget {
  final AuthApiRepository apiRepository;
  const ForgotPasswordDialog({super.key, required this.apiRepository});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  int _currentStep = 1; // 1: Email, 2: OTP, 3: New Password
  bool _isLoading = false;
  String _errorMessage = '';
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final res = await widget.apiRepository.sendForgotPasswordOtp(email: email);
      if (res['success'] == true) {
        setState(() {
          _currentStep = 2;
        });
      } else {
        setState(() => _errorMessage = res['message'] ?? 'Failed to send OTP.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter a 6-digit OTP.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final res = await widget.apiRepository.verifyForgotPasswordOtp(email: email, otp: otp);
      if (res['success'] == true) {
        setState(() {
          _currentStep = 3;
        });
      } else {
        setState(() => _errorMessage = res['message'] ?? 'Invalid OTP.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final newPass = _passwordController.text.trim();
    if (newPass.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final res = await widget.apiRepository.resetPassword(email: email, newPassword: newPass);
      if (res['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset successful. Please login.')),
          );
          Navigator.of(context).pop();
        }
      } else {
        setState(() => _errorMessage = res['message'] ?? 'Failed to reset password.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      title: Text(
        _currentStep == 1 
            ? 'Forgot Password' 
            : (_currentStep == 2 ? 'Verify OTP' : 'Reset Password'),
        style: AppFonts.headland(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 20,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.bottom(12.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
              
            if (_currentStep == 1) ...[
              Text(
                'Enter your registered email address and we will send you an OTP to reset your password.',
                style: AppFonts.poppinsRegular(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'your@email.com',
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else if (_currentStep == 2) ...[
              Text(
                'Enter the 6-digit OTP code sent to ${_emailController.text}.',
                style: AppFonts.poppinsRegular(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 8,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
                    letterSpacing: 8,
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else ...[
              Text(
                'Set a new secure password for your account.',
                style: AppFonts.poppinsRegular(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'New Password',
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  if (_currentStep == 1) {
                    _sendOtp();
                  } else if (_currentStep == 2) {
                    _verifyOtp();
                  } else {
                    _resetPassword();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(_currentStep == 1 ? 'Send OTP' : (_currentStep == 2 ? 'Verify' : 'Reset')),
        ),
      ],
    );
  }
}
