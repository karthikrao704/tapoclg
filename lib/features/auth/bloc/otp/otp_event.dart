abstract class OtpEvent {}

class VerifyOtpRequested extends OtpEvent {
  final String email;
  final String otp;

  VerifyOtpRequested({
    required this.email,
    required this.otp,
  });
}