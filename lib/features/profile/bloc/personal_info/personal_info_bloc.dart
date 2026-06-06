import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../core/storage/local_database.dart';
import 'personal_info_event.dart';
import 'personal_info_state.dart';

class PersonalInfoBloc extends Bloc<PersonalInfoEvent, PersonalInfoState> {
  final String _baseUrl = 'https://tapovana.onrender.com';

  PersonalInfoBloc() : super(const PersonalInfoState()) {
    on<LoadPersonalInfo>(_onLoadPersonalInfo);
    on<SavePersonalInfo>(_onSavePersonalInfo);
    on<ClearStatusMessages>(_onClearStatusMessages);
  }

  Future<void> _onLoadPersonalInfo(LoadPersonalInfo event, Emitter<PersonalInfoState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final userId = await LocalDatabase.getUserId();
      if (userId == null) {
        emit(state.copyWith(
          error: 'User ID not found locally. Please login again.',
          isLoading: false,
        ));
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/details/$userId'),
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

        String dob = user['dob'] ?? '';
        if (dob.isNotEmpty) {
          try {
            // A universal fix for backend timezone shifts (where 'YYYY-MM-DD' becomes e.g. '...T18:30:00Z' the day prior).
            // Converting to UTC and adding 12 hours safely repositions any shift up to 12 hours back onto its intended day.
            DateTime parsedDob = DateTime.parse(dob).toUtc().add(const Duration(hours: 12));
            String y = parsedDob.year.toString().padLeft(4, '0');
            String m = parsedDob.month.toString().padLeft(2, '0');
            String d = parsedDob.day.toString().padLeft(2, '0');
            dob = '$y-$m-$d';
          } catch (_) {
            // keep as is if unparseable
          }
        }

        emit(state.copyWith(
          fullName: user['name'] ?? '',
          email: user['email'] ?? '',
          phone: user['phone'] ?? '',
          dateOfBirth: dob,
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

    // Convert DOB purely as yyyy-MM-dd string, bypassing timezones
    String? dobFormatted;
    if (event.dateOfBirth.trim().isNotEmpty) {
      try {
        final parts = event.dateOfBirth.trim().split('/');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final month = parts[1].padLeft(2, '0');
          final year = parts[2];
          dobFormatted = '$year-$month-$day';
        } else {
          dobFormatted = event.dateOfBirth.trim();
        }
      } catch (_) {
        dobFormatted = event.dateOfBirth.trim();
      }
    }

    final body = {
      'name': event.fullName.trim().isEmpty ? null : event.fullName.trim(),
      'email': event.email.trim().isEmpty ? null : event.email.trim(),
      'phone': event.phone.trim().isEmpty ? null : event.phone.trim(),
      'dob': dobFormatted,
      'gender': event.gender.trim().isEmpty ? null : event.gender.trim(),
      'city': cityValue.isEmpty ? null : cityValue,
      'address': event.streetAddress.trim().isEmpty ? null : event.streetAddress.trim(),
      'health_concerns': event.healthConcerns.trim().isEmpty ? null : event.healthConcerns.trim(),
      'preferred_therapies': event.preferredTherapies.trim().isEmpty ? null : event.preferredTherapies.trim(),
      'allergies': event.allergies.trim().isEmpty ? null : event.allergies.trim(),
    };

    try {
      final userId = await LocalDatabase.getUserId();
      if (userId == null) {
        emit(state.copyWith(
          error: 'User ID not found locally. Please login again.',
          isSaving: false,
        ));
        return;
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/details/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        emit(state.copyWith(
          fullName: event.fullName,
          email: event.email,
          phone: event.phone,
          dateOfBirth: dobFormatted ?? event.dateOfBirth,
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
