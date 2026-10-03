// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trainingHabitService)
const trainingHabitServiceProvider = TrainingHabitServiceProvider._();

final class TrainingHabitServiceProvider
    extends
        $FunctionalProvider<
          TrainingHabitService,
          TrainingHabitService,
          TrainingHabitService
        >
    with $Provider<TrainingHabitService> {
  const TrainingHabitServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trainingHabitServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trainingHabitServiceHash();

  @$internal
  @override
  $ProviderElement<TrainingHabitService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TrainingHabitService create(Ref ref) {
    return trainingHabitService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrainingHabitService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrainingHabitService>(value),
    );
  }
}

String _$trainingHabitServiceHash() =>
    r'7551265b229c13dde717c568a033b0ff4236c7af';

/// The habits stored for whoever uses the app now, and the actions that change
/// them. Several trainings can each be a habit, one habit per training.

@ProviderFor(TrainingHabits)
const trainingHabitsProvider = TrainingHabitsProvider._();

/// The habits stored for whoever uses the app now, and the actions that change
/// them. Several trainings can each be a habit, one habit per training.
final class TrainingHabitsProvider
    extends $AsyncNotifierProvider<TrainingHabits, List<TrainingHabit>> {
  /// The habits stored for whoever uses the app now, and the actions that change
  /// them. Several trainings can each be a habit, one habit per training.
  const TrainingHabitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trainingHabitsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trainingHabitsHash();

  @$internal
  @override
  TrainingHabits create() => TrainingHabits();
}

String _$trainingHabitsHash() => r'2fa1916c119b0f2a46d9f4b8cb1457b5757f1585';

/// The habits stored for whoever uses the app now, and the actions that change
/// them. Several trainings can each be a habit, one habit per training.

abstract class _$TrainingHabits extends $AsyncNotifier<List<TrainingHabit>> {
  FutureOr<List<TrainingHabit>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<TrainingHabit>>, List<TrainingHabit>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TrainingHabit>>, List<TrainingHabit>>,
              AsyncValue<List<TrainingHabit>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// The habits whose training is still in the library, with the training as it
/// is now. What everything else reads: a habit naming a training deleted on
/// another device would otherwise be reminded of and drawn as owed forever.

@ProviderFor(activeHabits)
const activeHabitsProvider = ActiveHabitsProvider._();

/// The habits whose training is still in the library, with the training as it
/// is now. What everything else reads: a habit naming a training deleted on
/// another device would otherwise be reminded of and drawn as owed forever.

final class ActiveHabitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ActiveHabit>>,
          List<ActiveHabit>,
          FutureOr<List<ActiveHabit>>
        >
    with
        $FutureModifier<List<ActiveHabit>>,
        $FutureProvider<List<ActiveHabit>> {
  /// The habits whose training is still in the library, with the training as it
  /// is now. What everything else reads: a habit naming a training deleted on
  /// another device would otherwise be reminded of and drawn as owed forever.
  const ActiveHabitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeHabitsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeHabitsHash();

  @$internal
  @override
  $FutureProviderElement<List<ActiveHabit>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ActiveHabit>> create(Ref ref) {
    return activeHabits(ref);
  }
}

String _$activeHabitsHash() => r'a50b80a9132330a5d6d9fb24eac8e2b3974b6906';
