import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/core/api/app_error.dart';
import 'package:tapovana_mobile_app/core/storage/local_database.dart';
import 'package:tapovana_mobile_app/features/profile/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc({ProfileRepository? repository})
    : _repository = repository ?? ProfileRepository(),
      super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadProfilePhoto>(_onUploadProfilePhoto);
    on<DeleteProfilePhoto>(_onDeleteProfilePhoto);
    on<Logout>(_onLogout);
  }

  // ─── Load profile from API ────────────────────────────────────────────────

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final profile = await _repository.getUserDetails();

      // ✅ Save profile photo URL locally for AppBar to use
      await LocalDatabase.saveProfilePhotoUrl(profile.profilePhotoUrl);

      emit(
        state.copyWith(
          name: profile.name,
          email: profile.email,
          profilePhotoUrl: profile.profilePhotoUrl,
          memberSince: profile.memberSinceFormatted,
          membershipType: profile.membership ?? 'GOLD MEMBER',
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
          errorType: AppError.classify(e),
          isLoading: false,
        ),
      );
    }
  }

  // ─── Update profile (local, e.g. from PersonalInfoPage) ──────────────────

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
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

  // ─── Upload photo ─────────────────────────────────────────────────────────

  Future<void> _onUploadProfilePhoto(
    UploadProfilePhoto event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isUploadingPhoto: true, clearPhotoError: true));

    try {
      final photoUrl = await _repository.uploadProfilePhoto(
        filePath: event.filePath,
      );

      // ✅ Save new photo URL locally
      await LocalDatabase.saveProfilePhotoUrl(photoUrl);

      emit(state.copyWith(profilePhotoUrl: photoUrl, isUploadingPhoto: false));
    } catch (e) {
      emit(state.copyWith(photoError: e.toString(), isUploadingPhoto: false));
    }
  }
  // ─── Delete photo ─────────────────────────────────────────────────────────

  Future<void> _onDeleteProfilePhoto(
    DeleteProfilePhoto event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isUploadingPhoto: true, clearPhotoError: true));

    try {
      await _repository.deleteProfilePhoto();

      // ✅ Clear photo URL locally
      await LocalDatabase.saveProfilePhotoUrl(null);

      emit(state.copyWith(clearProfilePhotoUrl: true, isUploadingPhoto: false));
    } catch (e) {
      emit(state.copyWith(photoError: e.toString(), isUploadingPhoto: false));
    }
  }
  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> _onLogout(Logout event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
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
