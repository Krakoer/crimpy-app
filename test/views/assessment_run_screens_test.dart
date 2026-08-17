import 'dart:async';

import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_run_screen.dart';
import 'package:crimpy/views/screens/assessments/endurance_60/endurance_60_run_screen.dart';
import 'package:crimpy/views/screens/assessments/mvc_run_screen.dart';
import 'package:crimpy/views/widgets/assessment_tutorial_dialog.dart';
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

/// Puts the run on a pushed route the way the assessment list does, so the
/// navigator holds something under it and a dialog can be stacked over it.
Future<void> _pumpPushedRun(
  WidgetTester tester,
  Widget screen,
  BleRepository bleRepository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [bleRepositoryProvider.overrideWithValue(bleRepository)],
      child: MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => screen)),
            child: const Text('start'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('start'));
  await _settleRoute(tester);
}

/// The run keeps a periodic timer alive for as long as it is on screen, so
/// `pumpAndSettle` never returns here. Route transitions are pumped by hand.
Future<void> _settleRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Stacks a dialog over the run, which is what the tutorial button and the
/// leave confirmation both do, on the same navigator as the run itself.
Future<void> _openDialogOverRun(WidgetTester tester, Finder runScreen) async {
  unawaited(
    showDialog<void>(
      context: tester.element(runScreen),
      builder: (_) => const AlertDialog(title: Text('over the run')),
    ),
  );
  await _settleRoute(tester);
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

/// Opens the real tutorial over the run, which is what the help button does.
/// Its own handler resumes the clock when it closes, so it is the dialog that
/// can restart a run that an interruption is still holding.
Future<void> _openTutorialOverRun(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Show tutorial'));
  await _settleRoute(tester);
}

/// The run's clock. Asserting on it is what makes these tests bite: a run that
/// restarts behind a dialog looks the same from the outside as one that stayed
/// stopped, and the sensor is handed back either way.
bool _clockIsRunning(WidgetTester tester) {
  final state = tester.state(find.byType(MvcRunScreen));
  // ignore: avoid_dynamic_calls
  return (state as dynamic).timer.isRunning as bool;
}

/// Answers the interruption dialog, then lets the run route go.
Future<void> _dismissInterruptionDialog(WidgetTester tester) async {
  await tester.tap(find.text('Back'));
  await _settleRoute(tester);
  await _settleRoute(tester);
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

  // An interruption discards the assessment, so answering the interruption
  // dialog has to leave the run. Popping once only closed whatever the user
  // had open over it, which left them on a run that keeps counting down
  // against a sensor that stopped recording.
  group('an interrupted assessment is left even from under a dialog', () {
    testWidgets('critical force', (tester) async {
      final bleRepository = BleRepository();
      await _pumpPushedRun(
        tester,
        CriticalForceRunScreen(reps: _pullThenRest(), hand: HandSide.right),
        bleRepository,
      );
      await _openDialogOverRun(tester, find.byType(CriticalForceRunScreen));

      await _leaveAndReturnToForeground(tester);
      await _dismissInterruptionDialog(tester);

      expect(find.byType(CriticalForceRunScreen), findsNothing);
      expect(bleRepository.isStreaming, isTrue);
    });

    testWidgets('60% endurance', (tester) async {
      final bleRepository = BleRepository();
      await _pumpPushedRun(
        tester,
        const Endurance60RunScreen(
          hand: HandSide.right,
          mvcValue: 50,
          gripPosition: GripPosition.halfCrimp,
        ),
        bleRepository,
      );
      await _openDialogOverRun(tester, find.byType(Endurance60RunScreen));

      await _leaveAndReturnToForeground(tester);
      await _dismissInterruptionDialog(tester);

      expect(find.byType(Endurance60RunScreen), findsNothing);
      expect(bleRepository.isStreaming, isTrue);
    });
  });

  // Max Force measures each pull on its own, so an interruption only costs
  // extra rest and the run is kept. It still has to come back on screen before
  // it restarts: resuming under the tutorial or the leave confirmation counted
  // a pull down while the athlete was reading, and stored whatever the sensor
  // saw while nobody was pulling.
  group('an interrupted max force run resumes on the visible run', () {
    testWidgets('the paused dialog is the only thing left over the run', (
      tester,
    ) async {
      final bleRepository = BleRepository();
      await _pumpPushedRun(
        tester,
        MvcRunScreen(reps: _pullThenRest(), type: AssessmentType.mvc),
        bleRepository,
      );
      await _openDialogOverRun(tester, find.byType(MvcRunScreen));

      await _leaveAndReturnToForeground(tester);
      await _settleRoute(tester);

      expect(find.text('over the run'), findsNothing);
      expect(find.text('Workout paused'), findsOneWidget);
      expect(find.byType(MvcRunScreen), findsOneWidget);
      expect(_clockIsRunning(tester), isFalse);
      expect(bleRepository.isStreaming, isFalse);
    });

    testWidgets('answering it keeps the run and hands the sensor back', (
      tester,
    ) async {
      final bleRepository = BleRepository();
      await _pumpPushedRun(
        tester,
        MvcRunScreen(reps: _pullThenRest(), type: AssessmentType.mvc),
        bleRepository,
      );
      await _openDialogOverRun(tester, find.byType(MvcRunScreen));

      await _leaveAndReturnToForeground(tester);
      await _settleRoute(tester);
      await tester.tap(find.text('Resume'));
      await _settleRoute(tester);

      expect(find.byType(MvcRunScreen), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(_clockIsRunning(tester), isTrue);
      expect(bleRepository.isStreaming, isTrue);
    });

    // The tutorial resumes the clock itself when it is closed, so uncovering
    // the run for the paused dialog used to restart the run behind it.
    testWidgets('closing the tutorial to uncover the run does not restart it', (
      tester,
    ) async {
      final bleRepository = BleRepository();
      await _pumpPushedRun(
        tester,
        MvcRunScreen(reps: _pullThenRest(), type: AssessmentType.mvc),
        bleRepository,
      );
      await _openTutorialOverRun(tester);

      await _leaveAndReturnToForeground(tester);
      await _settleRoute(tester);

      expect(find.byType(AssessmentTutorialDialog), findsNothing);
      expect(find.text('Workout paused'), findsOneWidget);
      expect(_clockIsRunning(tester), isFalse);
      expect(bleRepository.isStreaming, isFalse);

      await tester.tap(find.text('Resume'));
      await _settleRoute(tester);

      expect(find.byType(MvcRunScreen), findsOneWidget);
      expect(_clockIsRunning(tester), isTrue);
      expect(bleRepository.isStreaming, isTrue);
    });

    // Backgrounding again while the paused dialog is up is how the athlete
    // answers whatever pulled them out in the first place. Handling that second
    // return would pop the dialog they still have to answer, which reads as an
    // answer and restarts the run with nobody in position.
    testWidgets('a second interruption does not resume the run by itself', (
      tester,
    ) async {
      final bleRepository = BleRepository();
      await _pumpPushedRun(
        tester,
        MvcRunScreen(reps: _pullThenRest(), type: AssessmentType.mvc),
        bleRepository,
      );

      await _leaveAndReturnToForeground(tester);
      await _settleRoute(tester);
      await _leaveAndReturnToForeground(tester);
      await _settleRoute(tester);

      expect(find.text('Workout paused'), findsOneWidget);
      expect(_clockIsRunning(tester), isFalse);
      expect(bleRepository.isStreaming, isFalse);

      await tester.tap(find.text('Resume'));
      await _settleRoute(tester);

      expect(find.byType(MvcRunScreen), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(_clockIsRunning(tester), isTrue);
      expect(bleRepository.isStreaming, isTrue);
    });
  });
}
