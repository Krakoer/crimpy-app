import 'package:clock/clock.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/endurance_hold.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/assessments/assessment_cue_box.dart';
import 'package:crimpy/views/screens/assessments/assessment_run_phase.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_run_screen.dart';
import 'package:crimpy/views/screens/assessments/endurance_60/endurance_60_run_screen.dart';
import 'package:crimpy/views/screens/assessments/mvc_run_screen.dart';
import 'package:crimpy/views/screens/assessments/post_assessment_screen.dart';
import 'package:crimpy/views/widgets/workout_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeConnection extends BleConnection {
  _FakeConnection(this.connection);

  final BleConnectionState connection;

  @override
  BleConnectionState build() => connection;
}

/// A sensor that is connected until the test loses it.
class _LosableConnection extends BleConnection {
  @override
  BleConnectionState build() => BleConnectionState.connected;

  void lose() => state = BleConnectionState.disconnected;
}

/// The samples the run reads, added by hand with the fake clock's time.
class _HandFedSamples extends BleDataStream {
  final List<BleDataPoint> points = [];

  @override
  Stream<List<BleDataPoint>> build() => const Stream.empty();

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
  durationSeconds: 5,
  targetLoad: 0,
  handSide: HandSide.right,
  gripPosition: GripPosition.halfCrimp,
  collectSensorData: true,
);

const _rest = RestItem(durationSeconds: 5);

const _leadInPullRestPull = [_rest, _pull, _rest, _pull];

Future<void> _pumpRun(
  WidgetTester tester,
  Widget screen, {
  required BleConnectionState connection,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bleRepositoryProvider.overrideWithValue(BleRepository()),
        connectionStateProvider.overrideWith(() => _FakeConnection(connection)),
      ],
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pump();
}

Color? _cueFill(WidgetTester tester) {
  final box = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(AssessmentCueBox),
          matching: find.byType(Container),
        )
        .first,
  );
  return (box.decoration as BoxDecoration?)?.color;
}

Color _fillOf(RunPhase phase) =>
    CrimpyTheme.fillOn(CrimpyTheme.phaseColor(phase));

