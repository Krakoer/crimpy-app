import 'dart:typed_data';

import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/run_screen_style.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/services/run_screen_style_service.dart';
import 'package:crimpy/services/video_launcher.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/run_screen_style_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:crimpy/views/screens/trainings/post_workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/run_screen_plugins.dart';

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

/// An EMOM of a single AMRAP exercise, which is the shape the ticket names: a
/// coach asks for as many pull ups as possible every minute for three minutes.
Training _amrapEmom() => const Training(
  id: 't7',
  title: 'Pull up EMOM',
  items: [
    TrainingItem(
      id: 'emom-1',
      type: TrainingItemType.emom,
      position: 0,
      cycles: 3,
      intervalSeconds: 60,
      items: [
        TrainingItem(
          id: 'pullup-1',
          type: TrainingItemType.exercise,
          position: 0,
          exerciseName: 'Pull up',
          repsIsMax: true,
        ),
      ],
    ),
  ],
);

/// The backend's per-item comment cap, past which a coach's note used to be
/// silently truncated. A run has to lay out a note of exactly this length
/// without overflowing, on either run screen design. Word-based rather than
/// one unbroken run of characters, since that is the shape a coach actually
/// pastes in, and each item gets its own word so a test can tell which one it
/// is reading off screen.
String _commentOfLength(String word, int length) => List.filled(
  (length / (word.length + 1)).ceil() + 1,
  word,
).join(' ').substring(0, length);

final String _repeaterComment = _commentOfLength('pause', 2000);
final String _hangRepComment = _commentOfLength('speed', 2000);
final String _emomComment = _commentOfLength('apnea', 2000);

/// A repeater and a hang rep, each carrying a comment at the new length limit,
/// so a run of either can be checked for a layout that survives it. No rest
/// between them, so a skip lands straight on the second one.
Training _hangsWithLongComments() => Training(
  id: 't8',
  title: 'Long comments',
  items: [
    TrainingItem(
      id: 'r1',
      type: TrainingItemType.repeater,
      position: 0,
      hand: 'right',
      cycles: 1,
      reps: 1,
      worktimeSeconds: 7,
      restSeconds: 0,
      comment: _repeaterComment,
    ),
    TrainingItem(
      id: 'h1',
      type: TrainingItemType.hangboardRep,
      position: 1,
      hand: 'right',
      worktimeSeconds: 7,
      restSeconds: 0,
      comment: _hangRepComment,
    ),
  ],
);

/// An EMOM whose own comment sits at the new length limit, run for a single
/// self paced round: the round itself is what has no FittedBox and no scroll
/// around its comment, so it is the step that must be reached to prove the
/// layout survives.
Training _emomWithLongComment() => Training(
  id: 't9',
  title: 'Long EMOM comment',
  items: [
    TrainingItem(
      id: 'emom-1',
      type: TrainingItemType.emom,
      position: 0,
      cycles: 1,
      intervalSeconds: 60,
      comment: _emomComment,
      items: [
        TrainingItem(
          id: 'pullup-1',
          type: TrainingItemType.exercise,
          position: 0,
          exerciseName: 'Pull up',
          repsIsMax: true,
        ),
      ],
    ),
  ],
);

