import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
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

  /// Identifies the snooze button in a notification response, and the iOS
  /// category the button is registered under.
  static const String snoozeActionId = 'snooze_training_reminder';
  static const String _categoryId = 'training_reminder';

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      actions: <AndroidNotificationAction>[
        // Picking the new hour needs a picker, so the button has to bring the
        // app up rather than being handled in the background.
        AndroidNotificationAction(
          snoozeActionId,
          'Snooze',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    ),
    iOS: DarwinNotificationDetails(categoryIdentifier: _categoryId),
  );

  static final List<DarwinNotificationCategory> _categories = [
    DarwinNotificationCategory(
      _categoryId,
      actions: [
        DarwinNotificationAction.plain(
          snoozeActionId,
          'Snooze',
          options: {DarwinNotificationActionOption.foreground},
        ),
      ],
    ),
  ];

  /// Emits when the user taps the snooze button. The app answers by asking for
  /// the hour to postpone to, so this only reports the request.
  ///
  /// A request raised before anything listens is held rather than dropped: the
  /// tap is what launched the app, so it always arrives before the shell is up.
  /// Carries the instant of the tap rather than nothing at all: two identical
  /// events in a row compare equal, and the second would never be delivered.
  Stream<DateTime> get snoozeRequests => _snoozeRequests.stream;

  DateTime? _snoozePending;
  late final StreamController<DateTime> _snoozeRequests =
      StreamController<DateTime>.broadcast(onListen: _flushPendingSnooze);

  void _flushPendingSnooze() {
    final pending = _snoozePending;
    if (pending == null || !_snoozeRequests.hasListener) return;
    _snoozePending = null;
    // Never delivered straight from onListen, which runs while the listener is
    // still being attached.
    scheduleMicrotask(() => _snoozeRequests.add(pending));
  }

  void dispose() => _snoozeRequests.close();

  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<void>? _initialization;
  Future<void> _pendingWrite = Future.value();

  /// Reminders are planned in wall clock time, so scheduling needs the device
  /// timezone database loaded first.
  ///
  /// The plugin demands per platform settings for every target it was
  /// registered on, so initializing on desktop would throw rather than degrade.
  ///
  /// The in flight future is what gets shared, not a done flag: permission
  /// requests and reminder writes race on the first call.
  Future<void> initialize() async {
    if (!supportsTrainingReminders) return;
    final started = _initialization ??= _initialize();
    try {
      await started;
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }

  Future<void> _initialize() async {
    // tz.local stays UTC on purpose: every reminder is a one shot absolute
    // instant with no matchDateTimeComponents, and TZDateTime.from preserves
    // the instant, so the alarm still fires at the intended wall clock time.
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          notificationCategories: _categories,
        ),
      ),
      onDidReceiveNotificationResponse: _handleResponse,
    );
    await _androidPlugin?.createNotificationChannel(_channel);

    // A snooze tapped while the app was not running launches it, and the
    // response callback above can fire before anything is listening. The launch
    // details keep it until the app shell asks.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _handleResponse(launch!.notificationResponse);
    }
  }

  void _handleResponse(NotificationResponse? response) {
    if (response?.actionId != snoozeActionId) return;
    AppLoggerHelper.debug('Training reminder snoozed from the notification');
    _snoozePending = DateTime.now();
    _flushPendingSnooze();
  }

  /// Runs the reminder writes one after another. A write is a cancel followed
  /// by a rewrite over dozens of platform calls, so interleaving two of them
  /// leaves the ids only the older plan used still pending.
  Future<void> _serialized(Future<void> Function() write) {
    final result = _pendingWrite.then((_) => write());
    _pendingWrite = result.catchError((_) {});
    return result;
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
  Future<void> scheduleAll(List<ReminderOccurrence> occurrences) =>
      _serialized(() => _scheduleAll(occurrences));

  Future<void> _scheduleAll(List<ReminderOccurrence> occurrences) async {
    await initialize();
    if (!supportsTrainingReminders) return;
    await _cancelAll();
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
  Future<void> cancelAll() => _serialized(_cancelAll);

  Future<void> _cancelAll() async {
    await initialize();
    if (!supportsTrainingReminders) return;

    final pending = await _plugin.pendingNotificationRequests();
    // Reminders already sitting in the tray are cancelled too: the training the
    // user just logged should not keep asking for itself.
    final active = await _plugin.getActiveNotifications();
    final ids = <int>{
      ...pending.map((request) => request.id),
      ...active.map((notification) => notification.id).nonNulls,
    };

    for (final id in ids) {
      if (id >= reminderIdBase && id < reminderIdBase + reminderIdBlockSize) {
        await _plugin.cancel(id: id);
      }
    }
  }
}

/// Whether the current platform can deliver scheduled reminders at all.
bool get supportsTrainingReminders => Platform.isAndroid || Platform.isIOS;

/// Whether the OS lets an app be exempted from battery optimization. Android
/// only: iOS hands the schedule to the system, so nothing can drop it there.
bool get hasBatteryOptimization => Platform.isAndroid;

/// Opens the OS screen listing the apps exempted from battery optimization.
/// This only shows the settings, it asks for nothing: requesting the exemption
/// outright needs a policy sensitive permission a training reminder would not
/// justify.
Future<void> openBatteryOptimizationSettings() async {
  if (!hasBatteryOptimization) return;
  const intent = AndroidIntent(
    action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
  );
  await intent.launch();
}
