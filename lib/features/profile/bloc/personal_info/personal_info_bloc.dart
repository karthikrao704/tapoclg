import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'personal_info_event.dart';
import 'personal_info_state.dart';

class PersonalInfoBloc extends Bloc<PersonalInfoEvent, PersonalInfoState> {
  final String _baseUrl = 'https://backend.rosettesmartlife.com';
  final int _userId = 2;

  PersonalInfoBloc() : super(const PersonalInfoState()) {
    on<LoadPersonalInfo>(_onLoadPersonalInfo);
    on<SavePersonalInfo>(_onSavePersonalInfo);
    on<ClearStatusMessages>(_onClearStatusMessages);
  }

  Future<void> _onLoadPersonalInfo(LoadPersonalInfo event, Emitter<PersonalInfoState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/details/$_userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'] as Map<String, dynamic>;

        String city = '';
        String country = '';
        if (user['city'] != null && (user['city'] as String).isNotEmpty) {
          final parts = (user['city'] as String).split(',');
          city = parts[0].trim();
          country = parts.length > 1 ? parts[1].trim() : '';
        }

        emit(state.copyWith(
          fullName: user['name'] ?? '',
          email: user['email'] ?? '',
          phone: user['phone'] ?? '',
          dateOfBirth: user['dob'] ?? '',
          gender: user['gender'] ?? '',
          country: country,
          city: city,
          streetAddress: user['address'] ?? '',
          healthConcerns: user['health_concerns'] ?? '',
          preferredTherapies: user['preferred_therapies'] ?? '',
          allergies: user['allergies'] ?? '',
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          error: 'Failed to load data (status ${response.statusCode})',
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Network error: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  Future<void> _onSavePersonalInfo(SavePersonalInfo event, Emitter<PersonalInfoState> emit) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));

    final cityValue = [
      event.city.trim(),
      if (event.country.trim().isNotEmpty) event.country.trim(),
    ].join(',');

    final body = {
      'name': event.fullName.trim().isEmpty ? null : event.fullName.trim(),
      'email': event.email.trim().isEmpty ? null : event.email.trim(),
      'phone': event.phone.trim().isEmpty ? null : event.phone.trim(),
      'dob': event.dateOfBirth.trim().isEmpty ? null : event.dateOfBirth.trim(),
      'gender': event.gender.trim().isEmpty ? null : event.gender.trim(),
      'city': cityValue.isEmpty ? null : cityValue,
      'address': event.streetAddress.trim().isEmpty ? null : event.streetAddress.trim(),
      'health_concerns': event.healthConcerns.trim().isEmpty ? null : event.healthConcerns.trim(),
      'preferred_therapies': event.preferredTherapies.trim().isEmpty ? null : event.preferredTherapies.trim(),
      'allergies': event.allergies.trim().isEmpty ? null : event.allergies.trim(),
    };

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/details/$_userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        emit(state.copyWith(
          fullName: event.fullName,
          email: event.email,
          phone: event.phone,
          dateOfBirth: event.dateOfBirth,
          gender: event.gender,
          country: event.country,
          city: event.city,
          streetAddress: event.streetAddress,
          healthConcerns: event.healthConcerns,
          preferredTherapies: event.preferredTherapies,
          allergies: event.allergies,
          isSaving: false,
          successMessage: 'Changes saved successfully!',
        ));
      } else {
        emit(state.copyWith(
          error: 'Save failed (status ${response.statusCode})',
          isSaving: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Network error: ${e.toString()}',
        isSaving: false,
      ));
    }
  }

  void _onClearStatusMessages(ClearStatusMessages event, Emitter<PersonalInfoState> emit) {
    emit(state.copyWith(error: null, successMessage: null));
  }
}
