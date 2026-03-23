import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String authMethod; 

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.authMethod = 'email',
  });

  @override
  List<Object?> get props => [id, email, name, photoUrl, authMethod];
}