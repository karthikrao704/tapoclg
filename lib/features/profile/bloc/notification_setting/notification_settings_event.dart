import 'package:equatable/equatable.dart';

abstract class NotificationSettingsEvent extends Equatable {
  const NotificationSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationSettings extends NotificationSettingsEvent {}

class UpdateNotificationSettings extends NotificationSettingsEvent {
  final bool? bookingConfirmation;
  final bool? reminders;
  final bool? rescheduleAlerts;
  final bool? workshops;
  final bool? programs;
  final bool? retreats;
  final bool? promotions;
  final bool? benefits;
  final bool? seasonal;
  final bool? pushNotifications;
  final bool? emailUpdates;
  final bool? smsAlerts;

  const UpdateNotificationSettings({
    this.bookingConfirmation,
    this.reminders,
    this.rescheduleAlerts,
    this.workshops,
    this.programs,
    this.retreats,
    this.promotions,
    this.benefits,
    this.seasonal,
    this.pushNotifications,
    this.emailUpdates,
    this.smsAlerts,
  });

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
      ];
}