import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/rep_blocks.dart';

/// A grip as a load trend tells it apart: the position and the edge it was
/// hung on. The same position on another edge is another load.
typedef LoadGrip = ({GripPosition position, int? edgeSizeMm});

/// One session's mean measured load on one grip, dated by the training day the
/// session belongs to, the day the history lists it under.
typedef LoadPoint = ({DateTime date, double kilograms});

/// The load of one training over time, grip by grip, Krakoer/crimpy#155.
class TrainingLoadTrend {
  /// What the trend is keyed by: the training played, or the name the runs
  /// carry when they name none, which is a builtin's case.
  final String key;

  /// The name of the training: the library's, when the training is one the
  /// athlete can read, and otherwise the name its latest run carries, less the
  /// date a run is saved with.
  final String title;

  /// Each grip the training was weighed on, most weighed first, with one point
  /// per session that weighed it, oldest first.
  final List<(LoadGrip, List<LoadPoint>)> grips;

  const TrainingLoadTrend({
    required this.key,
    required this.title,
    required this.grips,
  });
}

/// The least change across a series that is called one. Under half a kilo
/// between the first session and the last is grip noise, the same noise the
/// assessment charts refuse to zoom onto (assessment_chart_axes.dart), and it
/// is not called progress.
const double loadNoiseKg = 0.5;

/// The date a builtin run is named with when it is saved, " - 20/09/2026",
/// taken off so the runs of one builtin read as one training.
final _runDateSuffix = RegExp(r'\s+-\s+\d{2}/\d{2}/\d{4}$');

String _trainingName(SessionModel session) =>
    session.name.replaceFirst(_runDateSuffix, '').trim();

String _trainingKey(SessionModel session) =>
    session.trainingId ?? 'name:${_trainingName(session)}';

/// The load trends of a history, one per training the athlete has run at least
/// twice with the sensor, the most recently run first.
///
/// Per training rather than pooled: the same grip at two intensities is two
/// lines, and pooling a light repeater with a heavy max hang draws a zigzag
/// that tracks which training ran. A point is the mean load of the reps the
/// sensor weighed on that grip in that session, the set every load of a session
/// card is stated over (Krakoer/crimpy#25 to #30), so a rep it never weighed
/// is left out rather than averaged in as a zero. The mean rather than the
/// peak: it is what the fingers absorbed. Assessments are left out, since the
/// profile already charts them.
List<TrainingLoadTrend> loadTrendsOf(
  List<SessionModel> history, {
  Map<String, String> trainingTitles = const {},
}) {
  final sessionsByTraining = <String, List<SessionModel>>{};
  for (final session in history) {
    if (session.isAssessment) continue;
    if (_loadedReps(session).isEmpty) continue;
    sessionsByTraining
        .putIfAbsent(_trainingKey(session), () => [])
        .add(session);
  }

  final trends = <(DateTime, TrainingLoadTrend)>[];
  for (final MapEntry(key: key, value: sessions)
      in sessionsByTraining.entries) {
    if (sessions.length < 2) continue;
    sessions.sort((a, b) => a.date.compareTo(b.date));

    final pointsByGrip = <LoadGrip, List<LoadPoint>>{};
    for (final session in sessions) {
      final byGrip = <LoadGrip, List<double>>{};
      for (final rep in _loadedReps(session)) {
        final grip = (position: rep.gripPosition, edgeSizeMm: rep.edgeSizeMm);
        byGrip.putIfAbsent(grip, () => []).add(rep.averageWeight);
      }
      for (final MapEntry(key: grip, value: loads) in byGrip.entries) {
        pointsByGrip.putIfAbsent(grip, () => []).add((
          date: session.trainingDay,
          kilograms: loads.reduce((a, b) => a + b) / loads.length,
        ));
      }
    }

    final grips = pointsByGrip.entries.map((e) => (e.key, e.value)).toList()
      ..sort((a, b) => b.$2.length.compareTo(a.$2.length));
    trends.add((
      sessions.last.date,
      TrainingLoadTrend(
        key: key,
        title:
            trainingTitles[sessions.last.trainingId] ??
            _trainingName(sessions.last),
        grips: grips,
      ),
    ));
  }

  trends.sort((a, b) => b.$1.compareTo(a.$1));
  return [for (final (_, trend) in trends) trend];
}

/// The reps of a session that put a load on the sensor: the weighed ones
/// (Krakoer/crimpy#25 to #30), less a reading at or below zero, which is a
/// sensor tared under load rather than a load the fingers took. A mean over
/// it would draw under the chart's baseline and call the drop a loss.
List<RepDataModel> _loadedReps(SessionModel session) => weighedReps(
  session.reps ?? const [],
).where((rep) => rep.averageWeight > 0).toList();

/// A grip as a chip names it: "Half Crimp 20 mm".
String loadGripLabel(LoadGrip grip) => grip.edgeSizeMm == null
    ? grip.position.displayName
    : '${grip.position.displayName} ${grip.edgeSizeMm} mm';

/// What a series says about the load, in words, beside its line. The change is
/// from the first session to the last, and under [loadNoiseKg] of it is named
/// as noise rather than as a gain or a loss.
String loadTrendNote(List<LoadPoint> points, String Function(DateTime) date) {
  final first = points.first;
  final change = points.last.kilograms - first.kilograms;
  final since = 'since ${date(first.date)}';
  if (change.abs() < loadNoiseKg) {
    return 'Within half a kilo $since: grip noise, not progress.';
  }
  final amount = '${change.abs().toStringAsFixed(1)} kg';
  return change > 0 ? 'Up $amount $since.' : 'Down $amount $since.';
}
