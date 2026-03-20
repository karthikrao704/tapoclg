import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<Logout>(_onLogout);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      emit(
        state.copyWith(
          name: 'Virat Kohli',
          email: 'virat.kohli@example.com',
          avatar: 'assets/images/vk.png',
          membershipType: 'GOLD MEMBER',
          memberSince: 'March 2023',
          availableCredits: 12,
          nextRenewal: 'Jan 15, 2026',
          totalVisits: 24,
          appVersion: '2.4.0',
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Failed to load profile: ${e.toString()}',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      emit(
        state.copyWith(
          name: event.name,
          email: event.email,
          avatar: event.avatar,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Failed to update profile: ${e.toString()}',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onLogout(Logout event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate logout API call
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would navigate to login screen here
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Failed to logout: ${e.toString()}',
          isLoading: false,
        ),
      );
    }
  }
}
