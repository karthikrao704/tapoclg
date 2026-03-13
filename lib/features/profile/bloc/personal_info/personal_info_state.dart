import 'package:equatable/equatable.dart';

class PersonalInfoState extends Equatable {
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
  final bool isLoading;
  final String? error;

  const PersonalInfoState({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.country = '',
    this.city = '',
    this.streetAddress = '',
    this.healthConcerns = '',
    this.preferredTherapies = '',
    this.allergies = '',
    this.isLoading = false,
    this.error,
  });

  PersonalInfoState copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? country,
    String? city,
    String? streetAddress,
    String? healthConcerns,
    String? preferredTherapies,
    String? allergies,
    bool? isLoading,
    String? error,
  }) {
    return PersonalInfoState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      city: city ?? this.city,
      streetAddress: streetAddress ?? this.streetAddress,
      healthConcerns: healthConcerns ?? this.healthConcerns,
      preferredTherapies: preferredTherapies ?? this.preferredTherapies,
      allergies: allergies ?? this.allergies,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
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
        isLoading,
        error,
      ];
}