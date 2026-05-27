import 'package:equatable/equatable.dart';
import 'package:tapovana_mobile_app/core/api/app_error.dart';

class ProfileState extends Equatable {
  final String name;
  final String email;
  final String? profilePhotoUrl; // from API
  final String avatar; // local asset fallback
  final String membershipType;
  final String memberSince;
  final int availableCredits;
  final String nextRenewal;
  final int totalVisits;
  final String appVersion;
  final bool isLoading;
  final bool isUploadingPhoto;
  final String? error;
  final AppErrorType? errorType;
  final String? photoError;

  const ProfileState({
    this.name = '',
    this.email = '',
    this.profilePhotoUrl,
    this.avatar = 'assets/images/profile.png',
    this.membershipType = 'GOLD MEMBER',
    this.memberSince = '',
    this.availableCredits = 0,
    this.nextRenewal = '',
    this.totalVisits = 0,
    this.appVersion = '2.4.0',
    this.isLoading = false,
    this.isUploadingPhoto = false,
    this.error,
    this.errorType,
    this.photoError,
  });

  ProfileState copyWith({
    String? name,
    String? email,
    String? profilePhotoUrl,
    bool clearProfilePhotoUrl = false,
    String? avatar,
    String? membershipType,
    String? memberSince,
    int? availableCredits,
    String? nextRenewal,
    int? totalVisits,
    String? appVersion,
    bool? isLoading,
    bool? isUploadingPhoto,
    String? error,
    AppErrorType? errorType,
    bool clearError = false,
    String? photoError,
    bool clearPhotoError = false,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      profilePhotoUrl: clearProfilePhotoUrl
          ? null
          : (profilePhotoUrl ?? this.profilePhotoUrl),
      avatar: avatar ?? this.avatar,
      membershipType: membershipType ?? this.membershipType,
      memberSince: memberSince ?? this.memberSince,
      availableCredits: availableCredits ?? this.availableCredits,
      nextRenewal: nextRenewal ?? this.nextRenewal,
      totalVisits: totalVisits ?? this.totalVisits,
      appVersion: appVersion ?? this.appVersion,
      isLoading: isLoading ?? this.isLoading,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      error: clearError ? null : (error ?? this.error),
      errorType: clearError ? null : (errorType ?? this.errorType),
      photoError: clearPhotoError ? null : (photoError ?? this.photoError),
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        profilePhotoUrl,
        avatar,
        membershipType,
        memberSince,
        availableCredits,
        nextRenewal,
        totalVisits,
        appVersion,
        isLoading,
        isUploadingPhoto,
        error,
        errorType,
        photoError,
      ];
}