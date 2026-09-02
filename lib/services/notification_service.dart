import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/utils/availability_reminder_plan.dart';
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

  static const String _coachReplyChannelId = 'coach_replies';
  static const String _coachReplyChannelName = 'Coach replies';
  static const String _coachReplyChannelDescription =
      'Tells you when your coach answered the feedback you left on a session.';

  static const AndroidNotificationChannel _coachReplyChannel =
      AndroidNotificationChannel(
        _coachReplyChannelId,
        _coachReplyChannelName,
        description: _coachReplyChannelDescription,
        importance: Importance.defaultImportance,
      );

  static const String _availabilityChannelId = 'availability_reminders';
  static const String _availabilityChannelName = 'Availability reminders';
  static const String _availabilityChannelDescription =
      'Reminds you to tell your coach when you can train next week.';

  static const AndroidNotificationChannel _availabilityChannel =
      AndroidNotificationChannel(
        _availabilityChannelId,
        _availabilityChannelName,
        description: _availabilityChannelDescription,
        importance: Importance.defaultImportance,
      );

  // No snooze action and no Darwin category: postponing this one by an hour
  // says nothing, and the button would route into the training snooze flow.
  static const NotificationDetails _availabilityDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _availabilityChannelId,
      _availabilityChannelName,
      channelDescription: _availabilityChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );

  // A separate channel from the reminders so the two can be silenced apart: a
  // reminder is a nudge the user may not want, an answer from their coach is
  // not the same thing.
  static const NotificationDetails _coachReplyDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _coachReplyChannelId,
      _coachReplyChannelName,
      channelDescription: _coachReplyChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
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
    await _androidPlugin?.createNotificationChannel(_coachReplyChannel);
    await _androidPlugin?.createNotificationChannel(_availabilityChannel);

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

  /// Whether this platform can deliver a notification at all. Exposed on the
  /// service rather than read off [supportsTrainingReminders] directly so the
  /// callers deciding what to offer stay testable off a device.
  bool get canNotify => supportsTrainingReminders;

  /// Whether the OS currently accepts our notifications. Asked rather than
  /// assumed: a coach answer is dropped silently when it does not, and the
  /// announcer must not record it as delivered.
  Future<bool> hasPermission() async {
    if (!supportsTrainingReminders) return false;
    await initialize();
    if (Platform.isAndroid) {
      return await _androidPlugin?.areNotificationsEnabled() ?? true;
    }
    if (Platform.isIOS) {
      // Initialization asks for nothing, so an athlete who never turned
      // reminders on has never been prompted and holds no permission.
      // A provisional grant still delivers, quietly, so it counts.
      final options = await _iosPlugin?.checkPermissions();
      if (options == null) return false;
      return options.isEnabled || options.isProvisionalEnabled;
    }
    return true;
  }

  /// Replaces every pending reminder with [occurrences]. Ids are derived from
  /// the day and slot, so an unchanged plan rewrites itself identically.
  Future<void> scheduleAll(List<ReminderOccurrence> occurrences) => _serialized(
    () => _scheduleBlock(
      occurrences,
      base: reminderIdBase,
      size: reminderIdBlockSize,
      details: _details,
      label: 'training',
    ),
  );

  /// Replaces every pending availability reminder. Its own id block, so writing
  /// one plan never clears the other.
  Future<void> scheduleAvailabilityReminders(
    List<ReminderOccurrence> occurrences,
  ) => _serialized(
    () => _scheduleBlock(
      occurrences,
      base: availabilityReminderIdBase,
      size: availabilityReminderIdBlockSize,
      details: _availabilityDetails,
      label: 'availability',
    ),
  );

  Future<void> _scheduleBlock(
    List<ReminderOccurrence> occurrences, {
    required int base,
    required int size,
    required NotificationDetails details,
    required String label,
  }) async {
    await initialize();
    if (!supportsTrainingReminders) return;
    await _cancelBlock(base, size);
    for (final occurrence in occurrences) {
      await _plugin.zonedSchedule(
        id: occurrence.notificationId,
        title: occurrence.title,
        body: occurrence.body,
        scheduledDate: tz.TZDateTime.from(occurrence.when, tz.local),
        notificationDetails: details,
        // Reminders do not need minute precision, and inexact alarms avoid the
        // exact alarm permission Android 14 puts behind a policy review.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
    AppLoggerHelper.debug('Scheduled ${occurrences.length} $label reminders');
  }

  /// Posts the answer a coach wrote to a session, right now. Unlike a reminder
  /// this is not scheduled: the answer is already there by the time the app
  /// learns of it.
  Future<void> showCoachReply({
    required int id,
    required String title,
    required String body,
  }) async {
    await initialize();
    if (!supportsTrainingReminders) return;
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _coachReplyDetails,
    );
  }

  /// Takes one coach reply notification out of the shade, for an answer the
  /// athlete has since read in the app.
  Future<void> cancelCoachReply(int id) async {
    await initialize();
    if (!supportsTrainingReminders) return;
    await _plugin.cancel(id: id);
  }

  /// Cancels the training reminder id block only, leaving any other
  /// notification alone.
  Future<void> cancelAll() => _serialized(_cancelAll);

  /// Cancels the availability reminder id block only.
  Future<void> cancelAvailabilityReminders() => _serialized(
    () => _cancelBlock(
      availabilityReminderIdBase,
      availabilityReminderIdBlockSize,
    ),
  );

  Future<void> _cancelAll() =>
      _cancelBlock(reminderIdBase, reminderIdBlockSize);

  Future<void> _cancelBlock(int base, int size) async {
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
      if (idIsInBlock(id, base, size)) {
        await _plugin.cancel(id: id);
      }
    }
  }
}

/// Shown wherever a permission request comes back denied. One copy, so the
/// reminder settings and the coach answer ask cannot drift apart.
const String notificationsBlockedMessage =
    'Notifications are blocked. Enable them for Crimpy in your device settings.';

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
