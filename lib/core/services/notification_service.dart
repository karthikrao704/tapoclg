// lib/core/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tapovana_mobile_app/core/data/wellness_tips.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize notifications and timezone setup
  Future<void> initialize() async {
    try {
      // 1. Initialize timezone databases
      tz.initializeTimeZones();
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('✅ Timezone initialized: $timeZoneName');

      // 2. Android notification settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS notification settings
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // 4. Combine settings
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      // 5. Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );

      debugPrint('✅ Local notifications initialized successfully');

      // 6. Request permissions
      await requestPermissions();

      // 7. Schedule daily wellness tips
      await scheduleDailyWellnessTips();
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  /// Request permissions on Android 13+ and iOS
  Future<void> requestPermissions() async {
    try {
      // Request iOS Permissions
      final iosPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('🍎 iOS notification permission granted: $granted');
      }

      // Request Android Permissions
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('🤖 Android notification permission granted: $granted');

        // Attempt requesting exact alarms permission
        final exactGranted = await androidPlugin.requestExactAlarmsPermission();
        debugPrint('🤖 Android exact alarm permission granted: $exactGranted');
      }
    } catch (e) {
      debugPrint('⚠️ Error requesting notification permissions: $e');
    }
  }

  /// Schedule the next 14 days of wellness tip notifications offline
  Future<void> scheduleDailyWellnessTips() async {
    try {
      // 1. Cancel previous wellness tips notifications to avoid duplicates/stales
      // Wellness notifications will use IDs 100 to 114
      for (int i = 0; i < 15; i++) {
        await _flutterLocalNotificationsPlugin.cancel(100 + i);
      }
      debugPrint('🧹 Cancelled previous daily notifications');

      final localTime = tz.TZDateTime.now(tz.local);
      debugPrint('📅 Scheduling daily tips starting from: $localTime');

      int scheduledCount = 0;
      for (int i = 0; i < 14; i++) {
        // Calculate the Target Date: today + i days
        // Notification should fire at 6:00 AM local time
        var scheduledDate = tz.TZDateTime(
          tz.local,
          localTime.year,
          localTime.month,
          localTime.day + i,
          6, // 6:00 AM
          0,
        );

        // If the calculated time for today (i = 0) is in the past, move it to tomorrow
        if (scheduledDate.isBefore(localTime)) {
          continue;
        }

        final tipText = getWellnessTipForDate(scheduledDate);
        final int notificationId = 100 + scheduledCount;

        const androidDetails = AndroidNotificationDetails(
          'wellness_tips_channel',
          'Daily Wellness Tips',
          channelDescription: 'Receive a daily wellness tip every morning at 6:00 AM',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        );

        const iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        try {
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            notificationId,
            'Daily Wellness Tip',
            tipText,
            scheduledDate,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          scheduledCount++;
          debugPrint(
            '🔔 Scheduled notification ID $notificationId for date $scheduledDate: "$tipText"',
          );
        } catch (scheduleError) {
          // If scheduling exact alarms is blocked, fallback to non-exact allowWhileIdle
          debugPrint('⚠️ Exact alarm scheduling failed ($scheduleError). Retrying with basic mode...');
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            notificationId,
            'Daily Wellness Tip',
            tipText,
            scheduledDate,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          scheduledCount++;
          debugPrint(
            '🔔 Scheduled (non-exact fallback) ID $notificationId for date $scheduledDate',
          );
        }
      }

      debugPrint('🎉 Scheduled $scheduledCount daily wellness tip notifications successfully');
    } catch (e) {
      debugPrint('❌ Failed to schedule wellness notifications: $e');
    }
  }
}
