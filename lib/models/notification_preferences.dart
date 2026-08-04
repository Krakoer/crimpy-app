/// A time of day a reminder is delivered at.
class ReminderTime {
  final int hour;
  final int minute;

  const ReminderTime(this.hour, this.minute);

  factory ReminderTime.fromJson(Map<String, dynamic> json) => ReminderTime(
    (json['hour'] as num).toInt(),
    (json['minute'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {'hour': hour, 'minute': minute};

  @override
  bool operator ==(Object other) =>
      other is ReminderTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Every weekday index, 0=Mon..6=Sun.
const Set<int> allWeekdays = {0, 1, 2, 3, 4, 5, 6};

/// Weekdays a flexible ("X times per week") training is reminded on when the
/// user has not chosen any: [timesPerWeek] days spread evenly from Monday, so
/// three times a week gives Monday, Wednesday and Saturday.
Set<int> defaultFlexibleDays(int timesPerWeek) {
  final count = timesPerWeek.clamp(1, 7);
  return {for (var i = 0; i < count; i++) (i * 7 / count).round()};
}

/// Device-local settings driving the daily training reminder.
class NotificationPreferences {
  final bool enabled;
  final ReminderTime primaryTime;
  final ReminderTime? secondaryTime;

  /// Weekdays the reminder may fire on, 0=Mon..6=Sun.
  final Set<int> activeWeekdays;

  /// Weekdays chosen for flexible trainings, keyed by training id. Training ids
  /// are stable across weeks, unlike the week session ids.
  final Map<String, Set<int>> flexibleTrainingDays;

  const NotificationPreferences({
    this.enabled = false,
    this.primaryTime = const ReminderTime(8, 0),
    this.secondaryTime,
    this.activeWeekdays = allWeekdays,
    this.flexibleTrainingDays = const {},
  });

  /// The enabled reminder times, ordered so the index is the notification slot.
  List<ReminderTime> get times => [
    primaryTime,
    if (secondaryTime != null) secondaryTime!,
  ];

  /// Weekdays [trainingId] is reminded on, falling back to an even spread over
  /// the week when the user has not chosen any.
  Set<int> flexibleDaysFor(String trainingId, int timesPerWeek) =>
      flexibleTrainingDays[trainingId] ?? defaultFlexibleDays(timesPerWeek);

  NotificationPreferences copyWith({
    bool? enabled,
    ReminderTime? primaryTime,
    ReminderTime? secondaryTime,
    bool clearSecondaryTime = false,
    Set<int>? activeWeekdays,
    Map<String, Set<int>>? flexibleTrainingDays,
  }) => NotificationPreferences(
    enabled: enabled ?? this.enabled,
    primaryTime: primaryTime ?? this.primaryTime,
    secondaryTime: clearSecondaryTime
        ? null
        : (secondaryTime ?? this.secondaryTime),
    activeWeekdays: activeWeekdays ?? this.activeWeekdays,
    flexibleTrainingDays: flexibleTrainingDays ?? this.flexibleTrainingDays,
  );

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    final secondary = json['secondary_time'] as Map<String, dynamic>?;
    final weekdays = (json['active_weekdays'] as List<dynamic>?)
        ?.map((e) => (e as num).toInt())
        .toSet();
    final flexible = (json['flexible_training_days'] as Map<String, dynamic>?)
        ?.map(
          (key, value) => MapEntry(
            key,
            (value as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
          ),
        );
    return NotificationPreferences(
      enabled: json['enabled'] as bool? ?? false,
      primaryTime: json['primary_time'] == null
          ? const ReminderTime(8, 0)
          : ReminderTime.fromJson(json['primary_time'] as Map<String, dynamic>),
      secondaryTime: secondary == null
          ? null
          : ReminderTime.fromJson(secondary),
      activeWeekdays: weekdays == null || weekdays.isEmpty
          ? allWeekdays
          : weekdays,
      flexibleTrainingDays: flexible ?? const {},
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'primary_time': primaryTime.toJson(),
    'secondary_time': secondaryTime?.toJson(),
    'active_weekdays': activeWeekdays.toList()..sort(),
    'flexible_training_days': flexibleTrainingDays.map(
      (key, value) => MapEntry(key, value.toList()..sort()),
    ),
  };
}
