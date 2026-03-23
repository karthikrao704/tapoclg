abstract class LoginEvent {}

class LoginRequested extends LoginEvent {
  final String email;
  final String password;

  LoginRequested({
    required this.email,
    required this.password,
  });
}

/// For verifying 2FA OTP during email login
class LoginOtpVerifyRequested extends LoginEvent {
  final String email;
  final String otp;

  LoginOtpVerifyRequested({
    required this.email,
    required this.otp,
  });
}