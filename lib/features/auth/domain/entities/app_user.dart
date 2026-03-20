import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, email, name, photoUrl];
}