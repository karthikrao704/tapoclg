import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/features/auth/data/auth_api_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthApiRepository authRepository;

  LoginBloc(this.authRepository) : super(LoginInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LoginOtpVerifyRequested>(_onLoginOtpVerify);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      final response = await authRepository.login(
        email: event.email,
        password: event.password,
      );

      if (response["success"] == true) {
        if (response["requires_otp"] == true) {
          // 2FA is ON → needs OTP verification
          emit(LoginNeeds2FA(
            email: event.email,
            password: event.password,
          ));
        } else {
          // 2FA is OFF → direct login
          emit(LoginSuccess(response));
        }
      } else {
        emit(LoginFailure(response["message"] ?? "Login failed"));
      }
    } catch (e) {
      emit(LoginFailure("Something went wrong"));
    }
  }

  Future<void> _onLoginOtpVerify(
    LoginOtpVerifyRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      final response = await authRepository.verifyLoginOtp(
        email: event.email,
        otp: event.otp,
      );

      if (response["success"] == true) {
        emit(Login2FASuccess(response));
      } else {
        emit(LoginFailure(response["message"] ?? "OTP verification failed"));
      }
    } catch (e) {
      emit(LoginFailure("Something went wrong"));
    }
  }
}