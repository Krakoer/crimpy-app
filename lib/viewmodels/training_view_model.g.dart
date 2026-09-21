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

/// The athlete's training library, read once and shared by everything that
/// lists trainings.
///
/// The library comes back in a single request carrying every training in full,
/// so the favourites are a filter over what is already in hand rather than a
/// narrower read. Four providers used to call the repository themselves and
/// each one put the byte identical request on the wire: a home screen pull sent
/// two at the same time. They all derive from this now, and the fetch happens
/// once.
///
/// This is the provider to invalidate to fetch the library again. Invalidating
/// one of the lists below rebuilds it from the library already held and never
/// reaches the server, which is what makes a pinned or builtin change free.

@ProviderFor(trainingLibrary)
const trainingLibraryProvider = TrainingLibraryProvider._();

/// The athlete's training library, read once and shared by everything that
/// lists trainings.
///
/// The library comes back in a single request carrying every training in full,
/// so the favourites are a filter over what is already in hand rather than a
/// narrower read. Four providers used to call the repository themselves and
/// each one put the byte identical request on the wire: a home screen pull sent
/// two at the same time. They all derive from this now, and the fetch happens
/// once.
///
/// This is the provider to invalidate to fetch the library again. Invalidating
/// one of the lists below rebuilds it from the library already held and never
/// reaches the server, which is what makes a pinned or builtin change free.

final class TrainingLibraryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Training>>,
          List<Training>,
          FutureOr<List<Training>>
        >
    with $FutureModifier<List<Training>>, $FutureProvider<List<Training>> {
  /// The athlete's training library, read once and shared by everything that
  /// lists trainings.
  ///
  /// The library comes back in a single request carrying every training in full,
  /// so the favourites are a filter over what is already in hand rather than a
  /// narrower read. Four providers used to call the repository themselves and
  /// each one put the byte identical request on the wire: a home screen pull sent
  /// two at the same time. They all derive from this now, and the fetch happens
  /// once.
  ///
  /// This is the provider to invalidate to fetch the library again. Invalidating
  /// one of the lists below rebuilds it from the library already held and never
  /// reaches the server, which is what makes a pinned or builtin change free.
  const TrainingLibraryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trainingLibraryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trainingLibraryHash();

  @$internal
  @override
  $FutureProviderElement<List<Training>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Training>> create(Ref ref) {
    return trainingLibrary(ref);
  }
}

String _$trainingLibraryHash() => r'682832b945d463a239c802bba42d197a7bd28153';

/// Everything the builtin half of a training list is built from, read once and
/// shared the way the library is.
///
/// The pinned list and the full list show the same builtins against the same
/// pins, assessments and custom weights. Reading those per list put the same
/// three requests on the wire twice, which is the library duplication one layer
/// down. None of it belongs to the library, so a pin change drops this and
/// leaves the library alone, and a pull drops both.
///
/// The three reads are independent and go out together, so the catalog costs
/// one round trip rather than three. It reads the assessments and the weights
/// even when the athlete has pinned nothing, where the pinned list alone used
/// to stop at the pins: making them conditional would mean a list that watches
/// them only sometimes, which is the staleness the shared provider exists to
/// remove. It is two small requests on a cold start, against a list that
/// evaluates a builtin the moment one is pinned.

@ProviderFor(builtinTrainingCatalog)
const builtinTrainingCatalogProvider = BuiltinTrainingCatalogProvider._();

/// Everything the builtin half of a training list is built from, read once and
/// shared the way the library is.
///
/// The pinned list and the full list show the same builtins against the same
/// pins, assessments and custom weights. Reading those per list put the same
/// three requests on the wire twice, which is the library duplication one layer
/// down. None of it belongs to the library, so a pin change drops this and
/// leaves the library alone, and a pull drops both.
///
/// The three reads are independent and go out together, so the catalog costs
/// one round trip rather than three. It reads the assessments and the weights
/// even when the athlete has pinned nothing, where the pinned list alone used
/// to stop at the pins: making them conditional would mean a list that watches
/// them only sometimes, which is the staleness the shared provider exists to
/// remove. It is two small requests on a cold start, against a list that
/// evaluates a builtin the moment one is pinned.

final class BuiltinTrainingCatalogProvider
    extends
        $FunctionalProvider<
          AsyncValue<BuiltinTrainingCatalog>,
          BuiltinTrainingCatalog,
          FutureOr<BuiltinTrainingCatalog>
        >
    with
        $FutureModifier<BuiltinTrainingCatalog>,
        $FutureProvider<BuiltinTrainingCatalog> {
  /// Everything the builtin half of a training list is built from, read once and
  /// shared the way the library is.
  ///
  /// The pinned list and the full list show the same builtins against the same
  /// pins, assessments and custom weights. Reading those per list put the same
  /// three requests on the wire twice, which is the library duplication one layer
  /// down. None of it belongs to the library, so a pin change drops this and
  /// leaves the library alone, and a pull drops both.
  ///
  /// The three reads are independent and go out together, so the catalog costs
  /// one round trip rather than three. It reads the assessments and the weights
  /// even when the athlete has pinned nothing, where the pinned list alone used
  /// to stop at the pins: making them conditional would mean a list that watches
  /// them only sometimes, which is the staleness the shared provider exists to
  /// remove. It is two small requests on a cold start, against a list that
  /// evaluates a builtin the moment one is pinned.
  const BuiltinTrainingCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'builtinTrainingCatalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$builtinTrainingCatalogHash();

  @$internal
  @override
  $FutureProviderElement<BuiltinTrainingCatalog> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BuiltinTrainingCatalog> create(Ref ref) {
    return builtinTrainingCatalog(ref);
  }
}

String _$builtinTrainingCatalogHash() =>
    r'8dae1aabd749fbd33b15785beed4bf934c176f22';

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

String _$favTrainingsHash() => r'9252c05e9626563b1ff40c82a5afb59adbe1f50e';

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

String _$trainingsHash() => r'6ece01f4daab055d6ff890811a4e08054c250b1a';

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

String _$pinnedTrainingsHash() => r'b4bbc566fcc320c240ffa417fd602f9f8a1177c2';

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

/// Every training the athlete can start: their own library followed by the
/// builtins, each evaluated against the latest assessments.

@ProviderFor(allTrainings)
const allTrainingsProvider = AllTrainingsProvider._();

/// Every training the athlete can start: their own library followed by the
/// builtins, each evaluated against the latest assessments.

final class AllTrainingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TrainingListItem>>,
          List<TrainingListItem>,
          FutureOr<List<TrainingListItem>>
        >
    with
        $FutureModifier<List<TrainingListItem>>,
        $FutureProvider<List<TrainingListItem>> {
  /// Every training the athlete can start: their own library followed by the
  /// builtins, each evaluated against the latest assessments.
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
  $FutureProviderElement<List<TrainingListItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TrainingListItem>> create(Ref ref) {
    return allTrainings(ref);
  }
}

String _$allTrainingsHash() => r'a412e15260a6cd0c32d79d7805af98d6266bd264';
