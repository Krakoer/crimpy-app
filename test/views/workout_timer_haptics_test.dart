import 'dart:io';

import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/services/run_haptics.dart';
import 'package:crimpy/views/widgets/workout_timer.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordedHaptics extends RunHaptics {
  final cues = <String>[];
  WorkoutTimer? timer;

  @override
  Future<void> play(RunCue cue) async {
    final step = timer!.currentItem is RestItem ? 'rest' : 'pull';
    cues.add('${cue.name} in $step ${timer!.currentItemRemaining}');
  }
}

TrainingExecutionItem _pull(int seconds) => TimedItem(
  label: 'Pull',
  durationSeconds: seconds,
  targetLoad: 0,
  handSide: HandSide.right,
  gripPosition: GripPosition.halfCrimp,
  collectSensorData: true,
);

/// Plays [items] to the end on a hand-held clock, recording each cue felt.
List<String> cuesOver(List<TrainingExecutionItem> items) {
  final haptics = _RecordedHaptics();
  fakeAsync((async) {
    final watch = ManualCrimpyWatch();
    final timer = WorkoutTimer(items: items, watch: watch, haptics: haptics);
    haptics.timer = timer;
    timer.init();
    timer.play();
    for (var i = 0; i < 400 && !timer.finished; i++) {
      watch.advance(100);
      async.elapse(const Duration(milliseconds: 100));
    }
  });
  return haptics.cues;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutTimer haptics', () {
    // The same ticks the beeps sound on: the last two seconds of a step, and
    // each timed transition. The transition is played before the step moves
    // on, so it is recorded against the step it closes.
    test('follow the beeps through a run', () {
      final cues = cuesOver([
        RestItem(durationSeconds: 3),
        _pull(3),
        RestItem(durationSeconds: 3),
        _pull(3),
        RestItem(durationSeconds: 3),
      ]);

      expect(cues, [
        'countdown in rest 2',
        'countdown in rest 1',
        'pullStart in rest 0',
        'countdown in pull 2',
        'countdown in pull 1',
        'letGo in pull 0',
        'countdown in rest 2',
        'countdown in rest 1',
        'pullStart in rest 0',
        'countdown in pull 2',
        'countdown in pull 1',
        'letGo in pull 0',
        // The last rest leads into nothing: it counts down in silence, and
        // its end is the end of the run, which has no cue either.
      ]);
    });

    // An emom keeps a child's own rest ahead of the rest closing the round:
    // the athlete is already off the board, so no let go is felt there.
    test('a rest running into a rest is not felt as a let go', () {
      final cues = cuesOver([
        _pull(3),
        RestItem(durationSeconds: 3),
        RestItem(durationSeconds: 3),
        _pull(3),
      ]);

      expect(cues, [
        'countdown in pull 2',
        'countdown in pull 1',
        'letGo in pull 0',
        'countdown in rest 2',
        'countdown in rest 1',
        'countdown in rest 2',
        'countdown in rest 1',
        'pullStart in rest 0',
        'countdown in pull 2',
        'countdown in pull 1',
      ]);
    });

    test('each cue has a pattern of its own', () {
      final patterns = RunCue.values
          .map((cue) => VibrationRunHaptics.patterns[cue]!.join(','))
          .toSet();
      expect(patterns, hasLength(RunCue.values.length));
    });

    test('are silent when the setting is off', () async {
      final inner = _RecordedHaptics();
      var enabled = false;
      final gated = GatedRunHaptics(inner, enabled: () => enabled);
      inner.timer = WorkoutTimer(items: [_pull(3)]);

      await gated.play(RunCue.countdown);
      enabled = true;
      await gated.play(RunCue.letGo);

      expect(inner.cues, hasLength(1));
      expect(inner.cues.single, startsWith('letGo'));
    });

    test('a phone that cannot vibrate does not stop the run', () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const channel = MethodChannel('vibration');
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'no vibrator'),
      );
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      await expectLater(
        VibrationRunHaptics().play(RunCue.pullStart),
        completes,
      );
    });
  });

  // Get a Grip once shipped haptics without it and they failed silently.
  test('the Android app declares the VIBRATE permission', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android.permission.VIBRATE'));
  });
}
