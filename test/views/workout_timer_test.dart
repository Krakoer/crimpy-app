import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/views/widgets/workout_timer.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

TrainingExecutionItem step({required int seconds, required bool isRest}) =>
    isRest
    ? RestItem(durationSeconds: seconds)
    : TimedItem(
        label: 'Pull',
        durationSeconds: seconds,
        targetLoad: 0,
        handSide: HandSide.right,
        gripPosition: GripPosition.halfCrimp,
        collectSensorData: true,
      );

List<TrainingExecutionItem> stepsOf(List<(int, bool)> spec) => [
  for (final s in spec) step(seconds: s.$1, isRest: s.$2),
];

class TimerRun {
  TimerRun(this.frames, this.repCount, this.finished);

  final List<String> frames;
  final int repCount;
  final bool finished;
}

/// Drives the timer with a hand-controlled clock, recording what a screen would
/// paint: one frame per `onSecondChange`, which the timer also fires on every
/// rep transition.
TimerRun run(
  List<TrainingExecutionItem> reps, {
  required int seconds,
  int stepMillis = 100,
  int offsetMillis = 0,
}) {
  final frames = <String>[];
  late WorkoutTimer timer;
  var finished = false;

  fakeAsync((async) {
    final watch = ManualCrimpyWatch();
    timer = WorkoutTimer(
      items: reps,
      watch: watch,
      onSecondChange: () => frames.add(
        '${timer.currentItem is RestItem ? "rest" : "pull"} '
        '${timer.currentItemRemaining}',
      ),
      onFinished: () async => finished = true,
    );
    timer.init();
    timer.play();

    // A deliberate offset shifts the ticks off the second boundary, which is
    // what made the countdown behave differently from one run to the next.
    watch.advance(offsetMillis);

    final ticks = (seconds * 1000) ~/ stepMillis;
    for (var i = 0; i < ticks && !timer.finished; i++) {
      watch.advance(stepMillis);
      async.elapse(Duration(milliseconds: stepMillis));
    }
    if (!timer.finished) timer.timer.cancel();
  });

  return TimerRun(frames, timer.repCount, finished);
}

void main() {
  final protocol = stepsOf([(3, true), (7, false), (3, true), (7, false)]);

  group('WorkoutTimer countdown', () {
    test('counts each second down and never displays zero', () {
      final frames = run(protocol, seconds: 19).frames;

      expect(frames, [
        'rest 2',
        'rest 1',
        'pull 7',
        'pull 6',
        'pull 5',
        'pull 4',
        'pull 3',
        'pull 2',
        'pull 1',
        'rest 3',
        'rest 2',
        'rest 1',
        'pull 7',
        'pull 6',
        'pull 5',
        'pull 4',
        'pull 3',
        'pull 2',
        'pull 1',
      ]);
    });

    test('is identical whether or not ticks land on the second boundary', () {
      final aligned = run(protocol, seconds: 19).frames;
      final offset = run(protocol, seconds: 19, offsetMillis: 37).frames;

      expect(offset, aligned);
    });

    test('never displays zero at any tick granularity', () {
      for (final step in [10, 50, 100, 250]) {
        final frames = run(protocol, seconds: 19, stepMillis: step).frames;

        expect(
          frames.where((f) => f.endsWith(' 0')),
          isEmpty,
          reason: 'step ${step}ms produced $frames',
        );
      }
    });
  });

  group('WorkoutTimer rep counting', () {
    test('counts the final work rep before finishing', () {
      final result = run(protocol, seconds: 30);

      expect(result.finished, isTrue);
      expect(result.repCount, 2);
    });

    test('does not count rests', () {
      final result = run(
        stepsOf([(3, true), (7, false), (3, true)]),
        seconds: 30,
      );

      expect(result.finished, isTrue);
      expect(result.repCount, 1);
    });
  });

  group('emom rounds', () {
    EmomPosition at(int round) => EmomPosition(
      blockKey: 'emom#0',
      itemId: 'emom',
      occurrence: 0,
      round: round,
    );

    List<TrainingExecutionItem> block() => [
      TimedItem(
        label: 'Hang',
        durationSeconds: 10,
        targetLoad: 0,
        handSide: HandSide.right,
        gripPosition: GripPosition.halfCrimp,
        collectSensorData: false,
        emom: at(0),
      ),
      IntervalRestItem(durationSeconds: 50, intervalSeconds: 60, emom: at(0)),
      TimedItem(
        label: 'Hang',
        durationSeconds: 10,
        targetLoad: 0,
        handSide: HandSide.right,
        gripPosition: GripPosition.halfCrimp,
        collectSensorData: false,
        emom: at(1),
      ),
      IntervalRestItem(durationSeconds: 50, intervalSeconds: 60, emom: at(1)),
    ];

    /// Self paced work has no length until it has been done, so the rest that
    /// closes the round is measured back to the step the round opened on. A
    /// round the athlete got through in three seconds rests for the other
    /// fifty seven, and the round after it still starts on the clock.
    test('rests to the mark the next round starts on', () {
      final items = [
        ConfirmItem(label: 'Pull up', emom: at(0)),
        IntervalRestItem(durationSeconds: 60, intervalSeconds: 60, emom: at(0)),
      ];
      late WorkoutTimer timer;
      var restLeft = 0;

      fakeAsync((async) {
        final watch = ManualCrimpyWatch();
        timer = WorkoutTimer(items: items, watch: watch);
        timer.init();
        timer.play();

        watch.advance(3000);
        async.elapse(const Duration(milliseconds: 3000));
        timer.confirmRep();
        restLeft = timer.currentItemDuration;
        timer.timer.cancel();
      });

      expect(restLeft, 57);
    });

    /// Skipping a step is not the same as getting through it quickly: it moves
    /// the clock on by what was left, so the round still takes its interval.
    test('a skipped step leaves the round its full length', () {
      final items = block();
      late WorkoutTimer timer;
      var restLeft = 0;

      fakeAsync((async) {
        final watch = ManualCrimpyWatch();
        timer = WorkoutTimer(items: items, watch: watch);
        timer.init();
        timer.play();

        watch.advance(3000);
        async.elapse(const Duration(milliseconds: 3000));
        timer.skipRep();
        restLeft = timer.currentItemDuration;
        timer.timer.cancel();
      });

      expect(items[1], isA<IntervalRestItem>());
      expect(restLeft, 50);
    });

    test('drops the rounds still queued when the block is left', () {
      final items = block();
      late WorkoutTimer timer;

      fakeAsync((async) {
        final watch = ManualCrimpyWatch();
        timer = WorkoutTimer(items: items, watch: watch);
        timer.init();
        timer.play();
        watch.advance(1000);
        async.elapse(const Duration(milliseconds: 1000));

        timer.dropRemainingBlock('emom#0');
        timer.timer.cancel();
      });

      // Only the hang the run was on is left: the rest that closed its round
      // and the whole round after it are not played.
      expect(items, hasLength(1));
      expect(timer.currentItemIndex, 0);
    });

    test('keeps what follows the block it leaves', () {
      final items = [...block(), RestItem(durationSeconds: 120)];
      late WorkoutTimer timer;

      fakeAsync((async) {
        final watch = ManualCrimpyWatch();
        timer = WorkoutTimer(items: items, watch: watch);
        timer.init();
        timer.play();
        timer.dropRemainingBlock('emom#0');
        timer.timer.cancel();
      });

      expect(items, hasLength(2));
      expect(items.last, isA<RestItem>());
      expect(items.last.emom, isNull);
    });
  });
}
