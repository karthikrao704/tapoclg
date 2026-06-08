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
    on<UpgradeWellnessPass>(_onUpgradeWellnessPass);
    on<UseWellnessCredit>(_onUseWellnessCredit);
  }

  // ─── Load profile from local storage (no API call) ───────────────────────

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Load name & email from local DB
      final user = await LocalDatabase.getUser();
      final name = (user?['name'] as String?)?.isNotEmpty == true
          ? user!['name'] as String
          : '';
      final email = user?['email'] as String? ?? '';

      // Load profile photo URL from local DB
      final photoUrl = await LocalDatabase.getProfilePhotoUrl();

      // Load wellness pass from local DB
      final savedPass = await LocalDatabase.getWellnessPass();
      final String currentMembership = savedPass ?? 'GOLD';

      // Load wellness credits from local DB
      int credits = 0;
      final savedCredits = await LocalDatabase.getWellnessCredits();
      if (savedCredits != null) {
        credits = savedCredits;
      } else {
        if (currentMembership.toUpperCase().contains('SILVER')) {
          credits = 5;
        } else if (currentMembership.toUpperCase().contains('GOLD')) {
          credits = 12;
        } else if (currentMembership.toUpperCase().contains('DIAMOND')) {
          credits = 25;
        }
        await LocalDatabase.saveWellnessCredits(credits);
      }

      emit(
        state.copyWith(
          name: name,
          email: email,
          profilePhotoUrl: photoUrl,
          memberSince: '',
          membershipType: currentMembership.toUpperCase().endsWith('PASS') ||
                  currentMembership.toUpperCase().endsWith('MEMBER')
              ? currentMembership.toUpperCase()
              : '${currentMembership.toUpperCase()} PASS',
          availableCredits: credits,
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
          errorType: AppErrorType.server,
          isLoading: false,
        ),
      );
    }
  }

  // ─── Upgrade wellness pass ────────────────────────────────────────────────

  Future<void> _onUpgradeWellnessPass(
    UpgradeWellnessPass event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await LocalDatabase.saveWellnessPass(event.passType);

      int credits = 0;
      if (event.passType.toUpperCase().contains('SILVER')) {
        credits = 5;
      } else if (event.passType.toUpperCase().contains('GOLD')) {
        credits = 12;
      } else if (event.passType.toUpperCase().contains('DIAMOND')) {
        credits = 25;
      }

      await LocalDatabase.saveWellnessCredits(credits);

      emit(
        state.copyWith(
          membershipType: event.passType.toUpperCase().endsWith('PASS') || event.passType.toUpperCase().endsWith('MEMBER')
              ? event.passType.toUpperCase()
              : '${event.passType.toUpperCase()} PASS',
          availableCredits: credits,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Failed to upgrade wellness pass: ${e.toString()}',
        ),
      );
    }
  }

  // ─── Deduct wellness credit ───────────────────────────────────────────────

  Future<void> _onUseWellnessCredit(
    UseWellnessCredit event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final currentCredits = state.availableCredits;
      if (currentCredits > 0) {
        final newCredits = currentCredits - 1;
        await LocalDatabase.saveWellnessCredits(newCredits);
        emit(state.copyWith(availableCredits: newCredits));
      }
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Failed to deduct credit: ${e.toString()}',
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
    emit(const ProfileState());
  }
}
