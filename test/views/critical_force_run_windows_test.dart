import 'package:clock/clock.dart';
import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_result_screen.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_run_screen.dart';
import 'package:crimpy/views/widgets/workout_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/run_drafts.dart';

class _Connected extends BleConnection {
  @override
  BleConnectionState build() => BleConnectionState.connected;
}

/// The samples the run reads, added by hand with the fake clock's time.
class _HandFedSamples extends BleDataStream {
  final List<BleDataPoint> points = [];

  @override
  // One empty reading list, so the live graph lays out as it does on a
  // phone once the sensor streams.
  Stream<List<BleDataPoint>> build() => Stream.value(const []);

  @override
  double? lastValue() => points.lastOrNull?.value;

  @override
  List<BleDataPoint> getData() => points;
}

class _NoHistory extends Assessments {
  @override
  Future<List<AssessmentModel>> build(String? assessmentId) async => const [];

  @override
  Future<double?> getLastValueForHand(
    HandSide handSide, {
    GripPosition? gripPosition,
  }) async => null;
}

const _pull = TimedItem(
  label: 'Pull',
  durationSeconds: 2,
  targetLoad: 0,
  handSide: HandSide.right,
  gripPosition: GripPosition.halfCrimp,
  collectSensorData: true,
);

const _rest = RestItem(durationSeconds: 1);

/// A 1 s lead-in, then four 2 s pulls with 1 s between them.
const _reps = [_rest, _pull, _rest, _pull, _rest, _pull, _rest, _pull];

/// Puts the run on screen with [samples] as the sensor.
Future<State> _pumpRun(
  WidgetTester tester,
  ManualCrimpyWatch watch,
  _HandFedSamples samples,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...runDraftOverrides(),
        bleRepositoryProvider.overrideWithValue(BleRepository()),
        connectionStateProvider.overrideWith(_Connected.new),
        bleDataStreamProvider.overrideWith(() => samples),
        assessmentsProvider.overrideWith(_NoHistory.new),
      ],
      child: MaterialApp(
        home: CriticalForceRunScreen(
          reps: [..._reps],
          hand: HandSide.right,
          watch: watch,
        ),
      ),
    ),
  );
  return tester.state(find.byType(CriticalForceRunScreen));
}

