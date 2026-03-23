import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:tapovana_mobile_app/features/auth/domain/entities/app_user.dart';

class FirebaseAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isInitialized = false;

  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  AppUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      photoUrl: user.photoURL,
      authMethod: 'google',
    );
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize(
        serverClientId:
            '1026651541392-o3g2bt8gs7vq9gin1qg99eleqs09j56p.apps.googleusercontent.com',
      );
      _isInitialized = true;
      debugPrint('✅ GoogleSignIn initialized');
    }
  }

  Stream<AppUser?> get user {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Future<GoogleSignInResult?> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      debugPrint('🔄 Step 1: Calling authenticate()...');

      // Step 1: Authenticate (this gets the user's identity)
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();

      if (googleUser == null) {
        debugPrint('❌ User canceled Google Sign-In');
        return null;
      }

      debugPrint('✅ Step 1 done: ${googleUser.email}');

      // Step 2: Get authentication tokens (idToken)
      debugPrint('🔄 Step 2: Getting authentication tokens...');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint('✅ Step 2 done');
      debugPrint('   idToken: ${googleAuth.idToken != null ? "present (${googleAuth.idToken!.substring(0, 20)}...)" : "NULL"}');

      // Step 3: Try to get accessToken
      // DON'T use authorizeScopes for basic sign-in — it causes the reauth error
      String? accessToken;

      // The idToken alone is enough for Firebase sign-in
      // accessToken is optional

      debugPrint('🔄 Step 3: Creating Firebase credential...');

      // Step 4: Create Firebase credential using ONLY idToken
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: accessToken, // null is fine, Firebase only needs idToken
      );

      // Step 5: Sign in to Firebase
      debugPrint('🔄 Step 4: Signing in to Firebase...');

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      debugPrint('✅ Firebase sign-in success!');
      debugPrint('   Email: ${userCredential.user?.email}');
      debugPrint('   UID: ${userCredential.user?.uid}');
      debugPrint('   New user: ${userCredential.additionalUserInfo?.isNewUser}');

      final user = _mapFirebaseUser(userCredential.user);

      return GoogleSignInResult(
        user: user!,
        firebaseUid: userCredential.user!.uid,
      );
    } catch (e) {
      debugPrint('❌ Google Sign-In Failed: $e');
      throw Exception('Google Sign-In Failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('⚠️ Google sign out error: $e');
    }
    await _firebaseAuth.signOut();
    debugPrint('✅ Signed out');
  }
}

/// Result from Google sign-in
class GoogleSignInResult {
  final AppUser user;
  final String firebaseUid;

  GoogleSignInResult({
    required this.user,
    required this.firebaseUid,
  });

  String get generatedPassword => 'Google_$firebaseUid';
}