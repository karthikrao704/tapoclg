import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final String name;
  final String email;
  final String avatar;
  final String membershipType;
  final String memberSince;
  final int availableCredits;
  final String nextRenewal;
  final int totalVisits;
  final String appVersion;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.name = 'Virat Kohli',
    this.email = 'virat.kohli@example.com',
    this.avatar = 'assets/images/vk.png',
    this.membershipType = 'GOLD MEMBER',
    this.memberSince = 'March 2023',
    this.availableCredits = 12,
    this.nextRenewal = 'Jan 15, 2026',
    this.totalVisits = 24,
    this.appVersion = '2.4.0',
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    String? name,
    String? email,
    String? avatar,
    String? membershipType,
    String? memberSince,
    int? availableCredits,
    String? nextRenewal,
    int? totalVisits,
    String? appVersion,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      membershipType: membershipType ?? this.membershipType,
      memberSince: memberSince ?? this.memberSince,
      availableCredits: availableCredits ?? this.availableCredits,
      nextRenewal: nextRenewal ?? this.nextRenewal,
      totalVisits: totalVisits ?? this.totalVisits,
      appVersion: appVersion ?? this.appVersion,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    name,
    email,
    avatar,
    membershipType,
    memberSince,
    availableCredits,
    nextRenewal,
    totalVisits,
    appVersion,
    isLoading,
    error,
  ];
}