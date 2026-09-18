// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the trainings repository (local Drift in guest mode, remote API when authenticated).

@ProviderFor(trainingRepository)
const trainingRepositoryProvider = TrainingRepositoryProvider._();

/// Returns the trainings repository (local Drift in guest mode, remote API when authenticated).

final class TrainingRepositoryProvider
    extends
        $FunctionalProvider<
          TrainingRepository,
          TrainingRepository,
          TrainingRepository
        >
    with $Provider<TrainingRepository> {
  /// Returns the trainings repository (local Drift in guest mode, remote API when authenticated).
  const TrainingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trainingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trainingRepositoryHash();

  @$internal
  @override
  $ProviderElement<TrainingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TrainingRepository create(Ref ref) {
    return trainingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrainingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrainingRepository>(value),
    );
  }
}

String _$trainingRepositoryHash() =>
    r'4390f41d3ed826830fd867795f5e31caa3bd74b0';

/// Returns the assessment repository (local Drift in guest mode, remote API when authenticated).

@ProviderFor(assessmentRepository)
const assessmentRepositoryProvider = AssessmentRepositoryProvider._();

/// Returns the assessment repository (local Drift in guest mode, remote API when authenticated).

final class AssessmentRepositoryProvider
    extends
        $FunctionalProvider<
          AssessmentRepository,
          AssessmentRepository,
          AssessmentRepository
        >
    with $Provider<AssessmentRepository> {
  /// Returns the assessment repository (local Drift in guest mode, remote API when authenticated).
  const AssessmentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assessmentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assessmentRepositoryHash();

  @$internal
  @override
  $ProviderElement<AssessmentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AssessmentRepository create(Ref ref) {
    return assessmentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssessmentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssessmentRepository>(value),
    );
  }
}

String _$assessmentRepositoryHash() =>
    r'1a0002e2b5fda65b241a0805adb745e1ffd39be1';

/// Returns the builtin preferences repository (local in guest mode, remote when authenticated).

@ProviderFor(builtinPreferencesRepository)
const builtinPreferencesRepositoryProvider =
    BuiltinPreferencesRepositoryProvider._();

/// Returns the builtin preferences repository (local in guest mode, remote when authenticated).

final class BuiltinPreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          BuiltinPreferencesRepository,
          BuiltinPreferencesRepository,
          BuiltinPreferencesRepository
        >
    with $Provider<BuiltinPreferencesRepository> {
  /// Returns the builtin preferences repository (local in guest mode, remote when authenticated).
  const BuiltinPreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'builtinPreferencesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$builtinPreferencesRepositoryHash();

  @$internal
  @override
  $ProviderElement<BuiltinPreferencesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BuiltinPreferencesRepository create(Ref ref) {
    return builtinPreferencesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BuiltinPreferencesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BuiltinPreferencesRepository>(value),
    );
  }
}

String _$builtinPreferencesRepositoryHash() =>
    r'558d33a7082a5ebcc267e0861ca14de9457813db';

/// Returns the builtin trainings repository, injecting the appropriate dependencies.

@ProviderFor(builtinTrainingRepository)
const builtinTrainingRepositoryProvider = BuiltinTrainingRepositoryProvider._();

/// Returns the builtin trainings repository, injecting the appropriate dependencies.

final class BuiltinTrainingRepositoryProvider
    extends
        $FunctionalProvider<
          BuiltinTrainingRepository,
          BuiltinTrainingRepository,
          BuiltinTrainingRepository
        >
    with $Provider<BuiltinTrainingRepository> {
  /// Returns the builtin trainings repository, injecting the appropriate dependencies.
  const BuiltinTrainingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'builtinTrainingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$builtinTrainingRepositoryHash();

  @$internal
  @override
  $ProviderElement<BuiltinTrainingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BuiltinTrainingRepository create(Ref ref) {
    return builtinTrainingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BuiltinTrainingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BuiltinTrainingRepository>(value),
    );
  }
}

String _$builtinTrainingRepositoryHash() =>
    r'3129edbdb68f0acafe4db2b37483944432d7e7af';

/// Returns favorite trainings.

@ProviderFor(FavTrainings)
const favTrainingsProvider = FavTrainingsProvider._();

/// Returns favorite trainings.
final class FavTrainingsProvider
    extends $AsyncNotifierProvider<FavTrainings, List<Training>> {
  /// Returns favorite trainings.
  const FavTrainingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favTrainingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favTrainingsHash();

  @$internal
  @override
  FavTrainings create() => FavTrainings();
}

String _$favTrainingsHash() => r'ddbb4caa73c0b74005a2d732af763bd4353f241a';

/// Returns favorite trainings.

