import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/features/auth/domain/repos/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription _userSubscription;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    // Listen to auth state changes to persist login across app restarts
    _userSubscription = _authRepository.user.listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());
      await _authRepository.signInWithGoogle();
      // Note: We don't emit Authenticated() here because the stream listener 
      // above will automatically catch the state change and emit it for us.
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> signOut() async {
    try {
      emit(AuthLoading());
      await _authRepository.signOut();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}