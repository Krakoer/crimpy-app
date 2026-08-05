import 'dart:io';

import 'package:crimpy/logger.dart';
import 'package:crimpy/utils/reminder_plan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Delivers the training reminders through the OS scheduler. This is the only
/// place aware of the notifications plugin: what to send and when is decided by
/// [planReminders].
class NotificationService {
  static const String _channelId = 'training_reminders';
  static const String _channelName = 'Training reminders';
  static const String _channelDescription =
      'Reminds you of the trainings your coach scheduled.';

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDescription,
    importance: Importance.defaultImportance,
  );

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );

  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Reminders are planned in wall clock time, so scheduling needs the device
  /// timezone database loaded first.
  ///
  /// The plugin demands per platform settings for every target it was
  /// registered on, so initializing on desktop would throw rather than degrade.
  Future<void> initialize() async {
    if (!supportsTrainingReminders || _initialized) return;
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    await _androidPlugin?.createNotificationChannel(_channel);
    _initialized = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _iosPlugin => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  /// Asks the OS for permission to post notifications, returning whether it was
  /// granted. Android below 13 grants implicitly, desktop never does since it
  /// cannot deliver a scheduled reminder at all.
  Future<bool> requestPermission() async {
    if (!supportsTrainingReminders) return false;
    await initialize();
    if (Platform.isAndroid) {
      return await _androidPlugin?.requestNotificationsPermission() ?? true;
    }
    if (Platform.isIOS) {
      return await _iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  Future<bool> hasPermission() async {
    if (!supportsTrainingReminders) return false;
    await initialize();
    if (Platform.isAndroid) {
      return await _androidPlugin?.areNotificationsEnabled() ?? true;
    }
    return true;
  }

  /// Replaces every pending reminder with [occurrences]. Ids are derived from
  /// the day and slot, so an unchanged plan rewrites itself identically.
  Future<void> scheduleAll(List<ReminderOccurrence> occurrences) async {
    await initialize();
    await cancelAll();
    for (final occurrence in occurrences) {
      await _plugin.zonedSchedule(
        id: occurrence.notificationId,
        title: occurrence.title,
        body: occurrence.body,
        scheduledDate: tz.TZDateTime.from(occurrence.when, tz.local),
        notificationDetails: _details,
        // Reminders do not need minute precision, and inexact alarms avoid the
        // exact alarm permission Android 14 puts behind a policy review.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
    AppLoggerHelper.debug('Scheduled ${occurrences.length} training reminders');
  }

  /// Cancels the reminder id block only, leaving any other notification alone.
  Future<void> cancelAll() async {
    await initialize();
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (request.id >= reminderIdBase &&
          request.id < reminderIdBase + reminderIdBlockSize) {
        await _plugin.cancel(id: request.id);
      }
    }
  }
}

/// Whether the current platform can deliver scheduled reminders at all.
bool get supportsTrainingReminders => Platform.isAndroid || Platform.isIOS;
