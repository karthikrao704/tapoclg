import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordOtpSent extends ForgotPasswordState {
  final String email;
  const ForgotPasswordOtpSent(this.email);

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordOtpVerified extends ForgotPasswordState {
  final String email;
  final String otp;
  const ForgotPasswordOtpVerified(this.email, this.otp);

  @override
  List<Object?> get props => [email, otp];
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;
  const ForgotPasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String error;
  const ForgotPasswordFailure(this.error);

  @override
  List<Object?> get props => [error];
}
