import 'package:crimpy/models/notification_preferences.dart';

/// Longest note the API accepts on a day, counted in runes.
const int maxAvailabilityNoteLength = 2000;

/// What the athlete said they can do on one day, 0=Mon..6=Sun.
///
/// Deliberately permissive: a day may carry nothing but a sentence. A coach
/// reads the note when the duration alone does not say enough.
class DayAvailability {
  final int dayOfWeek;
  final bool isAvailable;
  final int? durationMinutes;
  final String? note;

  const DayAvailability({
    required this.dayOfWeek,
    this.isAvailable = false,
    this.durationMinutes,
    this.note,
  });

  factory DayAvailability.fromJson(Map<String, dynamic> json) =>
      DayAvailability(
        dayOfWeek: (json['day_of_week'] as num).toInt(),
        isAvailable: json['is_available'] as bool? ?? false,
        durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'day_of_week': dayOfWeek,
    'is_available': isAvailable,
    'duration_minutes': durationMinutes,
    'note': note,
  };

  DayAvailability copyWith({
    bool? isAvailable,
    int? durationMinutes,
    String? note,
    bool clearDuration = false,
    bool clearNote = false,
  }) => DayAvailability(
    dayOfWeek: dayOfWeek,
    isAvailable: isAvailable ?? this.isAvailable,
    durationMinutes: clearDuration
        ? null
        : (durationMinutes ?? this.durationMinutes),
    note: clearNote ? null : (note ?? this.note),
  );
}

/// One declared calendar week, keyed by its Monday. Not a program week: an
/// athlete declares whether or not a program covers that week.
class WeekAvailability {
  final DateTime weekStart;
  final List<DayAvailability> days;

  const WeekAvailability({required this.weekStart, required this.days});

  /// A week nobody has touched yet, every day off.
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
  /// all seven days even when the athlete only touched one.
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
