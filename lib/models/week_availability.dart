import 'package:crimpy/models/notification_preferences.dart';
import 'package:flutter/foundation.dart';

/// Longest free text the API accepts on any one field of an activity, counted
/// in runes.
const int maxActivityTextLength = 200;

/// Most activities the API accepts on a single day. A list with no ceiling
/// would let one athlete decide how big every response carrying it is.
const int maxActivitiesPerDay = 20;

/// One thing the athlete plans to do on a day.
///
/// Only the label is required. A duration they cannot guess, or a place they
/// have not picked, are left out rather than invented, and "when" is free text
/// rather than a slot: "before work" and "after the kids are down" are both
/// answers a coach reads, and neither is a morning or an afternoon.
class DayActivity {
  final String label;
  final int? durationMinutes;
  final String? when;
  final String? where;

  const DayActivity({
    required this.label,
    this.durationMinutes,
    this.when,
    this.where,
  });

  factory DayActivity.fromJson(Map<String, dynamic> json) => DayActivity(
    label: json['label'] as String? ?? '',
    durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
    when: json['when'] as String?,
    where: json['where'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'label': label,
    'duration_minutes': durationMinutes,
    'when': when,
    'where': where,
  };

  // Compared by value so an edit that changed nothing is not treated as one.
  // Re-declaring a week moves its updated_at, which puts it back at the top of
  // the coach's feed as a fresh answer, so "the athlete opened it and pressed
  // save" would read to them as "the athlete changed their week".
  @override
  bool operator ==(Object other) =>
      other is DayActivity &&
      other.label == label &&
      other.durationMinutes == durationMinutes &&
      other.when == when &&
      other.where == where;

  @override
  int get hashCode => Object.hash(label, durationMinutes, when, where);
}

/// What the athlete plans on one day, 0=Mon..6=Sun.
///
/// A day with an empty list is an answer, not a gap: it says nothing is on.
class DayAvailability {
  final int dayOfWeek;
  final List<DayActivity> activities;

  const DayAvailability({required this.dayOfWeek, this.activities = const []});

  factory DayAvailability.fromJson(Map<String, dynamic> json) =>
      DayAvailability(
        dayOfWeek: (json['day_of_week'] as num).toInt(),
        activities: [
          for (final raw in (json['activities'] as List? ?? const []))
            DayActivity.fromJson(raw as Map<String, dynamic>),
        ],
      );

  Map<String, dynamic> toJson() => {
    'day_of_week': dayOfWeek,
    'activities': [for (final activity in activities) activity.toJson()],
  };

  /// Minutes the day adds up to, counting only the activities that gave one.
  int get plannedMinutes => activities.fold(
    0,
    (total, activity) => total + (activity.durationMinutes ?? 0),
  );

  DayAvailability withActivities(List<DayActivity> activities) =>
      DayAvailability(dayOfWeek: dayOfWeek, activities: activities);

  @override
  bool operator ==(Object other) =>
      other is DayAvailability &&
      other.dayOfWeek == dayOfWeek &&
      listEquals(other.activities, activities);

  @override
  int get hashCode => Object.hash(dayOfWeek, Object.hashAll(activities));
}

/// One declared calendar week, keyed by its Monday. Not a program week: an
/// athlete declares whether or not a program covers that week.
class WeekAvailability {
  final DateTime weekStart;
  final List<DayAvailability> days;

  const WeekAvailability({required this.weekStart, required this.days});

  /// A week nobody has touched yet, nothing planned on any day.
  factory WeekAvailability.empty(DateTime weekStart) => WeekAvailability(
    weekStart: weekStart,
    days: [for (var day = 0; day < 7; day++) DayAvailability(dayOfWeek: day)],
  );

  factory WeekAvailability.fromJson(Map<String, dynamic> json) {
    final declared = <int, DayAvailability>{};
    for (final raw in (json['days'] as List? ?? const [])) {
      final day = DayAvailability.fromJson(raw as Map<String, dynamic>);
      declared[day.dayOfWeek] = day;
    }
    return WeekAvailability(
      weekStart: DateTime.parse(json['week_start'] as String),
      days: [
        for (var day = 0; day < 7; day++)
          declared[day] ?? DayAvailability(dayOfWeek: day),
      ],
    );
  }

  /// The API only ever holds a week written whole, so the body always carries
  /// all seven days even when the athlete only touched one, and even when
  /// every one of them is empty.
  Map<String, dynamic> toJson() => {
    'days': days.map((day) => day.toJson()).toList(),
  };

  WeekAvailability withDay(DayAvailability day) => WeekAvailability(
    weekStart: weekStart,
    days: [
      for (final existing in days)
        existing.dayOfWeek == day.dayOfWeek ? day : existing,
    ],
  );

  // Compared by value so a screen can ask whether the week still says what it
  // was loaded saying, rather than remembering that something was touched. A
  // flag cannot tell an edit from an edit that was undone, and re-sending an
  // unchanged week re-dates the declaration, which reaches the coach's feed as
  // an answer the athlete did not give.
  @override
  bool operator ==(Object other) =>
      other is WeekAvailability &&
      other.weekStart == weekStart &&
      listEquals(other.days, days);

  @override
  int get hashCode => Object.hash(weekStart, Object.hashAll(days));

  int get plannedActivityCount =>
      days.fold(0, (total, day) => total + day.activities.length);

  int get plannedDayCount =>
      days.where((day) => day.activities.isNotEmpty).length;

  int get plannedMinutes =>
      days.fold(0, (total, day) => total + day.plannedMinutes);
}

/// The weekly nudge a coach configured for the athletes they train. The hour is
/// a wall clock time raised on the athlete's own device, in the athlete's own
/// timezone, since the backend has no scheduler and no push channel.
class CoachAvailabilityReminder {
  final bool enabled;
  final int dayOfWeek;
  final ReminderTime time;

  const CoachAvailabilityReminder({
    required this.enabled,
    required this.dayOfWeek,
    required this.time,
  });

  factory CoachAvailabilityReminder.fromJson(Map<String, dynamic> json) =>
      CoachAvailabilityReminder(
        enabled: json['enabled'] as bool? ?? false,
        dayOfWeek: (json['day_of_week'] as num).toInt(),
        time: ReminderTime.fromJson(json),
      );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'day_of_week': dayOfWeek,
    ...time.toJson(),
  };
}

/// The date part alone, which is what the API keys a week on.
String formatWeekStart(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

/// The reminder and the weeks already declared, mirrored on the device so the
/// nudge is planned even when the app opens offline. A coach who set none is
/// stored as a plan with a null reminder rather than as no plan at all, so a
/// 404 is remembered as "off" and not re-read as a failure forever.
class CachedAvailabilityPlan {
  final CoachAvailabilityReminder? reminder;
  final Set<DateTime> declaredWeekStarts;

  const CachedAvailabilityPlan({
    required this.reminder,
    required this.declaredWeekStarts,
  });

  factory CachedAvailabilityPlan.fromJson(Map<String, dynamic> json) =>
      CachedAvailabilityPlan(
        reminder: json['reminder'] == null
            ? null
            : CoachAvailabilityReminder.fromJson(
                json['reminder'] as Map<String, dynamic>,
              ),
        declaredWeekStarts: {
          for (final raw in (json['declared_week_starts'] as List? ?? const []))
            DateTime.parse(raw as String),
        },
      );

  Map<String, dynamic> toJson() => {
    'reminder': reminder?.toJson(),
    'declared_week_starts': declaredWeekStarts.map(formatWeekStart).toList(),
  };
}
