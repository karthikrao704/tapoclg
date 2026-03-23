abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final Map<String, dynamic> data;

  LoginSuccess(this.data);
}

/// Login succeeded but 2FA is required
class LoginNeeds2FA extends LoginState {
  final String email;
  final String password;

  LoginNeeds2FA({required this.email, required this.password});
}

/// 2FA OTP verified successfully
class Login2FASuccess extends LoginState {
  final Map<String, dynamic> data;

  Login2FASuccess(this.data);
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure(this.error);
}