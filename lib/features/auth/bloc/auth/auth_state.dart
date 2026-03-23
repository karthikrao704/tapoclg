import 'package:equatable/equatable.dart';
import 'package:tapovana_mobile_app/features/auth/domain/entities/app_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final AppUser user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

/// Google: user is NEW → go to Data Entry (no OTP)
class GoogleNewUser extends AuthState {
  final AppUser user;
  final String firebaseUid;

  const GoogleNewUser({
    required this.user,
    required this.firebaseUid,
  });

  @override
  List<Object?> get props => [user, firebaseUid];
}

/// Google: user EXISTS but has 2FA → needs OTP
class GoogleNeeds2FA extends AuthState {
  final AppUser user;
  final String email;

  const GoogleNeeds2FA({
    required this.user,
    required this.email,
  });

  @override
  List<Object?> get props => [user, email];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}