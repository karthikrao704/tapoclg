import '../entities/app_user.dart';

abstract class AuthRepository {
  /// Stream that emits the current user, or null if unauthenticated.
  Stream<AppUser?> get user;
  
  Future<AppUser?> signInWithGoogle();
  Future<void> signOut();
}