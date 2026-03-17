import 'package:equatable/equatable.dart';

abstract class PersonalInfoEvent extends Equatable {
  const PersonalInfoEvent();

  @override
  List<Object> get props => [];
}

class LoadPersonalInfo extends PersonalInfoEvent {}

class UpdatePersonalInfo extends PersonalInfoEvent {
  final String fullName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String gender;
  final String country;
  final String city;
  final String streetAddress;
  final String healthConcerns;
  final String preferredTherapies;
  final String allergies;

  const UpdatePersonalInfo({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.country,
    required this.city,
    required this.streetAddress,
    required this.healthConcerns,
    required this.preferredTherapies,
    required this.allergies,
  });

  @override
  List<Object> get props => [
        fullName,
        email,
        phone,
        dateOfBirth,
        gender,
        country,
        city,
        streetAddress,
        healthConcerns,
        preferredTherapies,
        allergies,
      ];
}