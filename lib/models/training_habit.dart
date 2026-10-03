import 'package:crimpy/models/training.dart';

/// A training of the athlete's own they set themselves to keep up without a
/// coach: on chosen weekdays, or a number of times a week. Kept on the device,
/// like the reminder settings. See Krakoer/crimpy#153.
///
/// Carries the training's id and not its title: the title is read from the
/// library, so a renamed training is named as it is now.
class TrainingHabit {
  final String trainingId;

  /// Weekdays the training is due on, 0=Mon..6=Sun. Empty for a habit counted
  /// per week instead.
  final Set<int> weekdays;

  /// How many times a week the training is due, on no set day. Null for a habit
  /// set on weekdays.
  final int? timesPerWeek;

  /// The training day the habit was set or last changed. Days before it owed
  /// nothing, so the consistency strip does not draw them as misses.
  final DateTime since;

  const TrainingHabit.onWeekdays({
    required this.trainingId,
    required this.weekdays,
    required this.since,
  }) : timesPerWeek = null;

  const TrainingHabit.perWeek({
    required this.trainingId,
    required int this.timesPerWeek,
    required this.since,
  }) : weekdays = const {};

  bool get isPerWeek => timesPerWeek != null;

  /// Whether the habit asks for the training on [day] specifically.
  bool isDueOn(DateTime day) =>
      !isPerWeek && weekdays.contains(day.weekday - DateTime.monday);

  factory TrainingHabit.fromJson(Map<String, dynamic> json) {
    final trainingId = json['training_id'] as String;
    final since = DateTime.parse(json['since'] as String);
    final times = (json['times_per_week'] as num?)?.toInt();
    if (times != null) {
      return TrainingHabit.perWeek(
        trainingId: trainingId,
        timesPerWeek: times.clamp(1, 7),
        since: since,
      );
    }
    return TrainingHabit.onWeekdays(
      trainingId: trainingId,
      weekdays: {
        for (final day in json['weekdays'] as List<dynamic>? ?? const [])
          (day as num).toInt(),
      },
      since: since,
    );
  }

  Map<String, dynamic> toJson() => {
    'training_id': trainingId,
    if (isPerWeek)
      'times_per_week': timesPerWeek
    else
      'weekdays': (weekdays.toList()..sort()),
    'since':
        '${since.year.toString().padLeft(4, '0')}-'
        '${since.month.toString().padLeft(2, '0')}-'
        '${since.day.toString().padLeft(2, '0')}',
  };

  @override
  bool operator ==(Object other) =>
      other is TrainingHabit &&
      other.trainingId == trainingId &&
      other.timesPerWeek == timesPerWeek &&
      other.since == since &&
      other.weekdays.length == weekdays.length &&
      other.weekdays.containsAll(weekdays);

  @override
  int get hashCode => Object.hash(
    trainingId,
    timesPerWeek,
    since,
    Object.hashAllUnordered(weekdays),
  );
}

/// A habit together with the training it names, as the library holds it now.
class ActiveHabit {
  final TrainingHabit habit;
  final Training training;

  const ActiveHabit(this.habit, this.training);

  String get trainingId => habit.trainingId;
  String get title => training.title;
}
