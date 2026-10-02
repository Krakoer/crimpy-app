import 'package:crimpy/repositories/run_cue_preferences_repository.dart';
import 'package:crimpy/services/run_haptics.dart';
import 'package:crimpy/viewmodels/run_cue_preferences_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordedHaptics extends RunHaptics {
  final cues = <RunCue>[];

  @override
  Future<void> play(RunCue cue) async => cues.add(cue);
}

class _StoredPreferences extends RunCuePreferencesRepository {
  _StoredPreferences(this.stored);

  bool stored;

  @override
  Future<bool> vibrates() async => stored;

  @override
  Future<void> setVibrates(bool vibrates) async => stored = vibrates;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('vibration is on until turned off, and stays off', () async {
    expect(await SharedPreferencesRunCuePreferences().vibrates(), isTrue);

    await SharedPreferencesRunCuePreferences().setVibrates(false);

    expect(await SharedPreferencesRunCuePreferences().vibrates(), isFalse);
  });

  group('the run screen haptics', () {
    late _RecordedHaptics vibrator;

    ProviderContainer containerWith(bool stored) {
      vibrator = _RecordedHaptics();
      return ProviderContainer.test(
        overrides: [
          runHapticsProvider.overrideWithValue(vibrator),
          runCuePreferencesRepositoryProvider.overrideWithValue(
            _StoredPreferences(stored),
          ),
        ],
      );
    }

    test('vibrate once the setting says so', () async {
      final container = containerWith(true);
      final haptics = container.read(runCueHapticsProvider);
      await container.read(runCueVibrationProvider.future);

      await haptics.play(RunCue.pullStart);

      expect(vibrator.cues, [RunCue.pullStart]);
    });

    test('stay still when the athlete turned them off', () async {
      final container = containerWith(false);
      final haptics = container.read(runCueHapticsProvider);
      await container.read(runCueVibrationProvider.future);

      await haptics.play(RunCue.pullStart);

      expect(vibrator.cues, isEmpty);
    });

    test('stay still while the setting is still loading', () async {
      final container = containerWith(true);
      final haptics = container.read(runCueHapticsProvider);

      await haptics.play(RunCue.countdown);

      expect(vibrator.cues, isEmpty);
    });

    // The run holds its haptics for minutes and reads them long after the
    // provider that built them could have been disposed.
    test('still play long after they were read', () async {
      final container = containerWith(true);
      final haptics = container.read(runCueHapticsProvider);
      await container.read(runCueVibrationProvider.future);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await haptics.play(RunCue.letGo);

      expect(vibrator.cues, [RunCue.letGo]);
    });

    test('follow a change made mid-run', () async {
      final container = containerWith(true);
      final haptics = container.read(runCueHapticsProvider);
      await container.read(runCueVibrationProvider.future);

      await container.read(runCueVibrationProvider.notifier).set(false);
      await haptics.play(RunCue.letGo);

      expect(vibrator.cues, isEmpty);
    });
  });
}
