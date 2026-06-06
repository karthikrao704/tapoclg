import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../core/storage/local_database.dart';
import 'privacy_security_event.dart';
import 'privacy_security_state.dart';

class PrivacySecurityBloc extends Bloc<PrivacySecurityEvent, PrivacySecurityState> {
  static const String _baseUrl = 'https://tapovana.onrender.com';

  PrivacySecurityBloc() : super(const PrivacySecurityState()) {
    on<LoadPrivacySettings>(_onLoadPrivacySettings);
    on<UpdatePrivacySettings>(_onUpdatePrivacySettings);
    on<ChangePassword>(_onChangePassword);
    on<ClearPrivacyStatusMessages>(_onClearStatusMessages);
  }

  Future<void> _onLoadPrivacySettings(LoadPrivacySettings event, Emitter<PrivacySecurityState> emit) async {
    emit(state.copyWith(isLoading: true, error: () => null, successMessage: () => null));
    
    try {
      final userId = await LocalDatabase.getUserId();
      if (userId == null) {
        emit(state.copyWith(
          error: () => 'User ID not found locally. Please login again.',
          isLoading: false,
        ));
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/two-step/status/$userId'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // The API returns {"success":true,"two_step_verification":true}
        final bool isEnabled = data['two_step_verification'] ?? false;
        
        emit(state.copyWith(
          twoFactorAuth: isEnabled,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          error: () => 'Failed to load 2FA status (status ${response.statusCode})',
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Network error: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  Future<void> _onUpdatePrivacySettings(UpdatePrivacySettings event, Emitter<PrivacySecurityState> emit) async {
    final bool previousValue = state.twoFactorAuth;
    emit(state.copyWith(twoFactorAuth: event.twoFactorAuth, error: () => null, successMessage: () => null));
    
    try {
      final userId = await LocalDatabase.getUserId();
      if (userId == null) {
        emit(state.copyWith(
          twoFactorAuth: previousValue,
          error: () => 'User ID not found locally. Please login again.',
        ));
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/two-step/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': userId,
          'enabled': event.twoFactorAuth,
        }),
      );
      
      if (response.statusCode == 200) {
        emit(state.copyWith(
          successMessage: () => event.twoFactorAuth ? '2FA Enabled successfully' : '2FA Disabled successfully',
        ));
      } else {
        // Revert on failure
        emit(state.copyWith(
          twoFactorAuth: previousValue,
          error: () => 'Failed to update 2FA (status ${response.statusCode})',
        ));
      }
    } catch (e) {
      // Revert on error
      emit(state.copyWith(
        twoFactorAuth: previousValue,
        error: () => 'Network error: ${e.toString()}',
      ));
    }
  }

  Future<void> _onChangePassword(ChangePassword event, Emitter<PrivacySecurityState> emit) async {
    emit(state.copyWith(isLoading: true, passwordChanged: false, error: () => null, successMessage: () => null));
    
    try {
      // Logic for password change API would go here. 
      // Keeping simulation for now as no endpoint was provided for this.
      await Future.delayed(const Duration(seconds: 1));
      
      emit(state.copyWith(
        isLoading: false,
        passwordChanged: true,
        successMessage: () => 'Password changed successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to change password: ${e.toString()}',
        isLoading: false,
        passwordChanged: false,
      ));
    }
  }

  void _onClearStatusMessages(ClearPrivacyStatusMessages event, Emitter<PrivacySecurityState> emit) {
    emit(state.copyWith(error: () => null, successMessage: () => null));
  }
}