import 'package:equatable/equatable.dart';

abstract class PrivacySecurityEvent extends Equatable {
  const PrivacySecurityEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrivacySettings extends PrivacySecurityEvent {}

class UpdatePrivacySettings extends PrivacySecurityEvent {
  final bool twoFactorAuth;

  const UpdatePrivacySettings({
    required this.twoFactorAuth,
  });

  @override
  List<Object?> get props => [twoFactorAuth];
}

class ChangePassword extends PrivacySecurityEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}