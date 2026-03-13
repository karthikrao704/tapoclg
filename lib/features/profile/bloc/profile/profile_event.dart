import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String email;
  final String avatar;

  const UpdateProfile({
    required this.name,
    required this.email,
    required this.avatar,
  });

  @override
  List<Object> get props => [name, email, avatar];
}

class Logout extends ProfileEvent {}