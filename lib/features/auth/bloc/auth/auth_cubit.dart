import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tapovana_mobile_app/core/storage/secure_storage.dart';
import 'package:tapovana_mobile_app/core/storage/local_database.dart';
import 'package:tapovana_mobile_app/features/auth/data/auth_api_repository.dart';
import 'package:tapovana_mobile_app/features/auth/data/firebase_auth_repo.dart';
import 'package:tapovana_mobile_app/features/auth/domain/entities/app_user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuthRepository firebaseAuthRepo;
  final AuthApiRepository apiAuthRepo;
  final SecureStorage secureStorage;

  AuthCubit({
    required this.firebaseAuthRepo,
    required this.apiAuthRepo,
    required this.secureStorage,
  }) : super(AuthInitial()) {
    _checkExistingSession();
  }

  // ═══════════════════════════════════════
  //    CLERK SESSION HANDLERS
  // ═══════════════════════════════════════

  Future<void> syncClerkSession(dynamic authState) async {
    try {
      final user = authState.user;
      if (user == null) return;

      final sessionToken = await authState.sessionToken();
      if (sessionToken == null) return;

      final clerkId = user.id;
      final email = user.emailAddresses
          .firstWhere((e) => e.id == user.primaryEmailAddressId,
              orElse: () => user.emailAddresses.first)
          .emailAddress;
      
      final firstName = user.firstName ?? '';
      final lastName = user.lastName ?? '';
      final name = '${firstName} ${lastName}'.trim();

      // Check if we are already authenticated with this clerkId
      final currentState = state;
      if (currentState is Authenticated && currentState.user.id == clerkId) {
        return; // Already synced and authenticated
      }

      emit(AuthLoading());

      // Save token to secure storage
      await secureStorage.saveToken(sessionToken);
      await secureStorage.saveUserEmail(email);
      await secureStorage.saveAuthMethod('clerk');

      // Call clerk-sync endpoint on backend to get/create local user
      final response = await http.post(
        Uri.parse('${apiAuthRepo.baseUrl}/api/auth/clerk-sync'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $sessionToken",
        },
        body: jsonEncode({
          "clerkId": clerkId,
          "email": email,
          "name": name,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final dbUser = data['user'];
        final localId = dbUser?['id']?.toString() ?? clerkId;
        
        await secureStorage.saveUserId(localId);
        
        await _saveUserLocally(
          userId: localId,
          email: email,
          name: dbUser?['name'] ?? name,
          authMethod: 'clerk',
        );

        emit(Authenticated(AppUser(
          id: localId,
          email: email,
          name: dbUser?['name'] ?? name,
          authMethod: 'clerk',
        )));
      } else {
        emit(AuthError('Failed to sync session with backend (status ${response.statusCode}).'));
      }
    } catch (e) {
      debugPrint('❌ Clerk sync error: $e');
      emit(AuthError('Session sync error: $e'));
    }
  }

  Future<void> handleClerkSignOut() async {
    final currentState = state;
    if (currentState is! Unauthenticated) {
      await secureStorage.clearAll();
      await LocalDatabase.deleteUser();
      emit(Unauthenticated());
    }
  }

  // ═══════════════════════════════════════
  //    HELPER: Save user to local DB
  // ═══════════════════════════════════════

  Future<void> _saveUserLocally({
    required String userId,
    required String email,
    String? name,
    required String authMethod,
  }) async {
    await LocalDatabase.saveUser(
      userId: userId,
      email: email,
      name: name,
      authMethod: authMethod,
    );
    debugPrint('💾 User saved locally: $email (id: $userId)');
  }

  // ═══════════════════════════════════════
  //          SESSION CHECK ON START
  // ═══════════════════════════════════════

  Future<void> _checkExistingSession() async {
    try {
      final token = await secureStorage.getToken();
      final authMethod = await secureStorage.getAuthMethod();
      final email = await secureStorage.getUserEmail();
      final userId = await secureStorage.getUserId();

      if (token != null && token.isNotEmpty) {
        debugPrint('✅ Existing session: $email ($authMethod)');

        // Also check local DB for name
        final localUser = await LocalDatabase.getUser();
        final name = localUser?['name'] as String?;

        emit(Authenticated(AppUser(
          id: userId ?? '',
          email: email ?? '',
          name: name,
          authMethod: authMethod ?? 'email',
        )));
      } else {
        debugPrint('❌ No session');
        emit(Unauthenticated());
      }
    } catch (e) {
      debugPrint('❌ Session check error: $e');
      emit(Unauthenticated());
    }
  }

  // ═══════════════════════════════════════
  //       EMAIL CALLBACKS
  // ═══════════════════════════════════════

  Future<void> onEmailLoginSuccess(Map<String, dynamic> responseData) async {
    final userData = responseData['user'];
    final userId = userData?['id']?.toString() ?? '';
    final email = userData?['email'] ?? '';
    final name = userData?['name'];

    await secureStorage.saveAuthMethod('email');

    // Save to SQLite
    await _saveUserLocally(
      userId: userId,
      email: email,
      name: name,
      authMethod: 'email',
    );

    emit(Authenticated(AppUser(
      id: userId,
      email: email,
      name: name,
      authMethod: 'email',
    )));
  }

  Future<void> onLogin2FASuccess(Map<String, dynamic> responseData) async {
    final userData = responseData['user'];
    final userId = userData?['id']?.toString() ?? '';
    final email = userData?['email'] ?? '';
    final name = userData?['name'];

    await secureStorage.saveAuthMethod('email');

    // Save to SQLite
    await _saveUserLocally(
      userId: userId,
      email: email,
      name: name,
      authMethod: 'email',
    );

    emit(Authenticated(AppUser(
      id: userId,
      email: email,
      name: name,
      authMethod: 'email',
    )));
  }

  Future<void> onSignupComplete(
      Map<String, dynamic> responseData, String authMethod) async {
    final userData = responseData['user'];
    final userId = userData?['id']?.toString() ?? '';
    final email = userData?['email'] ?? '';
    final name = userData?['name'];

    await secureStorage.saveAuthMethod(authMethod);

    // Save to SQLite
    await _saveUserLocally(
      userId: userId,
      email: email,
      name: name,
      authMethod: authMethod,
    );

    emit(Authenticated(AppUser(
      id: userId,
      email: email,
      name: name,
      authMethod: authMethod,
    )));
  }

  // ═══════════════════════════════════════
  //        GOOGLE SIGN-IN
  // ═══════════════════════════════════════

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());

      final result = await firebaseAuthRepo.signInWithGoogle();
      if (result == null) {
        debugPrint('❌ Google sign-in canceled');
        emit(Unauthenticated());
        return;
      }

      debugPrint('✅ Google: ${result.user.email}, UID: ${result.firebaseUid}');

      final checkResponse = await apiAuthRepo.googleCheckUser(
        email: result.user.email,
      );

      debugPrint('📡 Check user response: $checkResponse');

      if (checkResponse['success'] == true && checkResponse['exists'] == true) {
        debugPrint('👤 User exists, attempting login...');

        final loginResponse = await apiAuthRepo.googleLogin(
          email: result.user.email,
          uid: result.firebaseUid,
        );

        debugPrint('📡 Google login response: $loginResponse');

        if (loginResponse['success'] == true) {
          if (loginResponse['requires_otp'] == true) {
            debugPrint('🔐 2FA enabled, needs OTP');
            emit(GoogleNeeds2FA(
              user: result.user,
              email: result.user.email,
            ));
          } else {
            debugPrint('✅ Google login success → Home');
            await secureStorage.saveAuthMethod('google');

            final userData = loginResponse['user'];
            final userId =
                userData?['id']?.toString() ?? result.user.id;
            final name = userData?['name'] ?? result.user.name;

            // Save to SQLite
            await _saveUserLocally(
              userId: userId,
              email: result.user.email,
              name: name,
              authMethod: 'google',
            );

            emit(Authenticated(AppUser(
              id: userId,
              email: result.user.email,
              name: name,
              photoUrl: result.user.photoUrl,
              authMethod: 'google',
            )));
          }
        } else {
          debugPrint('❌ Google login failed: ${loginResponse['message']}');
          emit(AuthError(loginResponse['message'] ?? 'Login failed'));
          emit(Unauthenticated());
        }
      } else if (checkResponse['success'] == true &&
          checkResponse['exists'] == false) {
        debugPrint('🆕 New Google user → Data Entry');
        emit(GoogleNewUser(
          user: result.user,
          firebaseUid: result.firebaseUid,
        ));
      } else {
        debugPrint('❌ Check user error: ${checkResponse['message']}');
        emit(AuthError(checkResponse['message'] ?? 'Something went wrong'));
        emit(Unauthenticated());
      }
    } catch (e) {
      debugPrint('❌ Google sign-in error: $e');
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // ═══════════════════════════════════════
  //    GOOGLE SIGNUP COMPLETE
  // ═══════════════════════════════════════

  Future<void> completeGoogleSignup({
    required String email,
    required String firebaseUid,
    required String name,
    required String gender,
    required String city,
  }) async {
    try {
      emit(AuthLoading());

      final response = await apiAuthRepo.completeGoogleSignup(
        email: email,
        uid: firebaseUid,
        name: name,
        gender: gender,
        city: city,
      );

      debugPrint('📡 Google signup complete: $response');

      if (response['success'] == true) {
        await secureStorage.saveAuthMethod('google');

        final userData = response['user'];
        final userId = userData?['id']?.toString() ?? '';

        // Save to SQLite
        await _saveUserLocally(
          userId: userId,
          email: email,
          name: userData?['name'] ?? name,
          authMethod: 'google',
        );

        emit(Authenticated(AppUser(
          id: userId,
          email: email,
          name: userData?['name'] ?? name,
          authMethod: 'google',
        )));
      } else {
        emit(AuthError(response['message'] ?? 'Signup failed'));
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // ═══════════════════════════════════════
  //     GOOGLE 2FA OTP
  // ═══════════════════════════════════════

  Future<void> verifyGoogle2FA({
    required String email,
    required String otp,
    required AppUser user,
  }) async {
    try {
      emit(AuthLoading());

      final response = await apiAuthRepo.verifyLoginOtp(
        email: email,
        otp: otp,
      );

      if (response['success'] == true) {
        await secureStorage.saveAuthMethod('google');

        final userData = response['user'];
        final userId = userData?['id']?.toString() ?? user.id;
        final name = userData?['name'] ?? user.name;

        // Save to SQLite
        await _saveUserLocally(
          userId: userId,
          email: email,
          name: name,
          authMethod: 'google',
        );

        emit(Authenticated(AppUser(
          id: userId,
          email: email,
          name: name,
          photoUrl: user.photoUrl,
          authMethod: 'google',
        )));
      } else {
        emit(AuthError(response['message'] ?? 'OTP failed'));
        emit(GoogleNeeds2FA(user: user, email: email));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(GoogleNeeds2FA(user: user, email: email));
    }
  }

  // ═══════════════════════════════════════
  //             SIGN OUT
  // ═══════════════════════════════════════

  Future<void> signOut() async {
    try {
      emit(AuthLoading());
      final authMethod = await secureStorage.getAuthMethod();
      if (authMethod == 'google') {
        await firebaseAuthRepo.signOut();
      }

      // Clear both storages
      await secureStorage.clearAll();
      await LocalDatabase.deleteUser();

      debugPrint('✅ Signed out (secure storage + local DB cleared)');
      emit(Unauthenticated());
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      await secureStorage.clearAll();
      await LocalDatabase.deleteUser();
      emit(Unauthenticated());
    }
  }
}