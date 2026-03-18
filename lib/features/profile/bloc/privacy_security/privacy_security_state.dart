import 'package:equatable/equatable.dart';

class PrivacySecurityState extends Equatable {
  final bool twoFactorAuth;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final bool passwordChanged;

  const PrivacySecurityState({
    this.twoFactorAuth = false,
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.passwordChanged = false,
  });

  PrivacySecurityState copyWith({
    bool? twoFactorAuth,
    bool? isLoading,
    String? Function()? error,
    String? Function()? successMessage,
    bool? passwordChanged,
  }) {
    return PrivacySecurityState(
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      successMessage: successMessage != null ? successMessage() : this.successMessage,
      passwordChanged: passwordChanged ?? this.passwordChanged,
    );
  }

  @override
  List<Object?> get props => [twoFactorAuth, isLoading, error, successMessage, passwordChanged];
}