import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tapovana_mobile_app/features/auth/domain/entities/app_user.dart';
import 'package:tapovana_mobile_app/features/auth/domain/repos/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  // 1. MUST use the singleton instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Track initialization state to prevent calling it multiple times
  bool _isInitialized = false;

  AuthRepositoryImpl({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  AppUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  // 2. Helper method to pass the Server Client ID safely
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize(
        // TODO: Replace this with the WEB Client ID from your Firebase Console
        serverClientId:
            '1026651541392-o3g2bt8gs7vq9gin1qg99eleqs09j56p.apps.googleusercontent.com',
        // scopes: ['email', 'profile'],
      );
      _isInitialized = true;
    }
  }

  @override
  Stream<AppUser?> get user {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      // 3. Guarantee initialization before doing anything else
      await _ensureInitialized();

      // 4. Trigger the Authentication sheet (Identity)
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
      if (googleUser == null) return null; // User canceled

      // 5. Request Authorization (Permissions / Access Token)
      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);

      // 6. Retrieve Identity Token
      final googleAuth = await googleUser.authentication;

      // 7. Create Firebase Credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth.accessToken,
      );

      // 8. Complete Sign-In
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      return _mapFirebaseUser(userCredential.user);
    } catch (e) {
      throw Exception('Google Sign-In Failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }
}
