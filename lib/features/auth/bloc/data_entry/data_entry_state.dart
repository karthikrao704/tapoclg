abstract class DataEntryState {}

class DataEntryInitial extends DataEntryState {}

class DataEntryLoading extends DataEntryState {}

class DataEntrySuccess extends DataEntryState {
  final Map<String, dynamic> loginData;
  final String authMethod;

  DataEntrySuccess({
    required this.loginData,
    required this.authMethod,
  });
}

class DataEntryFailure extends DataEntryState {
  final String error;

  DataEntryFailure(this.error);
}