/// A repeater with a real rest before its hang rep, both carrying a comment
/// at the new length limit. The full tank's rest preview reads the ahead
/// comment through a plain, unscrolled Column the same as its timed and
/// confirm blocks, so it needs a real rest between two long-commented steps
/// to be reached at all: the other fixtures above use no rest between items.
Training _hangsWithLongCommentsAndRest() => Training(
  id: 't10',
  title: 'Long comments with rest',
  items: [
    // A single-rep repeater rests only between reps, never after its last
    // one, so it would never lead into a real rest step here. A hang rep's
    // own rest is unconditional, which is what actually gets a rest between
    // this item and the next.
    TrainingItem(
      id: 'h0',
      type: TrainingItemType.hangboardRep,
      position: 0,
      hand: 'right',
      worktimeSeconds: 7,
      restSeconds: 30,
      comment: _repeaterComment,
    ),
    TrainingItem(
      id: 'h1',
      type: TrainingItemType.hangboardRep,
      position: 1,
      hand: 'right',
      worktimeSeconds: 7,
      restSeconds: 0,
      comment: _hangRepComment,
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
  AssessmentResults results = AssessmentResults.none,
  double? bodyweightKg,
}) async {
  final screen = MaterialApp(
    home: PlayTrainingScreen(
      training,
      useSensor: useSensor,
      results: results,
      bodyweightKg: bodyweightKg,
    ),
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
/// A hang whose exercise carries a demo video, so a run of it can be asked
/// where that video is reachable from.
Training _hangWithVideo() => const Training(
  id: 't6',
  title: 'Hang with video',
  items: [
    // Two reps with a rest between them, so the running hang really does have
    // an upcoming step to preview: the guard under test is the one that keeps
    // the preview's video off the screen while the hang itself is running, and
    // a hang with nothing after it would pass without exercising it.
    TrainingItem(
      id: 'h1',
      type: TrainingItemType.hangboardRep,
      position: 0,
      hand: 'right',
      reps: 2,
      worktimeSeconds: 7,
      restSeconds: 30,
      loads: [Load(value: 30, unit: 'kg')],
      exerciseName: 'Half crimp hang',
      exerciseVideoLink: 'https://example.com/hang',
    ),
  ],
);

/// A self paced exercise with a demo video: the athlete ends it themselves, so
/// they are stood in front of the phone rather than hanging off it.
Training _repsWithVideo() => const Training(
  id: 't7',
  title: 'Pull ups',
  items: [
    TrainingItem(
      id: 'e1',
      type: TrainingItemType.exercise,
      position: 0,
      reps: 8,
      exerciseName: 'Pull up',
      exerciseVideoLink: 'https://example.com/pull-up',
    ),
  ],
);

/// A single timed set with a demo video and nothing after it, which is the run
/// whose only chance to show the video is the preparation.
Training _singleTimedSetWithVideo() => const Training(
  id: 't8',
  title: 'Plank',
  items: [
    TrainingItem(
      id: 'e1',
      type: TrainingItemType.exercise,
      position: 0,
      duration: 30,
      exerciseName: 'Plank',
      exerciseVideoLink: 'https://example.com/plank',
    ),
  ],
);

/// Answers for the platform, which no test binding can: a launcher that refuses
/// is what the failure message is written against.
class _RefusingLauncher extends VideoLauncher {
  const _RefusingLauncher();

  @override
  Future<bool> open(String? link) async => false;
}

/// A note long enough that the running screen has to cut it short, which is
/// what the paused reading mode exists for.
final String _longNoteText = List.filled(
  10,
  'kilter volume, 40 degrees, ramp up from 6a, 2 to 3 min between blocks',
).join(' ');

Training _trainingWithLongNote() => Training(
  id: 't11',
  title: 'Board session',
  items: [
    TrainingItem(
      id: 'n1',
      type: TrainingItemType.free,
      position: 0,
      freeText: _longNoteText,
    ),
  ],
);

Future<void> _skip(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.skip_next));
  await tester.pump();
}

void main() {
  setUp(stubRunScreenPlugins);

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

  testWidgets(
    'a repeater and a hang rep each lay out a comment at the length limit',
    (tester) async {
      await _pumpRun(tester, _hangsWithLongComments());

      // Preparation rest previews the repeater's comment ahead of time.
      expect(find.text(_repeaterComment), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _skip(tester);
      // Running the repeater hang itself: the step whose header is wrapped in
      // a FittedBox, which scales rather than overflows, so a widget that
      // finds the comment text and finds no exception cannot tell a merely
      // wrapped comment from one that has shrunk the title to nothing. The
      // 4-line cap is what keeps the shrink from being severe; check the
      // title actually rendered at a legible size rather than a sliver.
      expect(find.text(_repeaterComment), findsOneWidget);
      expect(find.text(_hangRepComment), findsNothing);
      // Reverting the 4-line cap shrinks this to well under 1px on the test
      // surface (measured ~0.7px); capped, it holds well above that.
      expect(tester.getRect(find.text('RIGHT HANG')).height, greaterThan(3));
      expect(tester.takeException(), isNull);

      await _skip(tester);
      // Running the hang rep.
      expect(find.text(_hangRepComment), findsOneWidget);
      expect(find.text(_repeaterComment), findsNothing);
      expect(tester.getRect(find.text('HANG')).height, greaterThan(3));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('an emom round lays out a comment at the length limit', (
    tester,
  ) async {
    await _pumpRun(tester, _emomWithLongComment());

    // Preparation rest previews the round's comment ahead of time.
    expect(find.text(_emomComment), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _skip(tester);
    // Running the round itself: a self paced step, whose comment sits in a
    // plain Column with no FittedBox and no scroll around it, which is where
    // an unbounded comment used to overflow.
    expect(find.text(_emomComment), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // The full tank lays every comment straight into a plain Column with no
  // FittedBox and no scroll, so it is the design most exposed to an overflow
  // from a long note.
  testWidgets(
    'the full tank lays out a comment at the length limit on a timed step',
    (tester) async {
      await _pumpRun(
        tester,
        _hangsWithLongComments(),
        style: RunScreenStyle.fullTank,
      );
      await _skip(tester);
      expect(find.text(_repeaterComment), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the full tank lays out a comment at the length limit on a confirm step',
    (tester) async {
      await _pumpRun(
        tester,
        _emomWithLongComment(),
        style: RunScreenStyle.fullTank,
      );
      await _skip(tester);
      expect(find.text(_emomComment), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the full tank lays out a comment at the length limit on the rest preview',
    (tester) async {
      // The overflow this guards only shows on a small phone: the default
      // test surface has enough room to fit it regardless of the cap.
      tester.view.physicalSize = const Size(320, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _pumpRun(
        tester,
        _hangsWithLongCommentsAndRest(),
        style: RunScreenStyle.fullTank,
      );
      // Running the repeater hang, then its rest, which previews the hang
      // rep's comment ahead of time: the site the ring/tank design skips
      // over via a FittedBox that this design has no equivalent of.
      await _skip(tester);
      await _skip(tester);
      expect(find.text(_hangRepComment), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

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

  group('AMRAP and EMOM', () {
    testWidgets('an open rep count asks how many rather than naming one', (
      tester,
    ) async {
      await _pumpRun(tester, _amrapEmom());
      await _skip(tester);

      expect(find.text('AMRAP'), findsOneWidget);
      expect(find.textContaining('Tap DONE and say how many'), findsOneWidget);
      expect(find.text('ROUND 1/3'), findsOneWidget);
    });

    testWidgets('finishing an AMRAP records the count the athlete gives', (
      tester,
    ) async {
      await _pumpRun(
        tester,
        _amrapEmom(),
        results: AssessmentResults(const {
          'max-pullups': AssessmentHandValues(right: 20),
        }),
        bodyweightKg: 70,
      );
      await _skip(tester);

      await tester.tap(find.text('DONE'));
      await tester.pumpAndSettle();

      expect(find.text('How many did you manage?'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '23');
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      // The run moves on to the rest that closes the round, so the question
      // was answered rather than dismissed.
      expect(find.text('How many did you manage?'), findsNothing);
      expect(find.text('AMRAP'), findsNothing);
    });

    testWidgets('backing out of the question leaves the step where it was', (
      tester,
    ) async {
      await _pumpRun(
        tester,
        _amrapEmom(),
        results: AssessmentResults(const {
          'max-pullups': AssessmentHandValues(right: 20),
        }),
        bodyweightKg: 70,
      );
      await _skip(tester);

      await tester.tap(find.text('DONE'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('AMRAP'), findsOneWidget);
    });

    testWidgets('dropping out of the block ends it at the round reached', (
      tester,
    ) async {
      await _pumpRun(tester, _amrapEmom());
      await _skip(tester);

      await tester.tap(find.textContaining('I CANNOT MAKE THE NEXT ROUND'));
      await tester.pumpAndSettle();

      expect(find.text('Stop this block?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Stop'));
      await tester.pumpAndSettle();

      // The block held three rounds and the athlete dropped out of the first,
      // so the run has nothing left to play.
      expect(find.byType(PostWorkoutScreen), findsOneWidget);
    });

    testWidgets('the counts a run resolved reach the screen that saves them', (
      tester,
    ) async {
      await _pumpRun(
        tester,
        _amrapEmom(),
        results: AssessmentResults(const {
          'max-pullups': AssessmentHandValues(right: 20),
        }),
        bodyweightKg: 70,
      );
      await _skip(tester);

      await tester.tap(find.text('DONE'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '23');
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      // Out of the rest that closed round one, then out of the block.
      await _skip(tester);
      await tester.tap(find.textContaining('I CANNOT MAKE THE NEXT ROUND'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Stop'));
      await tester.pumpAndSettle();

      final post = tester.widget<PostWorkoutScreen>(
        find.byType(PostWorkoutScreen),
      );
      expect(
        post.itemResults.map(
          (r) => '${r.trainingItemId}/${r.occurrence}/${r.reps}/${r.cycles}',
        ),
        ['pullup-1/0/23/null', 'emom-1/0/null/1'],
      );
      // The review pass resolves the prescription against the same numbers the
      // run was played against, so the screen has to be handed them. Without
      // this the plumbing can be deleted and every other test stays green while
      // the athlete is reviewed against the coach's fallbacks.
      expect(post.assessmentResults.value('max-pullups'), 20);
      // Carried for the same reason and just as silently droppable: without
      // this, deleting the argument leaves a card stating "80 %BW" where it
      // should state the kilograms behind it, and every test stays green.
      expect(post.bodyweightKg, 70);
    });

    testWidgets('there is nothing to drop out of outside an emom', (
      tester,
    ) async {
      await _pumpRun(tester, _stretchingCircuit());
      await _skip(tester);

      expect(find.textContaining('I CANNOT MAKE THE NEXT ROUND'), findsNothing);
    });
  });

  // The video has to reach the run, and it has to reach it where a tap is safe.
  // The preparation rest previews the first step, which is where an athlete
  // about to hang can still look the movement up with both hands free.
  testWidgets('the demo video is offered during the preparation rest', (
    tester,
  ) async {
    await _pumpRun(tester, _hangWithVideo());

    expect(find.text('WATCH DEMO'), findsOneWidget);
  });

  // The requirement the ticket states: a tap target during a running set has to
  // not be reachable by accident. Once the hang starts there is none.
  testWidgets('the demo video is not reachable while a set is running', (
    tester,
  ) async {
    await _pumpRun(tester, _hangWithVideo());
    await _skip(tester);

    expect(find.text('WATCH DEMO'), findsNothing);
  });

  testWidgets('a self paced step offers the demo video', (tester) async {
    await _pumpRun(tester, _repsWithVideo());
    await _skip(tester);

    expect(find.text('WATCH DEMO'), findsOneWidget);
  });

  // The ticket's requirement has to hold in both designs, not just the default
  // one, and the full tank is a separate layout with its own blocks.
  testWidgets('the full tank offers the demo video during the preparation', (
    tester,
  ) async {
    await _pumpRun(tester, _hangWithVideo(), style: RunScreenStyle.fullTank);

    expect(find.text('WATCH DEMO'), findsOneWidget);
  });

  testWidgets('the full tank hides the demo video while a set is running', (
    tester,
  ) async {
    await _pumpRun(tester, _hangWithVideo(), style: RunScreenStyle.fullTank);
    await _skip(tester);

    expect(find.text('WATCH DEMO'), findsNothing);
  });

  testWidgets('the full tank offers the demo video on a self paced step', (
    tester,
  ) async {
    await _pumpRun(tester, _repsWithVideo(), style: RunScreenStyle.fullTank);
    await _skip(tester);

    expect(find.text('WATCH DEMO'), findsOneWidget);
  });

  // A run of one timed set is preparation then the set, so if the preparation
  // did not offer the video nothing would: this is the gap the full tank had.
  testWidgets('a single timed set still reaches its demo video', (
    tester,
  ) async {
    await _pumpRun(
      tester,
      _singleTimedSetWithVideo(),
      style: RunScreenStyle.fullTank,
    );

    expect(find.text('WATCH DEMO'), findsOneWidget);
  });

  testWidgets('a demo video that cannot be opened says so', (tester) async {
    gVideoLauncher = _RefusingLauncher();
    addTearDown(() => gVideoLauncher = const VideoLauncher());
    await _pumpRun(tester, _hangWithVideo());

    await tester.tap(find.text('WATCH DEMO'));
    await tester.pump();

    expect(find.text('Could not open the video'), findsOneWidget);
  });

  // A note is prose the athlete reads. The ring design scrolls its self paced
  // step once the content does not fit, so the whole note is shown there rather
  // than cut short: there is no pause on a step the athlete ends themselves, so
  // an ellipsis would hide text with no way to reach it.
  testWidgets('the ring design shows a long note whole and scrollable', (
    tester,
  ) async {
    await _pumpRun(tester, _trainingWithLongNote());
    await _skip(tester);

    expect(find.text('NOTE'), findsOneWidget);
    final prose = tester.widget<Text>(find.text(_longNoteText));
    expect(prose.maxLines, isNull);
    expect(
      find.ancestor(
        of: find.text(_longNoteText),
        matching: find.byType(SingleChildScrollView),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  // The reader is only worth anything if the athlete can reach it, and a self
  // paced step carries no play control to pause with: the note itself is the
  // control.
  testWidgets('the full tank opens a long note when the athlete taps it', (
    tester,
  ) async {
    await _pumpRun(
      tester,
      _trainingWithLongNote(),
      style: RunScreenStyle.fullTank,
    );
    await _skip(tester);

    expect(find.text('NOTE'), findsOneWidget);
    expect(find.text(_longNoteText), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsNothing);

    await tester.tap(find.text(_longNoteText));
    await tester.pumpAndSettle();

    // The capped copy on the tank, and the whole note in the reader over it.
    expect(find.text(_longNoteText), findsNWidgets(2));
    expect(find.text('Close'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // The run carries on behind it: the step is still there to finish.
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('DONE'), findsOneWidget);
  });
}
