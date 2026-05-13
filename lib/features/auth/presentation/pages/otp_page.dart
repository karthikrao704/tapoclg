import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth/auth_cubit.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth/auth_state.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/login/login_bloc.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/login/login_event.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/login/login_state.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/otp/otp_bloc.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/otp/otp_event.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/otp/otp_state.dart';
import 'package:tapovana_mobile_app/features/auth/data/auth_api_repository.dart';
import 'package:tapovana_mobile_app/features/auth/domain/entities/app_user.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

enum OtpType { emailSignup, emailLogin2FA, googleLogin2FA }

class OtpPage extends StatefulWidget {
  final String email;
  final String password;
  final OtpType otpType;
  final AppUser? googleUser;

  const OtpPage({
    super.key,
    required this.email,
    required this.password,
    required this.otpType,
    this.googleUser,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  String get _getOtp => otpControllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OtpBloc(AuthApiRepository())),
        BlocProvider(create: (_) => LoginBloc(AuthApiRepository())),
      ],
      child: MultiBlocListener(
        listeners: [
          // Email signup OTP verified → go to data entry
          BlocListener<OtpBloc, OtpState>(
            listener: (context, state) {
              if (state is OtpSuccess) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("OTP Verified")));
                context.push(
                  RouteConstants.dataEntry,
                  extra: {'email': widget.email, 'password': widget.password},
                );
              }
              if (state is OtpFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error)));
              }
            },
          ),

          // Email login 2FA verified → home
          BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is Login2FASuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Login Successful")),
                );
                context.read<AuthCubit>().onLogin2FASuccess(state.data);
              }
              if (state is LoginFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error)));
              }
            },
          ),

          // Google 2FA (AuthCubit handles it)
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  0,
                  24,
                  MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 120),
                    Image.asset('assets/logo/logo.png', width: 200),
                    const SizedBox(height: 20),
                    Text(
                      "Confirm Your Code",
                      style: AppFonts.headland(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Enter the code we sent to ${widget.email}",
                      textAlign: TextAlign.center,
                      style: AppFonts.poppinsRegular(
                        color: AppColors.primaryBlack40,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // OTP Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        4,
                        (index) => SizedBox(
                          width: 40,
                          child: TextField(
                            controller: otpControllers[index],
                            focusNode: focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 3) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(focusNodes[index + 1]);
                              } else if (value.isEmpty && index > 0) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(focusNodes[index - 1]);
                              } else if (value.isNotEmpty && index == 3) {
                                FocusScope.of(context).unfocus();
                              }
                            },
                            decoration: const InputDecoration(
                              counterText: "",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black54),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 70),

                    // Verify Button
                    _buildVerifyButton(context),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    switch (widget.otpType) {
      case OtpType.emailSignup:
        return BlocBuilder<OtpBloc, OtpState>(
          builder: (context, state) {
            return _verifyButton(
              isLoading: state is OtpLoading,
              onPressed: () {
                context.read<OtpBloc>().add(
                  VerifyOtpRequested(email: widget.email, otp: _getOtp),
                );
              },
            );
          },
        );

      case OtpType.emailLogin2FA:
        return BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return _verifyButton(
              isLoading: state is LoginLoading,
              onPressed: () {
                context.read<LoginBloc>().add(
                  LoginOtpVerifyRequested(email: widget.email, otp: _getOtp),
                );
              },
            );
          },
        );

      case OtpType.googleLogin2FA:
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return _verifyButton(
              isLoading: state is AuthLoading,
              onPressed: () {
                context.read<AuthCubit>().verifyGoogle2FA(
                  email: widget.email,
                  otp: _getOtp,
                  user: widget.googleUser!,
                );
              },
            );
          },
        );
    }
  }

  Widget _verifyButton({
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      // 1. Removed the strict height limit here
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.white,
          // 2. Set a minimum bounds so it defaults to 60px but can grow
          minimumSize: const Size(double.infinity, 60),
          // 3. Define explicit vertical padding to structure the text
          padding: const EdgeInsets.symmetric(vertical: 14),
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
            : Text("Verify", style: AppFonts.poppinsSemiBold(fontSize: 18)),
      ),
    );
  }
}
