import 'dart:typed_data';

import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/run_screen_style.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/services/run_screen_style_service.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/run_screen_style_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:crimpy/views/screens/trainings/post_workout_screen.dart';
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

/// A single hangboard hang with a load the coach prescribed, so a run of it
/// records a rep that carries a target when the sensor measured it.
Training _oneHang() => const Training(
  id: 't3',
  title: 'One hang',
  items: [
    TrainingItem(
      id: 'h1',
      type: TrainingItemType.hangboardRep,
      position: 0,
      hand: 'right',
      worktimeSeconds: 7,
      restSeconds: 0,
      loads: [Load(value: 30, unit: 'kg')],
    ),
  ],
);

/// Two prescribed hangs back to back, so a run can lose the sensor between them
/// and the reps on either side of the drop are read apart.
Training _twoHangs() => const Training(
  id: 't4',
  title: 'Two hangs',
  items: [
    TrainingItem(
      id: 'h1',
      type: TrainingItemType.hangboardRep,
      position: 0,
      hand: 'right',
      worktimeSeconds: 7,
      restSeconds: 0,
      loads: [Load(value: 30, unit: 'kg')],
    ),
    TrainingItem(
      id: 'h2',
      type: TrainingItemType.hangboardRep,
      position: 1,
      hand: 'right',
      worktimeSeconds: 7,
      restSeconds: 0,
      loads: [Load(value: 30, unit: 'kg')],
    ),
  ],
);

/// One block of two prescribed hangs, so both reps of a run are graded together
/// and the block states one ratio over them.
Training _repeatedHangs() => const Training(
  id: 't5',
  title: 'Repeated hangs',
  items: [
    TrainingItem(
      id: 'r1',
      type: TrainingItemType.repeater,
      position: 0,
      hand: 'right',
      cycles: 1,
      reps: 2,
      worktimeSeconds: 7,
      restSeconds: 3,
      loads: [Load(value: 30, unit: 'kg')],
    ),
  ],
);

/// One exercise loaded as a percentage of a coach assessment, with the
/// definition the training detail carries. The athlete cannot fetch that
/// definition, so this is the only thing that names it during the run.
Training _percentAssessmentExercise() => const Training(
  id: 't6',
  title: 'Weighted pull ups',
  referencedAssessments: [
    AssessmentDefinition(
      id: 'a9b8c7d6-0000-0000-0000-000000000003',
      label: 'Weighted hang',
      unit: AssessmentUnit.kilograms,
      trainingId: 't-weighted-hang',
    ),
  ],
  items: [
    TrainingItem(
      id: 'e1',
      type: TrainingItemType.exercise,
      position: 0,
      reps: 5,
      exerciseName: 'Pull up',
      loads: [
        Load(
          value: 80,
          unit: percentAssessmentUnit,
          assessmentId: 'a9b8c7d6-0000-0000-0000-000000000003',
          fallback: 25,
        ),
      ],
    ),
  ],
);

/// One sensor notification carrying [kilograms], in the frame layout the
/// firmware sends: two header bytes then the reading as a little endian float.
/// The repository is left at its default tare and coefficient, so the value
/// arrives calibrated as it was written.
List<int> _sample(double kilograms) {
  final frame = ByteData(6)..setFloat32(2, kilograms, Endian.little);
  return frame.buffer.asUint8List();
}

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

/// Reports the sensor stats a test sets rather than the ones a live sensor
/// would build up, so a run can state what the sensor delivered while its steps
/// ran. The run resets the session at every step boundary; the stats stand for
/// the whole run, so the reset is a no-op here.
class _FixedBleSession extends BleSession {
  _FixedBleSession(this.stats);

  final BleSessionStats stats;

  @override
  BleSessionStats build() => stats;

  @override
  void reset() {}
}

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
  bool useSensor = false,
  BleSessionStats? sensorStats,
  bool liveSensorStats = false,
}) async {
  final screen = MaterialApp(
    home: PlayTrainingScreen(training, useSensor: useSensor),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        runScreenStyleServiceProvider.overrideWithValue(
          _FixedStyleService(style),
        ),
        // Always served, never built: the real provider reaches for the stored
        // calibration on creation, which no test binding can answer, and the
        // screen reads the repository whether or not it runs with the sensor.
        bleRepositoryProvider.overrideWithValue(
          bleRepository ?? BleRepository(),
        ),
        if (sensorStats != null)
          bleSessionProvider.overrideWith(() => _FixedBleSession(sensorStats)),
      ],
      // The run only reads the stats once a step ends, so a test pushing real
      // samples has to hold the session open from the first frame: built on
      // that first read instead, it would have missed everything before it.
      child: liveSensorStats
          ? Consumer(
              builder: (context, ref, child) {
                ref.watch(bleSessionProvider);
                return child!;
              },
              child: screen,
            )
          : screen,
    ),
  );
  await tester.pump();
}

