import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/load_trends.dart';
import 'package:flutter_test/flutter_test.dart';

RepDataModel _rep(
  double averageWeight, {
  GripPosition grip = GripPosition.halfCrimp,
  int? edge = 20,
  bool isRest = false,
  bool targetUnmeasured = false,
  double targetWeight = 20,
}) => RepDataModel(
  averageWeight: averageWeight,
  duration: 7,
  index: 0,
  isRest: isRest,
  handSide: HandSide.right,
  targetWeight: targetWeight,
  gripPosition: grip,
  edgeSizeMm: edge,
  targetUnmeasured: targetUnmeasured,
);

SessionModel _run(
  DateTime date,
  List<RepDataModel> reps, {
  String? trainingId = 'repeaters',
  String name = 'Repeaters 20mm',
  bool isAssessment = false,
}) => SessionModel(
  name: name,
  isAssessment: isAssessment,
  origin: SessionOrigin.played,
  date: date,
  reps: reps,
  trainingId: trainingId,
);

String _day(DateTime date) => '${date.month}/${date.day}';

void main() {
  test('a training run once with the sensor has no trend yet', () {
    expect(
      loadTrendsOf([
        _run(DateTime(2026, 9, 8), [_rep(20)]),
      ]),
      isEmpty,
    );
  });

  test('a point is the mean of the weighed reps, one per session', () {
    final trends = loadTrendsOf([
      _run(DateTime(2026, 9, 8), [
        _rep(19),
        _rep(0, isRest: true, targetWeight: 0),
        _rep(21),
      ]),
      _run(DateTime(2026, 9, 12), [_rep(22)]),
    ]);

    final (grip, points) = trends.single.grips.single;
    expect(grip, (position: GripPosition.halfCrimp, edgeSizeMm: 20));
    expect(points.map((p) => p.kilograms), [20, 22]);
  });

  // Krakoer/crimpy#25 to #30: a rep the sensor never weighed is left out, not
  // averaged in as a zero, and a run it weighed nothing in is not a sensor run.
  test('leaves the unmeasured reps and the sensorless runs out', () {
    final trends = loadTrendsOf([
      _run(DateTime(2026, 9, 8), [
        _rep(20),
        _rep(0, targetUnmeasured: true, targetWeight: 0),
      ]),
      _run(DateTime(2026, 9, 10), [_rep(0, targetWeight: 0)]),
      _run(DateTime(2026, 9, 12), [_rep(21)]),
    ]);

    final points = trends.single.grips.single.$2;
    expect(points.map((p) => p.kilograms), [20, 21]);
  });

  test('keeps trainings apart and each grip on its own line', () {
    final trends = loadTrendsOf([
      _run(DateTime(2026, 9, 8), [
        _rep(20),
        _rep(15, grip: GripPosition.openHand),
      ]),
      _run(DateTime(2026, 9, 12), [_rep(21), _rep(10, edge: 15)]),
      _run(DateTime(2026, 9, 9), [_rep(32)], trainingId: 'max'),
      _run(DateTime(2026, 9, 14), [_rep(33)], trainingId: 'max'),
    ]);

    // The most recently run first.
    expect(trends.map((t) => t.key), ['max', 'repeaters']);
    final repeaters = trends.last.grips;
    // The most weighed grip first.
    expect(repeaters.first.$1, (
      position: GripPosition.halfCrimp,
      edgeSizeMm: 20,
    ));
    expect(repeaters, hasLength(3));
    expect(trends.first.grips.single.$2.map((p) => p.kilograms), [32, 33]);
  });

  test('reads the runs of a builtin as one training by their name', () {
    final trends = loadTrendsOf([
      _run(
        DateTime(2026, 9, 8),
        [_rep(20)],
        trainingId: null,
        name: 'Max Hangs - 08/09/2026',
      ),
      _run(
        DateTime(2026, 9, 12),
        [_rep(21)],
        trainingId: null,
        name: 'Max Hangs - 12/09/2026',
      ),
    ]);

    expect(trends.single.title, 'Max Hangs');
  });

  test('leaves assessments to the profile', () {
    expect(
      loadTrendsOf([
        _run(DateTime(2026, 9, 8), [_rep(40)], isAssessment: true),
        _run(DateTime(2026, 9, 12), [_rep(41)], isAssessment: true),
      ]),
      isEmpty,
    );
  });

  group('loadTrendNote', () {
    LoadPoint point(int day, double kg) =>
        (date: DateTime(2026, 9, day), kilograms: kg);

    test('calls under half a kilo grip noise, not progress', () {
      expect(
        loadTrendNote([point(8, 20), point(12, 21.2), point(20, 20.4)], _day),
        'Within half a kilo since 9/8: grip noise, not progress.',
      );
    });

    test('states a gain and a loss from the first session to the last', () {
      expect(
        loadTrendNote([point(8, 20), point(20, 21.4)], _day),
        'Up 1.4 kg since 9/8.',
      );
      expect(
        loadTrendNote([point(8, 20), point(20, 19.2)], _day),
        'Down 0.8 kg since 9/8.',
      );
    });
  });
}
