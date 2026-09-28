import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/assessments/assessment_cue_box.dart';
import 'package:crimpy/views/screens/assessments/assessment_run_phase.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_run_screen.dart';
import 'package:crimpy/views/screens/assessments/endurance_60/endurance_60_run_screen.dart';
import 'package:crimpy/views/screens/assessments/mvc_run_screen.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeConnection extends BleConnection {
  _FakeConnection(this.connection);

  final BleConnectionState connection;

  @override
  BleConnectionState build() => connection;
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

    testWidgets('critical force rests calm between pulls', (tester) async {
      await _pumpRun(
        tester,
        const CriticalForceRunScreen(
          reps: [_pull, _rest, _pull],
          hand: HandSide.right,
        ),
        connection: BleConnectionState.connected,
      );
      expect(_cueFill(tester), _fillOf(RunPhase.armed));
      expect(find.text('Pull!'), findsOneWidget);

      final state = tester.state(find.byType(CriticalForceRunScreen));
      // ignore: avoid_dynamic_calls
      (state as dynamic).timer.skipRep();
      await tester.pump();

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
}
