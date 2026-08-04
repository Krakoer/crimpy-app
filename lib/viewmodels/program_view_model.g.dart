// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Remote program repository, or null when the user is not authenticated
/// (programs are coach/server-owned, so there is no guest-mode equivalent).

@ProviderFor(programRepository)
const programRepositoryProvider = ProgramRepositoryProvider._();

/// Remote program repository, or null when the user is not authenticated
/// (programs are coach/server-owned, so there is no guest-mode equivalent).

final class ProgramRepositoryProvider
    extends
        $FunctionalProvider<
          ProgramRepository?,
          ProgramRepository?,
          ProgramRepository?
        >
    with $Provider<ProgramRepository?> {
  /// Remote program repository, or null when the user is not authenticated
  /// (programs are coach/server-owned, so there is no guest-mode equivalent).
  const ProgramRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProgramRepository?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProgramRepository? create(Ref ref) {
    return programRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgramRepository? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgramRepository?>(value),
    );
  }
}

String _$programRepositoryHash() => r'7e4046628205d92eebc550e438ac166136e2b369';

/// All programs assigned to the user (empty in guest mode).

@ProviderFor(programs)
const programsProvider = ProgramsProvider._();

/// All programs assigned to the user (empty in guest mode).

final class ProgramsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Program>>,
          List<Program>,
          FutureOr<List<Program>>
        >
    with $FutureModifier<List<Program>>, $FutureProvider<List<Program>> {
  /// All programs assigned to the user (empty in guest mode).
  const ProgramsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programsHash();

  @$internal
  @override
  $FutureProviderElement<List<Program>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Program>> create(Ref ref) {
    return programs(ref);
  }
}

String _$programsHash() => r'fd3965231ca551666051345f31568ea8bedff1ab';

/// The program covering today, else the most recent one, else null.

@ProviderFor(activeProgram)
const activeProgramProvider = ActiveProgramProvider._();

/// The program covering today, else the most recent one, else null.

final class ActiveProgramProvider
    extends
        $FunctionalProvider<AsyncValue<Program?>, Program?, FutureOr<Program?>>
    with $FutureModifier<Program?>, $FutureProvider<Program?> {
  /// The program covering today, else the most recent one, else null.
  const ActiveProgramProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeProgramProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeProgramHash();

  @$internal
  @override
  $FutureProviderElement<Program?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Program?> create(Ref ref) {
    return activeProgram(ref);
  }
}

String _$activeProgramHash() => r'c6889583eabeee98442543ae0e9b7539ee19b9f9';

/// Week summaries for a program (empty in guest mode).

@ProviderFor(programWeeks)
const programWeeksProvider = ProgramWeeksFamily._();

/// Week summaries for a program (empty in guest mode).

