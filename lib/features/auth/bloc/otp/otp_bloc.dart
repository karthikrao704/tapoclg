import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/features/auth/data/auth_api_repository.dart';
import 'otp_event.dart';
import 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final AuthApiRepository authRepository;

  OtpBloc(this.authRepository) : super(OtpInitial()) {
    on<VerifyOtpRequested>((event, emit) async {
      emit(OtpLoading());

      try {
        final response = await authRepository.verifySignupOtp(
          email: event.email,
          otp: event.otp,
        );

        if (response["success"] == true) {
          emit(OtpSuccess(response));
        } else {
          emit(OtpFailure(response["message"] ?? "OTP verification failed"));
        }
      } catch (e) {
        emit(OtpFailure("Something went wrong"));
      }
    });
  }
}