/// Moves the run clock and the wall clock on together until the run clock
/// reads [untilMs], feeding nothing in the lead-in, 10 kg in the pulls and
/// 30 kg in the rests.
Future<void> _runUntil(
  WidgetTester tester,
  ManualCrimpyWatch watch,
  _HandFedSamples samples,
  int untilMs,
) async {
  for (var ms = watch.elapsedMilliseconds; ms < untilMs; ms += 100) {
    final inPull = ms >= 1000 && (ms - 1000) % 3000 <= 2000;
    final kg = ms < 1000 ? 0.0 : (inPull ? 10.0 : 30.0);
    samples.points.add(BleDataPoint(kg, clock.now()));
    watch.advance(100);
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The athlete takes the edge while the test waits for the first pull. The
/// reading arrives a tick before the run sees it, and the run clock has to
/// pick up from the reading, so the readings fed after it keep matching it.
Future<void> _pullToStart(WidgetTester tester, _HandFedSamples samples) async {
  samples.points.add(BleDataPoint(10, clock.now()));
  await tester.pump(const Duration(milliseconds: 100));
}

/// Runs the lead-in and starts pull 1 right as it ends.
Future<void> _startTest(
  WidgetTester tester,
  ManualCrimpyWatch watch,
  _HandFedSamples samples,
) async {
  await _runUntil(tester, watch, samples, 1000);
  await _pullToStart(tester, samples);
}

// ignore: avoid_dynamic_calls
bool _waiting(State state) => (state as dynamic).waitingForFirstPull as bool;

// ignore: avoid_dynamic_calls
bool _clockRunning(State state) => (state as dynamic).timer.isRunning as bool;

const _windowsOnTheBells = [
  (start: 1000, end: 3000),
  (start: 4000, end: 6000),
  (start: 7000, end: 9000),
  (start: 10000, end: 12000),
];

void main() {
  testWidgets('a pause in a pull does not reach its window', (tester) async {
    final watch = ManualCrimpyWatch();
    final samples = _HandFedSamples();
    final state = await _pumpRun(tester, watch, samples);

    await _startTest(tester, watch, samples);
    await _runUntil(tester, watch, samples, 4500);
    // Back opens the leave dialog, which stops the run clock. The athlete
    // hangs off the edge at 30 kg for 5 s meanwhile.
    await tester.binding.handlePopRoute();
    await tester.pump();
    for (var i = 0; i < 50; i++) {
      samples.points.add(BleDataPoint(30, clock.now()));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.text('Keep going'));
    await tester.pump();
    await _runUntil(tester, watch, samples, 12000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // ignore: avoid_dynamic_calls
    expect((state as dynamic).pullWindows, _windowsOnTheBells);
    expect(find.text('10.00 kg'), findsOneWidget);
    expect(find.textContaining('paused for 5 s'), findsOneWidget);
  });

  testWidgets('dismissing the leave dialog beside it keeps the run going', (
    tester,
  ) async {
    final watch = ManualCrimpyWatch();
    final state = await _pumpRun(tester, watch, _HandFedSamples());

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.tapAt(const Offset(10, 10));
    await tester.pump();

    // ignore: avoid_dynamic_calls
    expect((state as dynamic).timer.isRunning, isTrue);
  });

  testWidgets('the pull windows sit on the bells and the force in them is '
      'the result', (tester) async {
    final watch = ManualCrimpyWatch();
    final samples = _HandFedSamples();
    final state = await _pumpRun(tester, watch, samples);

    await _startTest(tester, watch, samples);
    await _runUntil(tester, watch, samples, 4000);
    // ignore: avoid_dynamic_calls
    expect((state as dynamic).pullWindows, [(start: 1000, end: 3000)]);
    await _runUntil(tester, watch, samples, 12000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // ignore: avoid_dynamic_calls
    expect((state as dynamic).pullWindows, _windowsOnTheBells);
    expect(find.byType(CriticalForceResultScreen), findsOneWidget);
    expect(find.text('10.00 kg'), findsOneWidget);
    expect(find.text('Mean of pulls 1-4'), findsOneWidget);
  });

  testWidgets('after the lead-in the test waits, armed, for the first pull', (
    tester,
  ) async {
    final watch = ManualCrimpyWatch();
    final samples = _HandFedSamples();
    final state = await _pumpRun(tester, watch, samples);

    await _runUntil(tester, watch, samples, 1000);
    // The athlete is a few seconds late on the edge, pulling under the
    // start force meanwhile.
    for (var i = 0; i < 30; i++) {
      samples.points.add(BleDataPoint(3, clock.now()));
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(_waiting(state), isTrue);
    expect(_clockRunning(state), isFalse);
    expect(find.text('Pull to start'), findsOneWidget);
    // ignore: avoid_dynamic_calls
    expect((state as dynamic).pullWindows, isEmpty);

    await _pullToStart(tester, samples);

    expect(_waiting(state), isFalse);
    expect(_clockRunning(state), isTrue);
    expect(find.text('Pull!'), findsOneWidget);
    await _runUntil(tester, watch, samples, 4000);
    // ignore: avoid_dynamic_calls
    expect((state as dynamic).pullWindows, [(start: 1000, end: 3000)]);
  });

  testWidgets('a dialog closed while the test waits does not start pull 1', (
    tester,
  ) async {
    final watch = ManualCrimpyWatch();
    final samples = _HandFedSamples();
    final state = await _pumpRun(tester, watch, samples);

    await _runUntil(tester, watch, samples, 1000);
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.tap(find.text('Keep going'));
    await tester.pump();

    expect(_waiting(state), isTrue);
    expect(_clockRunning(state), isFalse);
  });

  testWidgets('a pull under a dialog opened during the wait does not start '
      'the test', (tester) async {
    final watch = ManualCrimpyWatch();
    final samples = _HandFedSamples();
    final state = await _pumpRun(tester, watch, samples);

    await _runUntil(tester, watch, samples, 1000);
    await tester.binding.handlePopRoute();
    await tester.pump();
    samples.points.add(BleDataPoint(10, clock.now()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(_waiting(state), isTrue);
    expect(_clockRunning(state), isFalse);

    await tester.tap(find.text('Keep going'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // The reading taken under the dialog does not count either.
    expect(_waiting(state), isTrue);
    await _pullToStart(tester, samples);
    expect(_waiting(state), isFalse);
  });

  testWidgets('the leave dialog offers to finish once enough pulls have run', (
    tester,
  ) async {
    final watch = ManualCrimpyWatch();
    final samples = _HandFedSamples();
    await _pumpRun(tester, watch, samples);

    await _startTest(tester, watch, samples);
    await _runUntil(tester, watch, samples, 7500);
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.tap(find.text('Finish'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(CriticalForceResultScreen), findsOneWidget);
    expect(find.text('Mean of pulls 1-2'), findsOneWidget);
  });

  testWidgets('the test can be finished by hand once enough pulls have run', (
    tester,
  ) async {
    final watch = ManualCrimpyWatch();
    final samples = _HandFedSamples();
    final state = await _pumpRun(tester, watch, samples);
    expect(criticalForceMinPullsToFinish, 2);

    await _startTest(tester, watch, samples);
    // Pull 2 is under way: one pull run, not enough to finish on.
    await _runUntil(tester, watch, samples, 4500);
    expect(find.textContaining('Finish with'), findsNothing);

    // Pull 4 is under way, three have run.
    await _runUntil(tester, watch, samples, 10500);
    await tester.tap(find.text('Finish with 3 pulls'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // ignore: avoid_dynamic_calls
    expect((state as dynamic).pullWindows, _windowsOnTheBells.take(3));
    expect(find.byType(CriticalForceResultScreen), findsOneWidget);
    expect(find.text('10.00 kg'), findsOneWidget);
    expect(find.text('Mean of pulls 1-3'), findsOneWidget);

    // What is saved carries the grip pulled on and what the test measured
    // beyond its value, one entry per pull run.
    final saved = tester
        .widget<CriticalForceResultScreen>(
          find.byType(CriticalForceResultScreen),
        )
        .saveAssessment;
    expect(saved.gripPosition, GripPosition.halfCrimp);
    expect(saved.details!['w_prime_kg_s'], isA<num>());
    expect(saved.details!['pulls'], hasLength(3));
  });
}
