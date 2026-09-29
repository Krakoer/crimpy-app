import 'package:crimpy/repositories/run_cue_preferences_repository.dart';
import 'package:crimpy/services/run_haptics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_cue_preferences_view_model.g.dart';

@Riverpod(keepAlive: true)
RunCuePreferencesRepository runCuePreferencesRepository(Ref ref) =>
    SharedPreferencesRunCuePreferences();

/// What plays the run's cues as vibrations.
@Riverpod(keepAlive: true)
RunHaptics runHaptics(Ref ref) => VibrationRunHaptics();

/// Whether the run screen vibrates on its cues. Allows it to be turned off.
@Riverpod(keepAlive: true)
class RunCueVibration extends _$RunCueVibration {
  @override
  Future<bool> build() =>
      ref.watch(runCuePreferencesRepositoryProvider).vibrates();

  Future<void> set(bool vibrates) async {
    state = AsyncData(vibrates);
    await ref.read(runCuePreferencesRepositoryProvider).setVibrates(vibrates);
  }
}

/// What the run screen plays its cues through: the vibrations, heard only
/// while the setting says so. The setting is asked at every cue, so one still
/// loading when the run starts counts as off rather than buzzing an athlete
/// who turned it off, and a change takes effect on the next cue.
@riverpod
RunHaptics runCueHaptics(Ref ref) => GatedRunHaptics(
  ref.watch(runHapticsProvider),
  enabled: () => ref.read(runCueVibrationProvider).value ?? false,
);
