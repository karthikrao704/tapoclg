abstract class OtpState {}

class OtpInitial extends OtpState {}

class OtpLoading extends OtpState {}

class OtpSuccess extends OtpState {
  final Map<String, dynamic> data;

  OtpSuccess(this.data);
}

class OtpFailure extends OtpState {
  final String error;

  OtpFailure(this.error);
}