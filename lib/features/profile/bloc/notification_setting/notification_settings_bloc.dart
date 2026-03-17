import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_settings_event.dart';
import 'notification_settings_state.dart';

class NotificationSettingsBloc extends Bloc<NotificationSettingsEvent, NotificationSettingsState> {
  NotificationSettingsBloc() : super(const NotificationSettingsState()) {
    on<LoadNotificationSettings>(_onLoadNotificationSettings);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
  }

  Future<void> _onLoadNotificationSettings(LoadNotificationSettings event, Emitter<NotificationSettingsState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(state.copyWith(
        bookingConfirmation: true,
        reminders: true,
        rescheduleAlerts: true,
        workshops: false,
        programs: true,
        retreats: false,
        promotions: false,
        benefits: true,
        seasonal: false,
        pushNotifications: true,
        emailUpdates: true,
        smsAlerts: false,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to load notification settings: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  Future<void> _onUpdateNotificationSettings(UpdateNotificationSettings event, Emitter<NotificationSettingsState> emit) async {
    // Note: We don't want to show a loading state for simple UI toggle updates
    // as it disrupts the instantaneous switch animation UX.
    
    emit(state.copyWith(
      bookingConfirmation: event.bookingConfirmation ?? state.bookingConfirmation,
      reminders: event.reminders ?? state.reminders,
      rescheduleAlerts: event.rescheduleAlerts ?? state.rescheduleAlerts,
      workshops: event.workshops ?? state.workshops,
      programs: event.programs ?? state.programs,
      retreats: event.retreats ?? state.retreats,
      promotions: event.promotions ?? state.promotions,
      benefits: event.benefits ?? state.benefits,
      seasonal: event.seasonal ?? state.seasonal,
      pushNotifications: event.pushNotifications ?? state.pushNotifications,
      emailUpdates: event.emailUpdates ?? state.emailUpdates,
      smsAlerts: event.smsAlerts ?? state.smsAlerts,
    ));
  }
}