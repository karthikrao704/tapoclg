import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/features/auth/data/auth_api_repository.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthApiRepository authRepository;
  String? _email;
  String? _otp;

  ForgotPasswordCubit(this.authRepository) : super(ForgotPasswordInitial());

  String? get currentEmail => _email;

  Future<void> sendOtp(String email) async {
    emit(ForgotPasswordLoading());
    try {
      final response = await authRepository.sendForgotPasswordOtp(email: email);
      if (response['success'] == true) {
        _email = email;
        emit(ForgotPasswordOtpSent(email));
      } else {
        emit(ForgotPasswordFailure(response['message'] ?? 'Failed to send OTP.'));
      }
    } catch (e) {
      emit(ForgotPasswordFailure('An error occurred. Please try again.'));
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (_email == null) {
      emit(const ForgotPasswordFailure('Email is missing. Please restart the process.'));
      return;
    }
    emit(ForgotPasswordLoading());
    try {
      final response = await authRepository.verifyForgotPasswordOtp(email: _email!, otp: otp);
      if (response['success'] == true) {
        _otp = otp;
        emit(ForgotPasswordOtpVerified(_email!, otp));
      } else {
        emit(ForgotPasswordFailure(response['message'] ?? 'Failed to verify OTP.'));
      }
    } catch (e) {
      emit(ForgotPasswordFailure('An error occurred. Please try again.'));
    }
  }

  Future<void> resetPassword(String newPassword) async {
    if (_email == null) {
      emit(const ForgotPasswordFailure('Email is missing. Please restart the process.'));
      return;
    }
    emit(ForgotPasswordLoading());
    try {
      final response = await authRepository.resetPassword(email: _email!, newPassword: newPassword);
      if (response['success'] == true) {
        emit(ForgotPasswordSuccess(response['message'] ?? 'Password reset successfully.'));
      } else {
        emit(ForgotPasswordFailure(response['message'] ?? 'Failed to reset password.'));
      }
    } catch (e) {
      emit(ForgotPasswordFailure('An error occurred. Please try again.'));
    }
  }
}