final class ProgramWeeksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WeekSummary>>,
          List<WeekSummary>,
          FutureOr<List<WeekSummary>>
        >
    with
        $FutureModifier<List<WeekSummary>>,
        $FutureProvider<List<WeekSummary>> {
  /// Week summaries for a program (empty in guest mode).
  const ProgramWeeksProvider._({
    required ProgramWeeksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'programWeeksProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programWeeksHash();

  @override
  String toString() {
    return r'programWeeksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WeekSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WeekSummary>> create(Ref ref) {
    final argument = this.argument as String;
    return programWeeks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramWeeksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programWeeksHash() => r'dae7cee23ac0afa19abcc03fddf5f560539655bb';

/// Week summaries for a program (empty in guest mode).

final class ProgramWeeksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WeekSummary>>, String> {
  const ProgramWeeksFamily._()
    : super(
        retry: null,
        name: r'programWeeksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Week summaries for a program (empty in guest mode).

  ProgramWeeksProvider call(String programId) =>
      ProgramWeeksProvider._(argument: programId, from: this);

  @override
  String toString() => r'programWeeksProvider';
}

/// Full detail for one week, or null when the week is not defined yet.

@ProviderFor(weekDetail)
const weekDetailProvider = WeekDetailFamily._();

/// Full detail for one week, or null when the week is not defined yet.

final class WeekDetailProvider
    extends $FunctionalProvider<AsyncValue<Week?>, Week?, FutureOr<Week?>>
    with $FutureModifier<Week?>, $FutureProvider<Week?> {
  /// Full detail for one week, or null when the week is not defined yet.
  const WeekDetailProvider._({
    required WeekDetailFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: null,
         name: r'weekDetailProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weekDetailHash();

  @override
  String toString() {
    return r'weekDetailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Week?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Week?> create(Ref ref) {
    final argument = this.argument as (String, int);
    return weekDetail(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is WeekDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weekDetailHash() => r'3e076e27b576ea72428d025f6bf645554f0aeb56';

/// Full detail for one week, or null when the week is not defined yet.

final class WeekDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Week?>, (String, int)> {
  const WeekDetailFamily._()
    : super(
        retry: null,
        name: r'weekDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Full detail for one week, or null when the week is not defined yet.

  WeekDetailProvider call(String programId, int weekNumber) =>
      WeekDetailProvider._(argument: (programId, weekNumber), from: this);

  @override
  String toString() => r'weekDetailProvider';
}

/// The training tree referenced by a session in one of the user's programs.
/// Auto-disposed so reopening a training always re-fetches fresh content.

@ProviderFor(programTraining)
const programTrainingProvider = ProgramTrainingFamily._();

/// The training tree referenced by a session in one of the user's programs.
/// Auto-disposed so reopening a training always re-fetches fresh content.

final class ProgramTrainingProvider
    extends
        $FunctionalProvider<AsyncValue<Training>, Training, FutureOr<Training>>
    with $FutureModifier<Training>, $FutureProvider<Training> {
  /// The training tree referenced by a session in one of the user's programs.
  /// Auto-disposed so reopening a training always re-fetches fresh content.
  const ProgramTrainingProvider._({
    required ProgramTrainingFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'programTrainingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programTrainingHash();

  @override
  String toString() {
    return r'programTrainingProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Training> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Training> create(Ref ref) {
    final argument = this.argument as (String, String);
    return programTraining(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramTrainingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programTrainingHash() => r'a22dd934a81686e64bfa9e60b53853355397d499';

/// The training tree referenced by a session in one of the user's programs.
/// Auto-disposed so reopening a training always re-fetches fresh content.

final class ProgramTrainingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Training>, (String, String)> {
  const ProgramTrainingFamily._()
    : super(
        retry: null,
        name: r'programTrainingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The training tree referenced by a session in one of the user's programs.
  /// Auto-disposed so reopening a training always re-fetches fresh content.

  ProgramTrainingProvider call(String programId, String trainingId) =>
      ProgramTrainingProvider._(argument: (programId, trainingId), from: this);

  @override
  String toString() => r'programTrainingProvider';
}

@ProviderFor(activeProgramWeek)
const activeProgramWeekProvider = ActiveProgramWeekProvider._();

final class ActiveProgramWeekProvider
    extends
        $FunctionalProvider<
          AsyncValue<ActiveProgramWeek?>,
          ActiveProgramWeek?,
          FutureOr<ActiveProgramWeek?>
        >
    with
        $FutureModifier<ActiveProgramWeek?>,
        $FutureProvider<ActiveProgramWeek?> {
  const ActiveProgramWeekProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeProgramWeekProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeProgramWeekHash();

  @$internal
  @override
  $FutureProviderElement<ActiveProgramWeek?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ActiveProgramWeek?> create(Ref ref) {
    return activeProgramWeek(ref);
  }
}

String _$activeProgramWeekHash() => r'd2fc1d7ceb575fef5d153d2a19a750ac9e539ba4';

/// All trainings scheduled for today (day-of-week + everyday) in the active
/// program. Empty on a rest day or with no active program.

@ProviderFor(todayTrainings)
const todayTrainingsProvider = TodayTrainingsProvider._();

/// All trainings scheduled for today (day-of-week + everyday) in the active
/// program. Empty on a rest day or with no active program.

final class TodayTrainingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TodayTraining>>,
          List<TodayTraining>,
          FutureOr<List<TodayTraining>>
        >
    with
        $FutureModifier<List<TodayTraining>>,
        $FutureProvider<List<TodayTraining>> {
  /// All trainings scheduled for today (day-of-week + everyday) in the active
  /// program. Empty on a rest day or with no active program.
  const TodayTrainingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayTrainingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayTrainingsHash();

  @$internal
  @override
  $FutureProviderElement<List<TodayTraining>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TodayTraining>> create(Ref ref) {
    return todayTrainings(ref);
  }
}

String _$todayTrainingsHash() => r'da42c1e34e1507e21c99f77379beeef84c5efb25';

/// The first training scheduled for today, or null on a rest day.

@ProviderFor(todayTraining)
const todayTrainingProvider = TodayTrainingProvider._();

/// The first training scheduled for today, or null on a rest day.

final class TodayTrainingProvider
    extends
        $FunctionalProvider<
          AsyncValue<TodayTraining?>,
          TodayTraining?,
          FutureOr<TodayTraining?>
        >
    with $FutureModifier<TodayTraining?>, $FutureProvider<TodayTraining?> {
  /// The first training scheduled for today, or null on a rest day.
  const TodayTrainingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayTrainingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayTrainingHash();

  @$internal
  @override
  $FutureProviderElement<TodayTraining?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TodayTraining?> create(Ref ref) {
    return todayTraining(ref);
  }
}

String _$todayTrainingHash() => r'2108ab2cc5ae9de24cd9425ceaac4a18ed3e460f';
