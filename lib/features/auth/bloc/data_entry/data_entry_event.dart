abstract class DataEntryEvent {}

/// For BOTH email and Google users
class SubmitDataEntry extends DataEntryEvent {
  final String email;
  final String password; // real password for email, "Google_<uid>" for Google
  final String name;
  final String gender;
  final String city;
  final String authMethod; // "email" or "google"

  SubmitDataEntry({
    required this.email,
    required this.password,
    required this.name,
    required this.gender,
    required this.city,
    required this.authMethod,
  });
}