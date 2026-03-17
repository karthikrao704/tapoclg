import 'package:flutter_bloc/flutter_bloc.dart';
import 'personal_info_event.dart';
import 'personal_info_state.dart';

class PersonalInfoBloc extends Bloc<PersonalInfoEvent, PersonalInfoState> {
  PersonalInfoBloc() : super(const PersonalInfoState()) {
    on<LoadPersonalInfo>(_onLoadPersonalInfo);
    on<UpdatePersonalInfo>(_onUpdatePersonalInfo);
  }

  Future<void> _onLoadPersonalInfo(LoadPersonalInfo event, Emitter<PersonalInfoState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(state.copyWith(
        fullName: 'Ananya Sharma',
        email: 'ananya.sharma@example.com',
        phone: '+91 98765 43210',
        dateOfBirth: '05/15/1992',
        gender: 'Female',
        country: 'India',
        city: 'Mysuru',
        streetAddress: '124 Lotus Gardens, Gokulam 3rd Stage',
        healthConcerns: 'Chronic lower back pain, occasional insomnia',
        preferredTherapies: 'Ayurvedic Massage, Yoga Nidra, Shirodhara',
        allergies: 'Peanuts, Synthetic Fragrances',
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to load personal info: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  Future<void> _onUpdatePersonalInfo(UpdatePersonalInfo event, Emitter<PersonalInfoState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
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
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to update personal info: ${e.toString()}',
        isLoading: false,
      ));
    }
  }
}