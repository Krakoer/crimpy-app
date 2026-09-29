// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_cue_preferences_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runCuePreferencesRepository)
const runCuePreferencesRepositoryProvider =
    RunCuePreferencesRepositoryProvider._();

final class RunCuePreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          RunCuePreferencesRepository,
          RunCuePreferencesRepository,
          RunCuePreferencesRepository
        >
    with $Provider<RunCuePreferencesRepository> {
  const RunCuePreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runCuePreferencesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runCuePreferencesRepositoryHash();

  @$internal
  @override
  $ProviderElement<RunCuePreferencesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RunCuePreferencesRepository create(Ref ref) {
    return runCuePreferencesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RunCuePreferencesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RunCuePreferencesRepository>(value),
    );
  }
}

String _$runCuePreferencesRepositoryHash() =>
    r'420853de7198bc3929fee298e03e2df30cde7804';

/// What plays the run's cues as vibrations.

@ProviderFor(runHaptics)
const runHapticsProvider = RunHapticsProvider._();

/// What plays the run's cues as vibrations.

final class RunHapticsProvider
    extends $FunctionalProvider<RunHaptics, RunHaptics, RunHaptics>
    with $Provider<RunHaptics> {
  /// What plays the run's cues as vibrations.
  const RunHapticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runHapticsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runHapticsHash();

  @$internal
  @override
  $ProviderElement<RunHaptics> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RunHaptics create(Ref ref) {
    return runHaptics(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RunHaptics value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RunHaptics>(value),
    );
  }
}

String _$runHapticsHash() => r'3eda785e11a50d3eb98eb9cd831e9b444c2c56c2';

/// Whether the run screen vibrates on its cues. Allows it to be turned off.

@ProviderFor(RunCueVibration)
const runCueVibrationProvider = RunCueVibrationProvider._();

/// Whether the run screen vibrates on its cues. Allows it to be turned off.
final class RunCueVibrationProvider
    extends $AsyncNotifierProvider<RunCueVibration, bool> {
  /// Whether the run screen vibrates on its cues. Allows it to be turned off.
  const RunCueVibrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runCueVibrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runCueVibrationHash();

  @$internal
  @override
  RunCueVibration create() => RunCueVibration();
}

String _$runCueVibrationHash() => r'b6531501f9b154ab413f4fcd258443012073cf2e';

/// Whether the run screen vibrates on its cues. Allows it to be turned off.

abstract class _$RunCueVibration extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
