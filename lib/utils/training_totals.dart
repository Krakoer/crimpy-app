import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/rep_blocks.dart';

/// The heaviest single pull of a history, and the day it was pulled.
typedef HeaviestPull = ({double kilograms, DateTime date});

/// What an athlete has done since they started recording, all sessions added
/// up: the odometer of Krakoer/crimpy#150.
///
/// The counts of work ([pulls], [timeUnderTensionSeconds]) take every work rep,
/// measured or not, since a pull the sensor did not see was still pulled. The
/// loads ([volumeKg], [heaviestPull]) take only the reps the sensor weighed,
/// the set every load of a session card is stated over (rep_blocks.dart,
/// Krakoer/crimpy#25 to #30): a rep it never weighed is stored at 0 kg, which is
/// the absence of a reading rather than a load, so it adds nothing to a load
/// and stands for none. [weighedPulls] says how many that was, so the card can
/// say how much of [pulls] the loads count.
class TrainingTotals {
  final int sessions;
  final int daysTrained;
  final int pulls;
  final int weighedPulls;
  final int timeUnderTensionSeconds;
  final double volumeKg;
  final HeaviestPull? heaviestPull;

  /// The day of the first session counted, null when there is none.
  final DateTime? since;

  const TrainingTotals({
    required this.sessions,
    required this.daysTrained,
    required this.pulls,
    required this.weighedPulls,
    required this.timeUnderTensionSeconds,
    required this.volumeKg,
    required this.heaviestPull,
    required this.since,
  });

  static const none = TrainingTotals(
    sessions: 0,
    daysTrained: 0,
    pulls: 0,
    weighedPulls: 0,
    timeUnderTensionSeconds: 0,
    volumeKg: 0,
    heaviestPull: null,
    since: null,
  );

  bool get isEmpty => sessions == 0;

  /// Whether some of the pulls counted went unweighed, which is when the card
  /// has to say that its loads count fewer pulls than it states.
  bool get someUnweighed => weighedPulls < pulls;

  /// Adds up [history], every session the athlete has, each carrying its reps.
  ///
  /// Every session counts toward [sessions] and [daysTrained], a logged climb
  /// included: the card rewards turning up, and a climbing day is a day trained.
  /// Days are calendar days on the device's clock, which is the day the athlete
  /// lived.
  ///
  /// Volume is load times pulls, the sum of the mean load of every weighed rep.
  /// A reading below zero, a sensor tared under load, adds nothing rather than
  /// taking load away: it is a pull the athlete made, not one they undid.
  factory TrainingTotals.of(List<SessionModel> history) {
    if (history.isEmpty) return none;

    final days = <DateTime>{};
    var pulls = 0;
    var weighedPulls = 0;
    var timeUnderTension = 0;
    var volume = 0.0;
    HeaviestPull? heaviest;
    DateTime? since;

    for (final session in history) {
      final day = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      days.add(day);
      if (since == null || day.isBefore(since)) since = day;

      final reps = session.reps ?? const <RepDataModel>[];
      final workReps = reps.where((rep) => !rep.isRest);
      pulls += workReps.length;
      timeUnderTension += workReps.fold(0, (sum, rep) => sum + rep.duration);

      final weighed = weighedReps(reps);
      weighedPulls += weighed.length;
      for (final rep in weighed) {
        if (rep.averageWeight > 0) volume += rep.averageWeight;
      }

      final max = measuredMaxWeight(reps);
      if (max != null &&
          max > 0 &&
          (heaviest == null || max > heaviest.kilograms)) {
        heaviest = (kilograms: max, date: session.date);
      }
    }

    return TrainingTotals(
      sessions: history.length,
      daysTrained: days.length,
      pulls: pulls,
      weighedPulls: weighedPulls,
      timeUnderTensionSeconds: timeUnderTension,
      volumeKg: volume,
      heaviestPull: heaviest,
      since: since,
    );
  }
}
