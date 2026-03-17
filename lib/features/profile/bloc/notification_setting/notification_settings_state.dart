import 'package:equatable/equatable.dart';

class NotificationSettingsState extends Equatable {
  // Appointment Notifications
  final bool bookingConfirmation;
  final bool reminders;
  final bool rescheduleAlerts;

  // Program Updates
  final bool workshops;
  final bool programs;
  final bool retreats;

  // Marketing & Offers
  final bool promotions;
  final bool benefits;
  final bool seasonal;

  // Notification Channels
  final bool pushNotifications;
  final bool emailUpdates;
  final bool smsAlerts;

  final bool isLoading;
  final String? error;

  const NotificationSettingsState({
    this.bookingConfirmation = true,
    this.reminders = true,
    this.rescheduleAlerts = true,
    this.workshops = false,
    this.programs = true,
    this.retreats = false,
    this.promotions = false,
    this.benefits = true,
    this.seasonal = false,
    this.pushNotifications = true,
    this.emailUpdates = true,
    this.smsAlerts = false,
    this.isLoading = false,
    this.error,
  });

  NotificationSettingsState copyWith({
    bool? bookingConfirmation,
    bool? reminders,
    bool? rescheduleAlerts,
    bool? workshops,
    bool? programs,
    bool? retreats,
    bool? promotions,
    bool? benefits,
    bool? seasonal,
    bool? pushNotifications,
    bool? emailUpdates,
    bool? smsAlerts,
    bool? isLoading,
    String? error,
  }) {
    return NotificationSettingsState(
      bookingConfirmation: bookingConfirmation ?? this.bookingConfirmation,
      reminders: reminders ?? this.reminders,
      rescheduleAlerts: rescheduleAlerts ?? this.rescheduleAlerts,
      workshops: workshops ?? this.workshops,
      programs: programs ?? this.programs,
      retreats: retreats ?? this.retreats,
      promotions: promotions ?? this.promotions,
      benefits: benefits ?? this.benefits,
      seasonal: seasonal ?? this.seasonal,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailUpdates: emailUpdates ?? this.emailUpdates,
      smsAlerts: smsAlerts ?? this.smsAlerts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        bookingConfirmation,
        reminders,
        rescheduleAlerts,
        workshops,
        programs,
        retreats,
        promotions,
        benefits,
        seasonal,
        pushNotifications,
        emailUpdates,
        smsAlerts,
        isLoading,
        error,
      ];
}