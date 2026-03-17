import 'package:flutter_bloc/flutter_bloc.dart';
import 'privacy_security_event.dart';
import 'privacy_security_state.dart';

class PrivacySecurityBloc extends Bloc<PrivacySecurityEvent, PrivacySecurityState> {
  PrivacySecurityBloc() : super(const PrivacySecurityState()) {
    on<LoadPrivacySettings>(_onLoadPrivacySettings);
    on<UpdatePrivacySettings>(_onUpdatePrivacySettings);
    on<ChangePassword>(_onChangePassword);
  }

  Future<void> _onLoadPrivacySettings(LoadPrivacySettings event, Emitter<PrivacySecurityState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(state.copyWith(
        twoFactorAuth: true,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to load privacy settings: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  Future<void> _onUpdatePrivacySettings(UpdatePrivacySettings event, Emitter<PrivacySecurityState> emit) async {
    emit(state.copyWith(
      twoFactorAuth: event.twoFactorAuth,
    ));
    
    // Simulate background API update...
  }

  Future<void> _onChangePassword(ChangePassword event, Emitter<PrivacySecurityState> emit) async {
    emit(state.copyWith(isLoading: true, passwordChanged: false));
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      emit(state.copyWith(
        isLoading: false,
        passwordChanged: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to change password: ${e.toString()}',
        isLoading: false,
        passwordChanged: false,
      ));
    }
  }
}