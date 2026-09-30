import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/training_totals.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/training_totals_card.dart';
import 'package:flutter_test/flutter_test.dart';

RepDataModel _rep({
  bool isRest = false,
  int duration = 7,
  double averageWeight = 20,
  double targetWeight = 0,
  bool targetUnmeasured = false,
}) => RepDataModel(
  averageWeight: averageWeight,
  duration: duration,
  index: 0,
  isRest: isRest,
  handSide: HandSide.right,
  targetWeight: targetWeight,
  targetUnmeasured: targetUnmeasured,
);

SessionModel _session(DateTime date, [List<RepDataModel>? reps]) =>
    SessionModel(
      name: 'Run',
      isAssessment: false,
      origin: SessionOrigin.played,
      date: date,
      reps: reps,
    );

void main() {
  test('an empty history adds up to nothing', () {
    final totals = TrainingTotals.of(const []);

    expect(totals.isEmpty, isTrue);
    expect(totals.since, isNull);
    expect(totals.heaviestPull, isNull);
  });

  test('counts sessions, days and the day the count starts from', () {
    final totals = TrainingTotals.of([
      _session(DateTime(2026, 9, 20, 9)),
      // Same day as the first, so it is a session but not a day.
      _session(DateTime(2026, 9, 20, 18)),
      _session(DateTime(2026, 9, 12, 7)),
      // A logged climb carries no reps and still counts as a day trained.
      _session(DateTime(2026, 9, 25)),
    ]);

    expect(totals.sessions, 4);
    expect(totals.daysTrained, 3);
    expect(totals.since, DateTime(2026, 9, 12));
    expect(totals.pulls, 0);
    expect(totals.heaviestPull, isNull);
  });

  test('pulls and time under tension count work reps, rests left out', () {
    final totals = TrainingTotals.of([
      _session(DateTime(2026, 9, 20), [
        _rep(duration: 7),
        _rep(isRest: true, duration: 3, averageWeight: 0),
        _rep(duration: 10),
      ]),
    ]);

    expect(totals.pulls, 2);
    expect(totals.timeUnderTensionSeconds, 17);
    expect(totals.volumeKg, 40);
  });

  // Krakoer/crimpy#25 to #30: a pull the sensor never weighed is stored at 0 kg,
  // which is no reading rather than a load. It still counts as a pull.
  test('loads count only the pulls the sensor weighed', () {
    final totals = TrainingTotals.of([
      _session(DateTime(2026, 9, 20), [
        _rep(averageWeight: 30, targetWeight: 30),
        // The sensor dropped: prescribed, performed, weighed nothing.
        _rep(averageWeight: 0, targetUnmeasured: true),
        // A both hands hang, never meant to be weighed.
        _rep(averageWeight: 0),
      ]),
    ]);

    expect(totals.pulls, 3);
    expect(totals.timeUnderTensionSeconds, 21);
    expect(totals.weighedPulls, 1);
    expect(totals.someUnweighed, isTrue);
    expect(totals.volumeKg, 30);
    expect(totals.heaviestPull?.kilograms, 30);
  });

  test('a reading below zero adds no volume and is no heaviest pull', () {
    final totals = TrainingTotals.of([
      _session(DateTime(2026, 9, 20), [_rep(averageWeight: -1.5)]),
    ]);

    expect(totals.weighedPulls, 1);
    expect(totals.volumeKg, 0);
    expect(totals.heaviestPull, isNull);
  });

  test('the heaviest pull carries the day it was pulled', () {
    final totals = TrainingTotals.of([
      _session(DateTime(2026, 9, 20), [_rep(averageWeight: 32)]),
      _session(DateTime(2026, 9, 14), [_rep(averageWeight: 41.5)]),
      _session(DateTime(2026, 9, 27), [_rep(averageWeight: 38)]),
    ]);

    expect(totals.heaviestPull?.kilograms, 41.5);
    expect(totals.heaviestPull?.date, DateTime(2026, 9, 14));
  });

  group('measuredNote', () {
    test('states the rule alone when every pull was weighed', () {
      final totals = TrainingTotals.of([
        _session(DateTime(2026, 9, 20), [_rep()]),
      ]);

      expect(
        measuredNote(totals),
        'Volume and heaviest pull count only the pulls the sensor measured.',
      );
    });

    test('says how many pulls the loads count when not all of them', () {
      final totals = TrainingTotals.of([
        _session(DateTime(2026, 9, 20), [
          _rep(),
          _rep(averageWeight: 0, targetUnmeasured: true),
        ]),
      ]);

      expect(
        measuredNote(totals),
        'Volume and heaviest pull count only the pulls the sensor measured: '
        '1 of 2.',
      );
    });
  });

  test('a volume past ten tonnes reads in tonnes', () {
    expect(formatVolume(9999), '9,999 kg');
    expect(formatVolume(12345), '12.3 t');
  });
}
