import 'package:equatable/equatable.dart';

class PrivacySecurityState extends Equatable {
  final bool twoFactorAuth;
  final bool isLoading;
  final String? error;
  final bool passwordChanged;

  const PrivacySecurityState({
    this.twoFactorAuth = true, // Defaulting to true as per image
    this.isLoading = false,
    this.error,
    this.passwordChanged = false,
  });

  PrivacySecurityState copyWith({
    bool? twoFactorAuth,
    bool? isLoading,
    String? error,
    bool? passwordChanged,
  }) {
    return PrivacySecurityState(
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      passwordChanged: passwordChanged ?? this.passwordChanged,
    );
  }

  @override
  List<Object?> get props => [twoFactorAuth, isLoading, error, passwordChanged];
}