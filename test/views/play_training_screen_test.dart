import 'package:crimpy/models/run_screen_style.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/services/run_screen_style_service.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/run_screen_style_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The screen keeps the screen awake and preloads sounds; neither plugin exists
/// in a test binding, so both channels answer with a no-op.
void _stubPlugins() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final channel in const [
    MethodChannel('dev.fluttercommunity.plus/wakelock'),
    MethodChannel('xyz.luan/audioplayers'),
    MethodChannel('xyz.luan/audioplayers.global'),
  ]) {
    messenger.setMockMethodCallHandler(channel, (call) async => null);
  }
}

Training _stretchingCircuit() => const Training(
  id: 't1',
  title: 'Stretch routine',
  items: [
    TrainingItem(
      id: 'c',
      type: TrainingItemType.circuit,
      position: 0,
      cycles: 3,
      cycleRestSeconds: 10,
      items: [
        TrainingItem(
          id: 'e1',
          type: TrainingItemType.exercise,
          position: 0,
          duration: 35,
          restSeconds: 10,
          exerciseName: 'Pigeon',
          comment: 'Right leg',
        ),
        TrainingItem(
          id: 'e2',
          type: TrainingItemType.exercise,
          position: 1,
          duration: 35,
          restSeconds: 10,
          exerciseName: 'Pigeon',
          comment: 'Left leg',
        ),
      ],
    ),
  ],
);

/// An uncommented exercise ahead of a commented one, both at the top level.
Training _oneCommentedExercise() => const Training(
  id: 't2',
  title: 'Two exercises',
  items: [
    TrainingItem(
      id: 'e1',
      type: TrainingItemType.exercise,
      position: 0,
      duration: 20,
      restSeconds: 10,
      exerciseName: 'Frog',
    ),
    TrainingItem(
      id: 'e2',
      type: TrainingItemType.exercise,
      position: 1,
      duration: 20,
      exerciseName: 'Pigeon',
      comment: 'Right leg',
    ),
  ],
);

/// Serves one design without touching the device storage, so a test states
/// which layout it is about.
class _FixedStyleService extends RunScreenStyleService {
  _FixedStyleService(this.style);

  final RunScreenStyle style;

  @override
  Future<RunScreenStyle> load() async => style;

  @override
  Future<void> save(RunScreenStyle style) async {}
}

/// Runs a training in a given design, the ring by default, whose header, timer
/// and next-up line most of these tests are written against.
Future<void> _pumpRun(
  WidgetTester tester,
  Training training, {
  RunScreenStyle style = RunScreenStyle.ringAndTank,
  BleRepository? bleRepository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        runScreenStyleServiceProvider.overrideWithValue(
          _FixedStyleService(style),
        ),
        // The real provider reaches for the stored calibration on creation,
        // which no test binding can serve.
        if (bleRepository != null)
          bleRepositoryProvider.overrideWithValue(bleRepository),
      ],
      child: MaterialApp(home: PlayTrainingScreen(training, useSensor: false)),
    ),
  );
  await tester.pump();
}

/// Moves to the next step of the run, the way the skip button does.
Future<void> _skip(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.skip_next));
  await tester.pump();
}

void main() {
  setUp(_stubPlugins);

  testWidgets('the comment of a step is shown while a rest follows it', (
    tester,
  ) async {
    await _pumpRun(tester, _stretchingCircuit());

    // Preparation rest first: it leads into the first exercise, whose comment
    // is shown ahead of time under the name of that upcoming step.
    expect(find.text('Right leg'), findsOneWidget);
    expect(find.textContaining('Next:'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Right leg')).dy,
      greaterThan(tester.getTopLeft(find.textContaining('Next:')).dy),
    );

    await _skip(tester);

    // Now running the exercise itself: the comment follows its title, above
    // the timer.
    expect(find.text('Right leg'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Right leg')).dy,
      greaterThan(tester.getTopLeft(find.text('PIGEON')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Right leg')).dy,
      lessThan(tester.getTopLeft(find.text('00:35')).dy),
    );
  });

  testWidgets('a rest only carries the comment of the step it leads into', (
    tester,
  ) async {
    await _pumpRun(tester, _stretchingCircuit());

    // Prep rest -> first exercise -> its rest, which leads into the second one.
    await _skip(tester);
    await _skip(tester);
    expect(find.text('Left leg'), findsOneWidget);
    expect(find.text('Right leg'), findsNothing);

    // Second exercise, then the single rest closing the cycle: the rest the
    // circuit sets stands in for the one the last exercise carries rather than
    // running after it. It leads into the first exercise of cycle two.
    await _skip(tester);
    await _skip(tester);
    expect(find.text('Right leg'), findsOneWidget);
    expect(find.text('Left leg'), findsNothing);

    await _skip(tester);
    expect(find.text('Right leg'), findsOneWidget);
  });

  testWidgets('an uncommented step shows no comment of its own', (
    tester,
  ) async {
    await _pumpRun(tester, _oneCommentedExercise());

    // Preparation rest leads into the uncommented exercise.
    expect(find.text('Right leg'), findsNothing);

    // Running that exercise: the comment of the later one must not appear.
    await _skip(tester);
    expect(find.text('FROG'), findsOneWidget);
    expect(find.text('Right leg'), findsNothing);

    // Its rest leads into the commented exercise, so the comment appears.
    await _skip(tester);
    expect(find.text('Right leg'), findsOneWidget);
  });

  // The design every user gets unless they pick the other one, wired to the
  // same timer, look-ahead and skip button as the ring.
  testWidgets('the full tank runs a training from its own layout', (
    tester,
  ) async {
    await _pumpRun(
      tester,
      _stretchingCircuit(),
      style: RunScreenStyle.fullTank,
    );

    // Preparation comes first and looks ahead to name what it leads into. The
    // tank owns the whole screen, so the training title has no app bar to sit
    // in.
    expect(find.text('PREPARATION'), findsOneWidget);
    expect(find.text('READY'), findsOneWidget);
    expect(find.text('Get ready. First up: pigeon.'), findsOneWidget);
    expect(find.text('Stretch routine'), findsNothing);

    await _skip(tester);

    // Running the first exercise, which carries its own comment.
    expect(find.text('PIGEON'), findsOneWidget);
    expect(find.text('Right leg'), findsOneWidget);
    expect(find.text('SEC LEFT'), findsOneWidget);
    expect(find.text('WORK'), findsOneWidget);

    await _skip(tester);

    // Its rest, which previews the step after it.
    expect(find.text('REST'), findsOneWidget);
    expect(find.text('Left leg'), findsOneWidget);
  });

  // Samples taken while the run is suspended belong to no rep. Recording them
  // dragged the average force of the rep the pause interrupted down towards
  // zero, since the athlete is off the board for the whole pause.
  testWidgets('pausing the run stops recording sensor samples', (tester) async {
    final bleRepository = BleRepository();
    await _pumpRun(tester, _stretchingCircuit(), bleRepository: bleRepository);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    expect(bleRepository.isStreaming, isTrue);

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(bleRepository.isStreaming, isFalse);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    expect(bleRepository.isStreaming, isTrue);
  });

  // Leaving a paused run must not leave the sensor mute for the rest of the
  // app: the live gauge outside the run reads the same stream.
  testWidgets('leaving a paused run hands the sensor stream back', (
    tester,
  ) async {
    final bleRepository = BleRepository();
    await _pumpRun(tester, _stretchingCircuit(), bleRepository: bleRepository);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(bleRepository.isStreaming, isFalse);

    await tester.pumpWidget(const SizedBox());
    expect(bleRepository.isStreaming, isTrue);
  });
}