abstract class _$FavTrainings extends $AsyncNotifier<List<Training>> {
  FutureOr<List<Training>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Training>>, List<Training>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Training>>, List<Training>>,
              AsyncValue<List<Training>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Returns all trainings and allows creating, updating, and deleting them.

@ProviderFor(Trainings)
const trainingsProvider = TrainingsProvider._();

/// Returns all trainings and allows creating, updating, and deleting them.
final class TrainingsProvider
    extends $AsyncNotifierProvider<Trainings, List<Training>> {
  /// Returns all trainings and allows creating, updating, and deleting them.
  const TrainingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trainingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trainingsHash();

  @$internal
  @override
  Trainings create() => Trainings();
}

String _$trainingsHash() => r'3dacd25a1d5852b99536da3ecc4757300963b71d';

/// Returns all trainings and allows creating, updating, and deleting them.

abstract class _$Trainings extends $AsyncNotifier<List<Training>> {
  FutureOr<List<Training>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Training>>, List<Training>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Training>>, List<Training>>,
              AsyncValue<List<Training>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Returns the list of all sessions, and allows the creation of new sessions.

@ProviderFor(Sessions)
const sessionsProvider = SessionsProvider._();

/// Returns the list of all sessions, and allows the creation of new sessions.
final class SessionsProvider
    extends $AsyncNotifierProvider<Sessions, List<SessionModel>> {
  /// Returns the list of all sessions, and allows the creation of new sessions.
  const SessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionsHash();

  @$internal
  @override
  Sessions create() => Sessions();
}

String _$sessionsHash() => r'b9a59e71046cb4cb112afe3bb7646db9a8c13fbf';

/// Returns the list of all sessions, and allows the creation of new sessions.

abstract class _$Sessions extends $AsyncNotifier<List<SessionModel>> {
  FutureOr<List<SessionModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<SessionModel>>, List<SessionModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SessionModel>>, List<SessionModel>>,
              AsyncValue<List<SessionModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for getting a single session with full data by ID.
/// Auto-disposed: a loaded session carries its whole BLE sample array, so one
/// cached entry per visited session would keep growing for the whole run.

@ProviderFor(sessionWithData)
const sessionWithDataProvider = SessionWithDataFamily._();

/// Provider for getting a single session with full data by ID.
/// Auto-disposed: a loaded session carries its whole BLE sample array, so one
/// cached entry per visited session would keep growing for the whole run.

final class SessionWithDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<SessionModel?>,
          SessionModel?,
          FutureOr<SessionModel?>
        >
    with $FutureModifier<SessionModel?>, $FutureProvider<SessionModel?> {
  /// Provider for getting a single session with full data by ID.
  /// Auto-disposed: a loaded session carries its whole BLE sample array, so one
  /// cached entry per visited session would keep growing for the whole run.
  const SessionWithDataProvider._({
    required SessionWithDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sessionWithDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionWithDataHash();

  @override
  String toString() {
    return r'sessionWithDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SessionModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SessionModel?> create(Ref ref) {
    final argument = this.argument as String;
    return sessionWithData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionWithDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionWithDataHash() => r'aca34b528e0864edcdadb94469a924a9d3cb7bf1';

/// Provider for getting a single session with full data by ID.
/// Auto-disposed: a loaded session carries its whole BLE sample array, so one
/// cached entry per visited session would keep growing for the whole run.

final class SessionWithDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SessionModel?>, String> {
  const SessionWithDataFamily._()
    : super(
        retry: null,
        name: r'sessionWithDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for getting a single session with full data by ID.
  /// Auto-disposed: a loaded session carries its whole BLE sample array, so one
  /// cached entry per visited session would keep growing for the whole run.

  SessionWithDataProvider call(String sessionId) =>
      SessionWithDataProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionWithDataProvider';
}

/// The items a played session was run from, so its reps can be read block by
/// block. Empty when the session was not played from a training, or when the
/// training has been deleted since.
///
/// The live training is what names the blocks, not a snapshot: editing a
/// training relabels the blocks of the sessions already played from it, which
/// costs a heading rather than the grouping itself.

@ProviderFor(sessionTrainingItems)
const sessionTrainingItemsProvider = SessionTrainingItemsFamily._();

/// The items a played session was run from, so its reps can be read block by
/// block. Empty when the session was not played from a training, or when the
/// training has been deleted since.
///
/// The live training is what names the blocks, not a snapshot: editing a
/// training relabels the blocks of the sessions already played from it, which
/// costs a heading rather than the grouping itself.

final class SessionTrainingItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TrainingItem>>,
          List<TrainingItem>,
          FutureOr<List<TrainingItem>>
        >
    with
        $FutureModifier<List<TrainingItem>>,
        $FutureProvider<List<TrainingItem>> {
  /// The items a played session was run from, so its reps can be read block by
  /// block. Empty when the session was not played from a training, or when the
  /// training has been deleted since.
  ///
  /// The live training is what names the blocks, not a snapshot: editing a
  /// training relabels the blocks of the sessions already played from it, which
  /// costs a heading rather than the grouping itself.
  const SessionTrainingItemsProvider._({
    required SessionTrainingItemsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'sessionTrainingItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionTrainingItemsHash();

  @override
  String toString() {
    return r'sessionTrainingItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TrainingItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TrainingItem>> create(Ref ref) {
    final argument = this.argument as String?;
    return sessionTrainingItems(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionTrainingItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionTrainingItemsHash() =>
    r'0c20137944069418a1214b82bd2e5f58a8c4dd72';

/// The items a played session was run from, so its reps can be read block by
/// block. Empty when the session was not played from a training, or when the
/// training has been deleted since.
///
/// The live training is what names the blocks, not a snapshot: editing a
/// training relabels the blocks of the sessions already played from it, which
/// costs a heading rather than the grouping itself.

final class SessionTrainingItemsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TrainingItem>>, String?> {
  const SessionTrainingItemsFamily._()
    : super(
        retry: null,
        name: r'sessionTrainingItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The items a played session was run from, so its reps can be read block by
  /// block. Empty when the session was not played from a training, or when the
  /// training has been deleted since.
  ///
  /// The live training is what names the blocks, not a snapshot: editing a
  /// training relabels the blocks of the sessions already played from it, which
  /// costs a heading rather than the grouping itself.

  SessionTrainingItemsProvider call(String? trainingId) =>
      SessionTrainingItemsProvider._(argument: trainingId, from: this);

  @override
  String toString() => r'sessionTrainingItemsProvider';
}

/// Provider that returns filtered sessions based on a given filter.
/// Auto-disposed: the filtered list is derived from the cached sessions, so
/// recomputing it is cheap compared to holding one list per filter used.

@ProviderFor(filteredSessions)
const filteredSessionsProvider = FilteredSessionsFamily._();

/// Provider that returns filtered sessions based on a given filter.
/// Auto-disposed: the filtered list is derived from the cached sessions, so
/// recomputing it is cheap compared to holding one list per filter used.

final class FilteredSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SessionModel>>,
          List<SessionModel>,
          FutureOr<List<SessionModel>>
        >
    with
        $FutureModifier<List<SessionModel>>,
        $FutureProvider<List<SessionModel>> {
  /// Provider that returns filtered sessions based on a given filter.
  /// Auto-disposed: the filtered list is derived from the cached sessions, so
  /// recomputing it is cheap compared to holding one list per filter used.
  const FilteredSessionsProvider._({
    required FilteredSessionsFamily super.from,
    required SessionFilter? super.argument,
  }) : super(
         retry: null,
         name: r'filteredSessionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredSessionsHash();

  @override
  String toString() {
    return r'filteredSessionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SessionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SessionModel>> create(Ref ref) {
    final argument = this.argument as SessionFilter?;
    return filteredSessions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredSessionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredSessionsHash() => r'228c34a328aa3f28c8538d43b163923efe9ef32a';

/// Provider that returns filtered sessions based on a given filter.
/// Auto-disposed: the filtered list is derived from the cached sessions, so
/// recomputing it is cheap compared to holding one list per filter used.

final class FilteredSessionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SessionModel>>,
          SessionFilter?
        > {
  const FilteredSessionsFamily._()
    : super(
        retry: null,
        name: r'filteredSessionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider that returns filtered sessions based on a given filter.
  /// Auto-disposed: the filtered list is derived from the cached sessions, so
  /// recomputing it is cheap compared to holding one list per filter used.

  FilteredSessionsProvider call(SessionFilter? filter) =>
      FilteredSessionsProvider._(argument: filter, from: this);

  @override
  String toString() => r'filteredSessionsProvider';
}

/// Provider for pinned builtin trainings (with favorites).

@ProviderFor(PinnedTrainings)
const pinnedTrainingsProvider = PinnedTrainingsProvider._();

/// Provider for pinned builtin trainings (with favorites).
final class PinnedTrainingsProvider
    extends $AsyncNotifierProvider<PinnedTrainings, List<TrainingListItem>> {
  /// Provider for pinned builtin trainings (with favorites).
  const PinnedTrainingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinnedTrainingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinnedTrainingsHash();

  @$internal
  @override
  PinnedTrainings create() => PinnedTrainings();
}

String _$pinnedTrainingsHash() => r'340e0adc411e5fa2d647013997a27ce8ab1a750d';

/// Provider for pinned builtin trainings (with favorites).

abstract class _$PinnedTrainings
    extends $AsyncNotifier<List<TrainingListItem>> {
  FutureOr<List<TrainingListItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<TrainingListItem>>, List<TrainingListItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<TrainingListItem>>,
                List<TrainingListItem>
              >,
              AsyncValue<List<TrainingListItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for combined training list (regular + builtin trainings).

@ProviderFor(AllTrainings)
const allTrainingsProvider = AllTrainingsProvider._();

/// Provider for combined training list (regular + builtin trainings).
final class AllTrainingsProvider
    extends $AsyncNotifierProvider<AllTrainings, List<TrainingListItem>> {
  /// Provider for combined training list (regular + builtin trainings).
  const AllTrainingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTrainingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTrainingsHash();

  @$internal
  @override
  AllTrainings create() => AllTrainings();
}

String _$allTrainingsHash() => r'839d0c316ec92344cf3af4f415aa62093b76aed0';

/// Provider for combined training list (regular + builtin trainings).

abstract class _$AllTrainings extends $AsyncNotifier<List<TrainingListItem>> {
  FutureOr<List<TrainingListItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<TrainingListItem>>, List<TrainingListItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<TrainingListItem>>,
                List<TrainingListItem>
              >,
              AsyncValue<List<TrainingListItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
