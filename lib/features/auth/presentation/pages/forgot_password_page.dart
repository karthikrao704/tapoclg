import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/forgot_password/forgot_password_cubit.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/forgot_password/forgot_password_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bool isSmallScreen = size.height < 650;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            if (_pageController.page == 0) {
              context.pop();
            } else {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
          listener: (context, state) {
            if (state is ForgotPasswordFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.redAccent),
              );
            } else if (state is ForgotPasswordOtpSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("OTP sent successfully to your email.")),
              );
              _nextPage();
            } else if (state is ForgotPasswordOtpVerified) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("OTP verified. Please enter your new password.")),
              );
              _nextPage();
            } else if (state is ForgotPasswordSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              context.pop(); // Go back to login
            }
          },
          builder: (context, state) {
            final isLoading = state is ForgotPasswordLoading;

            return PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Prevent manual swipe
              children: [
                _buildEmailStep(isSmallScreen, isLoading),
                _buildOtpStep(isSmallScreen, isLoading),
                _buildNewPasswordStep(isSmallScreen, isLoading),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmailStep(bool isSmallScreen, bool isLoading) {
    final size = MediaQuery.sizeOf(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isSmallScreen ? 10 : 20),
          Text(
            "Forgot Password",
            style: AppFonts.headland(
              fontSize: isSmallScreen ? 24 : 28,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            "Enter your registered email address to receive a password reset OTP.",
            style: AppFonts.poppinsRegular(
              color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          SizedBox(height: isSmallScreen ? 30 : 40),
          Text(
            "Email",
            style: AppFonts.poppinsSemiBold(fontSize: isSmallScreen ? 12 : 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppFonts.poppinsRegular(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            decoration: _inputDecoration("your@email.com", isSmallScreen),
          ),
          SizedBox(height: isSmallScreen ? 30 : 40),
          _buildSubmitButton(
            text: "Send OTP",
            isLoading: isLoading,
            isSmallScreen: isSmallScreen,
            onPressed: () {
              if (_emailController.text.trim().isNotEmpty) {
                context.read<ForgotPasswordCubit>().sendOtp(_emailController.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid email.")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(bool isSmallScreen, bool isLoading) {
    final size = MediaQuery.sizeOf(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isSmallScreen ? 10 : 20),
          Text(
            "Verify OTP",
            style: AppFonts.headland(
              fontSize: isSmallScreen ? 24 : 28,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            "Enter the 4-digit OTP sent to your email address.",
            style: AppFonts.poppinsRegular(
              color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          SizedBox(height: isSmallScreen ? 30 : 40),
          Text(
            "OTP",
            style: AppFonts.poppinsSemiBold(fontSize: isSmallScreen ? 12 : 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            style: AppFonts.poppinsRegular(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: isSmallScreen ? 14 : 16,
              letterSpacing: 4.0,
            ),
            decoration: _inputDecoration("", isSmallScreen).copyWith(
              counterText: "",
            ),
          ),
          SizedBox(height: isSmallScreen ? 30 : 40),
          _buildSubmitButton(
            text: "Verify OTP",
            isLoading: isLoading,
            isSmallScreen: isSmallScreen,
            onPressed: () {
              if (_otpController.text.trim().length == 4) {
                context.read<ForgotPasswordCubit>().verifyOtp(_otpController.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid 4-digit OTP.")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewPasswordStep(bool isSmallScreen, bool isLoading) {
    final size = MediaQuery.sizeOf(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isSmallScreen ? 10 : 20),
          Text(
            "Reset Password",
            style: AppFonts.headland(
              fontSize: isSmallScreen ? 24 : 28,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            "Enter a new password for your account.",
            style: AppFonts.poppinsRegular(
              color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          SizedBox(height: isSmallScreen ? 30 : 40),
          Text(
            "New Password",
            style: AppFonts.poppinsSemiBold(fontSize: isSmallScreen ? 12 : 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            style: AppFonts.poppinsRegular(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            decoration: _inputDecoration("••••••••", isSmallScreen).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: isSmallScreen ? 20 : 24,
                ),
                onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 30),
          Text(
            "Confirm New Password",
            style: AppFonts.poppinsSemiBold(fontSize: isSmallScreen ? 12 : 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: AppFonts.poppinsRegular(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            decoration: _inputDecoration("••••••••", isSmallScreen).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: isSmallScreen ? 20 : 24,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 30 : 40),
          _buildSubmitButton(
            text: "Reset Password",
            isLoading: isLoading,
            isSmallScreen: isSmallScreen,
            onPressed: () {
              final newPass = _newPasswordController.text.trim();
              final confirmPass = _confirmPasswordController.text.trim();

              if (newPass.isEmpty || confirmPass.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields.")),
                );
                return;
              }
              if (newPass != confirmPass) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Passwords do not match.")),
                );
                return;
              }
              if (newPass.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password must be at least 6 characters.")),
                );
                return;
              }

              context.read<ForgotPasswordCubit>().resetPassword(newPass);
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText, bool isSmallScreen) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppFonts.poppinsRegular(
        color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
        fontSize: isSmallScreen ? 12 : 14,
      ),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E293B)
          : AppColors.backgroundColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isSmallScreen ? 12 : 14),
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
    );
  }

  Widget _buildSubmitButton({
    required String text,
    required bool isLoading,
    required bool isSmallScreen,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.white,
          elevation: 3,
          minimumSize: Size(double.infinity, isSmallScreen ? 50 : 60),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: isLoading
            ? SizedBox(
                width: isSmallScreen ? 20 : 24,
                height: isSmallScreen ? 20 : 24,
                child: const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5),
              )
            : Text(
                text,
                style: AppFonts.poppinsSemiBold(fontSize: isSmallScreen ? 16 : 20),
              ),
      ),
    );
  }
}
