import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:tapovana_mobile_app/features/auth/domain/entities/app_user.dart';

class FirebaseAuthRepository {
  final FirebaseAuth _firebaseAuth;
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '1026651541392-o3g2bt8gs7vq9gin1qg99eleqs09j56p.apps.googleusercontent.com',
  );

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

  Stream<AppUser?> get user {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Future<GoogleSignInResult?> signInWithGoogle() async {
    try {
      debugPrint('🔄 Starting Google Sign-In...');

      await _googleSignIn.signOut();

      // ✅ v6.x uses signIn()
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('❌ User canceled');
        return null;
      }

      debugPrint('✅ Google user: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // ✅ v6.x has both idToken and accessToken
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      debugPrint('✅ Firebase: ${userCredential.user?.email}');

      final user = _mapFirebaseUser(userCredential.user);
      
      return GoogleSignInResult(
        user: user!,
        firebaseUid: userCredential.user!.uid,
      );
    } catch (e) {
      debugPrint('❌ Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}

class GoogleSignInResult {
  final AppUser user;
  final String firebaseUid;
  GoogleSignInResult({required this.user, required this.firebaseUid});
}