/// The reps a finished run handed to the screen that shows them, which is what
/// gets saved as the session.
List<RepDataModel> _recordedReps(WidgetTester tester) =>
    tester.widget<PostWorkoutScreen>(find.byType(PostWorkoutScreen)).results;

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

  // A run started with "Run without" measures nothing, so the reps it records
  // carry no target: graded against the load they were prescribed, every one of
  // them would read as a miss.
  testWidgets('a run without the sensor records reps with no target', (
    tester,
  ) async {
    await _pumpRun(tester, _oneHang(), useSensor: false);

    // Preparation rest, then the hang itself.
    await _skip(tester);
    await _skip(tester);
    await tester.pumpAndSettle();

    expect(find.byType(PostWorkoutScreen), findsOneWidget);
    expect(find.textContaining('you hit your target on'), findsNothing);
    expect(find.textContaining('on target'), findsNothing);
    // Nothing was ever going to measure this run, so its reps lost no target:
    // the flag is what a dropped sensor leaves behind, not a missing target.
    expect(_recordedReps(tester).every((rep) => !rep.targetUnmeasured), isTrue);
  });

  // Whether a run collects sensor data is decided when the training is
  // expanded, from the sensor it started with. A run that loses the sensor
  // partway measures nothing from there on, so the reps it goes on recording
  // carry no target either: kept, they would grade as misses.
  testWidgets('a run the sensor never answered records reps with no target', (
    tester,
  ) async {
    await _pumpRun(
      tester,
      _oneHang(),
      useSensor: true,
      sensorStats: BleSessionStats(),
    );

    await _skip(tester);
    await _skip(tester);
    await tester.pumpAndSettle();

    expect(find.byType(PostWorkoutScreen), findsOneWidget);
    expect(find.textContaining('you hit your target on'), findsNothing);
    expect(find.textContaining('on target'), findsNothing);
  });

  testWidgets('a step the sensor measured records the load it was given', (
    tester,
  ) async {
    await _pumpRun(
      tester,
      _oneHang(),
      useSensor: true,
      sensorStats: BleSessionStats(avg: 31, max: 34, nbPoints: 120),
    );

    await _skip(tester);
    await _skip(tester);
    await tester.pumpAndSettle();

    expect(find.byType(PostWorkoutScreen), findsOneWidget);
    expect(find.textContaining('you hit your target on'), findsOneWidget);
  });

  // The run the ticket is about: the sensor answers for the first hang and goes
  // quiet before the second, the way a disconnect mid-session leaves it. The
  // expansion cannot tell the two hangs apart, since both were prescribed with
  // the sensor connected, so only the samples that actually arrived can.
  testWidgets('a sensor that drops mid-run only targets the reps it measured', (
    tester,
  ) async {
    final bleRepository = BleRepository();
    await _pumpRun(
      tester,
      _twoHangs(),
      useSensor: true,
      bleRepository: bleRepository,
      liveSensorStats: true,
    );

    // Preparation rest, then the first hang, which the sensor measures.
    await _skip(tester);
    for (final kilograms in const [28.0, 31.0, 32.0]) {
      bleRepository.handleRawSample(_sample(kilograms));
    }
    await tester.pump();

    // Second hang: the sensor is gone, so nothing reaches the stream while it
    // runs, even though the run still believes it collects sensor data.
    await _skip(tester);
    await tester.pump();

    await _skip(tester);
    await tester.pumpAndSettle();

    final hangs = _recordedReps(tester).where((rep) => !rep.isRest).toList();
    expect(hangs, hasLength(2));

    expect(hangs.first.targetWeight, 30);
    expect(hangs.first.averageWeight, closeTo(30.33, 0.01));
    expect(hangs.first.targetUnmeasured, false);

    // The hang was prescribed a load and performed, so it says the target was
    // lost rather than never given: graded against the zero above it would read
    // as a miss, counted as a plain untargeted rep it would still weigh down
    // the run's ratio.
    expect(hangs.last.targetWeight, 0);
    expect(hangs.last.averageWeight, 0);
    expect(hangs.last.targetUnmeasured, true);
  });

  // What the athlete reads after that run: the block played two hangs and the
  // sensor measured one, so the ratio is over the one hang the run could grade
  // and the other is named rather than counted as a miss.
  testWidgets('the run states its ratio over the reps it measured', (
    tester,
  ) async {
    final bleRepository = BleRepository();
    await _pumpRun(
      tester,
      _repeatedHangs(),
      useSensor: true,
      bleRepository: bleRepository,
      liveSensorStats: true,
    );

    await _skip(tester);
    for (final kilograms in const [28.0, 31.0, 32.0]) {
      bleRepository.handleRawSample(_sample(kilograms));
    }
    await tester.pump();

    // The rest between the two hangs, then the second hang with the sensor gone.
    await _skip(tester);
    await _skip(tester);
    await tester.pump();

    await _skip(tester);
    await tester.pumpAndSettle();

    expect(find.byType(PostWorkoutScreen), findsOneWidget);
    expect(find.textContaining('1 of 1'), findsOneWidget);
    expect(find.textContaining('1 unmeasured'), findsOneWidget);
  });

  // No results are handed in, so the training's own definitions are all the run
  // has: they name the coach assessment, which used to read "80% assessment".
  testWidgets('a step names the coach assessment its load is read against', (
    tester,
  ) async {
    await _pumpRun(tester, _percentAssessmentExercise());
    await _skip(tester);

    expect(find.textContaining('80% Weighted hang'), findsOneWidget);
    expect(find.textContaining('80% assessment'), findsNothing);
  });
}
