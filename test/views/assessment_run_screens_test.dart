import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_run_screen.dart';
import 'package:crimpy/views/screens/assessments/endurance_60/endurance_60_run_screen.dart';
import 'package:crimpy/views/screens/assessments/mvc_run_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

List<TrainingExecutionItem> _pullThenRest() => const [
  TimedItem(
    label: 'Pull',
    durationSeconds: 5,
    targetLoad: 0,
    handSide: HandSide.right,
    gripPosition: GripPosition.halfCrimp,
    collectSensorData: true,
  ),
  RestItem(durationSeconds: 5),
];

/// Puts a run screen on screen with a repository the test can inspect. The
/// real provider reaches for the stored calibration on creation, which no test
/// binding can answer.
Future<void> _pumpRun(
  WidgetTester tester,
  Widget screen,
  BleRepository bleRepository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [bleRepositoryProvider.overrideWithValue(bleRepository)],
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pump();
}

/// Backgrounds the app, which is what makes a run screen pause the stream,
/// then brings it back so the screen sits on its interruption dialog. The
/// stream stays paused until that dialog is answered, which is the window the
/// screen can be left in. Coming back also restores the frames the test
/// binding stops producing while the app is paused.
Future<void> _leaveAndReturnToForeground(WidgetTester tester) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  await tester.pump();
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pump();
  await tester.pump();
}

void main() {
  // Leaving a backgrounded assessment must not leave the sensor mute for the
  // rest of the app: the live gauge, the bodyweight measure and the next run
  // all read the same stream.
  group('leaving an interrupted assessment hands the sensor stream back', () {
    testWidgets('max force', (tester) async {
      final bleRepository = BleRepository();
      await _pumpRun(
        tester,
        MvcRunScreen(reps: _pullThenRest(), type: AssessmentType.mvc),
        bleRepository,
      );

      await _leaveAndReturnToForeground(tester);
      expect(bleRepository.isStreaming, isFalse);

      await tester.pumpWidget(const SizedBox());
      expect(bleRepository.isStreaming, isTrue);
    });

    testWidgets('critical force', (tester) async {
      final bleRepository = BleRepository();
      await _pumpRun(
        tester,
        CriticalForceRunScreen(reps: _pullThenRest(), hand: HandSide.right),
        bleRepository,
      );

      await _leaveAndReturnToForeground(tester);
      expect(bleRepository.isStreaming, isFalse);

      await tester.pumpWidget(const SizedBox());
      expect(bleRepository.isStreaming, isTrue);
    });

    testWidgets('60% endurance', (tester) async {
      final bleRepository = BleRepository();
      await _pumpRun(
        tester,
        const Endurance60RunScreen(
          hand: HandSide.right,
          mvcValue: 50,
          gripPosition: GripPosition.halfCrimp,
        ),
        bleRepository,
      );

      await _leaveAndReturnToForeground(tester);
      expect(bleRepository.isStreaming, isFalse);

      await tester.pumpWidget(const SizedBox());
      expect(bleRepository.isStreaming, isTrue);
    });
  });
}
