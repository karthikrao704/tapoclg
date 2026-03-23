import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/features/auth/data/auth_api_repository.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthApiRepository authRepository;

  SignupBloc(this.authRepository) : super(SignupInitial()) {
    on<SignupRequested>((event, emit) async {
      emit(SignupLoading());

      try {
        final response = await authRepository.sendSignupOtp(
          email: event.email,
          password: event.password,
        );

        if (response["success"] == true) {
          emit(SignupSuccess(response));
        } else {
          emit(SignupFailure(response["message"] ?? "Failed to send OTP"));
        }
      } catch (e) {
        emit(SignupFailure("Something went wrong"));
      }
    });
  }
}