void main() {
  group('a timed assessment step', () {
    test('the rest before the first pull is the lead-in, armed', () {
      expect(
        assessmentStepPhase(
          steps: _leadInPullRestPull,
          stepIndex: 0,
          sensorLost: false,
        ),
        RunPhase.armed,
      );
    });

    test('a pull with no target is armed, not engaged', () {
      expect(
        assessmentStepPhase(
          steps: _leadInPullRestPull,
          stepIndex: 1,
          sensorLost: false,
        ),
        RunPhase.armed,
      );
    });

    test('a rest after a pull is calm', () {
      expect(
        assessmentStepPhase(
          steps: _leadInPullRestPull,
          stepIndex: 2,
          sensorLost: false,
        ),
        RunPhase.calm,
      );
    });

    test('a lost sensor is the alarm on any step', () {
      for (var index = 0; index < _leadInPullRestPull.length; index++) {
        expect(
          assessmentStepPhase(
            steps: _leadInPullRestPull,
            stepIndex: index,
            sensorLost: true,
          ),
          RunPhase.alarm,
        );
      }
    });
  });

  group('the 60% endurance hold', () {
    test('is engaged inside the band and armed outside it', () {
      expect(
        enduranceHoldPhase(inZone: true, sensorLost: false),
        RunPhase.engaged,
      );
      expect(
        enduranceHoldPhase(inZone: false, sensorLost: false),
        RunPhase.armed,
      );
    });

    test('is the alarm without a sensor, in the band or not', () {
      expect(
        enduranceHoldPhase(inZone: true, sensorLost: true),
        RunPhase.alarm,
      );
      expect(
        enduranceHoldPhase(inZone: false, sensorLost: true),
        RunPhase.alarm,
      );
    });
  });

  group('the run screens paint the phase', () {
    testWidgets('max force opens armed on its lead-in', (tester) async {
      await _pumpRun(
        tester,
        const MvcRunScreen(reps: _leadInPullRestPull, type: AssessmentType.mvc),
        connection: BleConnectionState.connected,
      );

      expect(_cueFill(tester), _fillOf(RunPhase.armed));
      expect(find.text('Pulling with right hand in'), findsOneWidget);
    });

    testWidgets('max force without a sensor raises the alarm', (tester) async {
      await _pumpRun(
        tester,
        const MvcRunScreen(reps: _leadInPullRestPull, type: AssessmentType.mvc),
        connection: BleConnectionState.disconnected,
      );

      expect(_cueFill(tester), _fillOf(RunPhase.alarm));
      expect(find.text('No sensor'), findsOneWidget);
    });

    // No sample arrives without a sensor, and the samples used to be the only
    // thing repainting Max Force, so the alarm showed a frozen countdown.
    testWidgets('max force keeps counting down under the alarm', (
      tester,
    ) async {
      final watch = ManualCrimpyWatch();
      await _pumpRun(
        tester,
        MvcRunScreen(
          reps: _leadInPullRestPull,
          type: AssessmentType.mvc,
          watch: watch,
        ),
        connection: BleConnectionState.disconnected,
      );
      expect(find.text('5'), findsOneWidget);

      watch.advance(2000);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No sensor'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('critical force rests calm between pulls', (tester) async {
      final watch = ManualCrimpyWatch();
      await _pumpRun(
        tester,
        CriticalForceRunScreen(
          reps: const [_pull, _rest, _pull],
          hand: HandSide.right,
          watch: watch,
        ),
        connection: BleConnectionState.connected,
      );
      expect(_cueFill(tester), _fillOf(RunPhase.armed));
      expect(find.text('Pull!'), findsOneWidget);

      watch.advance(_pull.durationSeconds * 1000);
      await tester.pump(const Duration(milliseconds: 100));

      expect(_cueFill(tester), _fillOf(RunPhase.calm));
      expect(find.text('Pulling in'), findsOneWidget);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        CrimpyTheme.phaseCalmGround,
      );
    });

    testWidgets('60% endurance without a sensor raises the alarm', (
      tester,
    ) async {
      await _pumpRun(
        tester,
        const Endurance60RunScreen(
          hand: HandSide.right,
          mvcValue: 50,
          gripPosition: GripPosition.halfCrimp,
        ),
        connection: BleConnectionState.disconnected,
      );

      expect(find.text('No sensor'), findsOneWidget);
    });
  });

  group('the time held up to the last sample', () {
    final now = DateTime(2026, 9, 28, 12);

    test('drops the time counted after the last sample', () {
      expect(
        heldUntilLastSample(
          elapsed: const Duration(seconds: 10),
          now: now,
          lastSampleAt: now.subtract(const Duration(seconds: 2)),
        ),
        const Duration(seconds: 8),
      );
    });

    test('is never negative for a sample older than the hold', () {
      expect(
        heldUntilLastSample(
          elapsed: const Duration(seconds: 1),
          now: now,
          lastSampleAt: now.subtract(const Duration(seconds: 5)),
        ),
        Duration.zero,
      );
    });

    test('keeps the whole hold without a sample to go by', () {
      expect(
        heldUntilLastSample(
          elapsed: const Duration(seconds: 4),
          now: now,
          lastSampleAt: null,
        ),
        const Duration(seconds: 4),
      );
    });
  });

  // Decided on Krakoer/crimpy#176: a hold that loses its sensor ends on the
  // last real sample, keeps the time held up to it, and says why.
  group('a 60% endurance hold that loses its sensor', () {
    const mvc = 50.0;
    const inBand = mvc * 0.6;

    Future<(_LosableConnection, _HandFedSamples)> pumpHold(
      WidgetTester tester,
    ) async {
      final connection = _LosableConnection();
      final samples = _HandFedSamples();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bleRepositoryProvider.overrideWithValue(BleRepository()),
            connectionStateProvider.overrideWith(() => connection),
            bleDataStreamProvider.overrideWith(() => samples),
            bleLastValueProvider.overrideWithValue(inBand),
            assessmentsProvider.overrideWith(_NoHistory.new),
          ],
          child: const MaterialApp(
            home: Endurance60RunScreen(
              hand: HandSide.right,
              mvcValue: mvc,
              gripPosition: GripPosition.halfCrimp,
            ),
          ),
        ),
      );
      return (connection, samples);
    }

    /// Sends an in-band sample every tick for [length].
    Future<void> holdFor(
      WidgetTester tester,
      _HandFedSamples samples,
      Duration length,
    ) async {
      const tick = Duration(milliseconds: 100);
      for (var held = Duration.zero; held < length; held += tick) {
        samples.points.add(BleDataPoint(inBand, clock.now()));
        await tester.pump(tick);
      }
    }

    testWidgets('stops the clock at the last sample, not at the loss', (
      tester,
    ) async {
      final (connection, samples) = await pumpHold(tester);
      // The hold starts once the load has sat in the band for a second.
      final holdStartsAt = clock.now().add(const Duration(seconds: 1));
      await holdFor(tester, samples, const Duration(seconds: 5));
      final lastSampleAt = samples.points.last.timestamp;

      // The run notices the loss two seconds after the last sample.
      await tester.pump(const Duration(seconds: 2));
      connection.lose();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final result = tester.widget<PostAssessmentScreen>(
        find.byType(PostAssessmentScreen),
      );
      final expected =
          lastSampleAt.difference(holdStartsAt).inMilliseconds / 1000;
      expect(result.saveAssessment.rightValue, closeTo(expected, 0.2));
      expect(find.textContaining('sensor was lost'), findsOneWidget);
    });

    testWidgets('does not start on a stale sample', (tester) async {
      final (connection, samples) = await pumpHold(tester);
      connection.lose();
      await holdFor(tester, samples, const Duration(seconds: 3));

      expect(find.byType(PostAssessmentScreen), findsNothing);
      expect(find.text('No sensor'), findsOneWidget);
    });
  });
}
