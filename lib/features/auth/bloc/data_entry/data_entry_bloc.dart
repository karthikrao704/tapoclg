import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/features/auth/data/auth_api_repository.dart';
import 'data_entry_event.dart';
import 'data_entry_state.dart';

class DataEntryBloc extends Bloc<DataEntryEvent, DataEntryState> {
  final AuthApiRepository authRepository;

  DataEntryBloc(this.authRepository) : super(DataEntryInitial()) {
    on<SubmitDataEntry>(_onSubmitDataEntry);
  }

  /// Works for BOTH email and Google users
  /// Backend sees the same request regardless of auth method
  Future<void> _onSubmitDataEntry(
    SubmitDataEntry event,
    Emitter<DataEntryState> emit,
  ) async {
    emit(DataEntryLoading());

    try {
      // Step 1: Complete signup on backend
      // For email users: password = their real password
      // For Google users: password = "Google_<firebaseUID>"
      final response = await authRepository.completeSignup(
        email: event.email,
        password: event.password,
        name: event.name,
        gender: event.gender,
        city: event.city,
      );

      print("COMPLETE SIGNUP RESPONSE: $response");

      if (response['success'] == true) {
        // Step 2: Auto-login using same credentials
        final loginResponse = await authRepository.login(
          email: event.email,
          password: event.password,
        );

        print("AUTO LOGIN RESPONSE: $loginResponse");

        if (loginResponse['success'] == true &&
            loginResponse['requires_otp'] != true) {
          emit(DataEntrySuccess(
            loginData: loginResponse,
            authMethod: event.authMethod,
          ));
        } else {
          emit(DataEntryFailure("Signup done but auto-login failed"));
        }
      } else {
        emit(DataEntryFailure(response['message'] ?? 'Signup failed'));
      }
    } catch (e) {
      emit(DataEntryFailure(e.toString()));
    }
  }
}