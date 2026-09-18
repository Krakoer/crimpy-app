// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessments_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The assessment protocols the app ships with.
///
/// These are compiled-in definitions, not stored data, so they do not depend on
/// whether the user is signed in.

@ProviderFor(assessmentTrainings)
const assessmentTrainingsProvider = AssessmentTrainingsProvider._();

/// The assessment protocols the app ships with.
///
/// These are compiled-in definitions, not stored data, so they do not depend on
/// whether the user is signed in.

final class AssessmentTrainingsProvider
    extends
        $FunctionalProvider<
          List<AssessmentTrainingModel>,
          List<AssessmentTrainingModel>,
          List<AssessmentTrainingModel>
        >
    with $Provider<List<AssessmentTrainingModel>> {
  /// The assessment protocols the app ships with.
  ///
  /// These are compiled-in definitions, not stored data, so they do not depend on
  /// whether the user is signed in.
  const AssessmentTrainingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assessmentTrainingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assessmentTrainingsHash();

  @$internal
  @override
  $ProviderElement<List<AssessmentTrainingModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<AssessmentTrainingModel> create(Ref ref) {
    return assessmentTrainings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AssessmentTrainingModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AssessmentTrainingModel>>(
        value,
      ),
    );
  }
}

String _$assessmentTrainingsHash() =>
    r'ca76dc19857245b419ddfe9d97610bb3779dbdbc';

/// Return an assessment training given its type.

@ProviderFor(assessmentTraining)
const assessmentTrainingProvider = AssessmentTrainingFamily._();

/// Return an assessment training given its type.

final class AssessmentTrainingProvider
    extends
        $FunctionalProvider<
          AssessmentTrainingModel,
          AssessmentTrainingModel,
          AssessmentTrainingModel
        >
    with $Provider<AssessmentTrainingModel> {
  /// Return an assessment training given its type.
  const AssessmentTrainingProvider._({
    required AssessmentTrainingFamily super.from,
    required AssessmentType super.argument,
  }) : super(
         retry: null,
         name: r'assessmentTrainingProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assessmentTrainingHash();

  @override
  String toString() {
    return r'assessmentTrainingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AssessmentTrainingModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AssessmentTrainingModel create(Ref ref) {
    final argument = this.argument as AssessmentType;
    return assessmentTraining(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssessmentTrainingModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssessmentTrainingModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AssessmentTrainingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assessmentTrainingHash() =>
    r'97edf47cf9b71999b358b5aa46551eeca9c2e0ea';

/// Return an assessment training given its type.

final class AssessmentTrainingFamily extends $Family
    with $FunctionalFamilyOverride<AssessmentTrainingModel, AssessmentType> {
  const AssessmentTrainingFamily._()
    : super(
        retry: null,
        name: r'assessmentTrainingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Return an assessment training given its type.

  AssessmentTrainingProvider call(AssessmentType type) =>
      AssessmentTrainingProvider._(argument: type, from: this);

  @override
  String toString() => r'assessmentTrainingProvider';
}

/// Every assessment that can be measured, so a result can be named and a
/// percentage of one unit checked. Cached locally, so it answers offline.

@ProviderFor(assessmentDefinitions)
const assessmentDefinitionsProvider = AssessmentDefinitionsProvider._();

/// Every assessment that can be measured, so a result can be named and a
/// percentage of one unit checked. Cached locally, so it answers offline.

final class AssessmentDefinitionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AssessmentDefinition>>,
          List<AssessmentDefinition>,
          FutureOr<List<AssessmentDefinition>>
        >
    with
        $FutureModifier<List<AssessmentDefinition>>,
        $FutureProvider<List<AssessmentDefinition>> {
  /// Every assessment that can be measured, so a result can be named and a
  /// percentage of one unit checked. Cached locally, so it answers offline.
  const AssessmentDefinitionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assessmentDefinitionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assessmentDefinitionsHash();

  @$internal
  @override
  $FutureProviderElement<List<AssessmentDefinition>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssessmentDefinition>> create(Ref ref) {
    return assessmentDefinitions(ref);
  }
}

String _$assessmentDefinitionsHash() =>
    r'7d4d30ef23b076c30381d1d822feda7cbe1e8336';

/// The assessments the athlete may record a result against beyond the ones
/// Crimpy ships: their own, and a coach's whose training a program has
/// prescribed to them. Each is measured by running the training that backs it,
/// so the training itself is what this holds.
///
/// This mirrors the rule the server enforces when a result is posted. The
/// prescribed half is a walk over the programs, which can fail offline: when it
/// does the athlete keeps the assessments they own rather than an empty tab.
///
/// Ordered by name, which is how the history lists them once they have results.

@ProviderFor(recordableAssessmentTrainings)
const recordableAssessmentTrainingsProvider =
    RecordableAssessmentTrainingsProvider._();

/// The assessments the athlete may record a result against beyond the ones
/// Crimpy ships: their own, and a coach's whose training a program has
/// prescribed to them. Each is measured by running the training that backs it,
/// so the training itself is what this holds.
///
/// This mirrors the rule the server enforces when a result is posted. The
/// prescribed half is a walk over the programs, which can fail offline: when it
/// does the athlete keeps the assessments they own rather than an empty tab.
///
/// Ordered by name, which is how the history lists them once they have results.

final class RecordableAssessmentTrainingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Training>>,
          List<Training>,
          FutureOr<List<Training>>
        >
    with $FutureModifier<List<Training>>, $FutureProvider<List<Training>> {
  /// The assessments the athlete may record a result against beyond the ones
  /// Crimpy ships: their own, and a coach's whose training a program has
  /// prescribed to them. Each is measured by running the training that backs it,
  /// so the training itself is what this holds.
  ///
  /// This mirrors the rule the server enforces when a result is posted. The
  /// prescribed half is a walk over the programs, which can fail offline: when it
  /// does the athlete keeps the assessments they own rather than an empty tab.
  ///
  /// Ordered by name, which is how the history lists them once they have results.
  const RecordableAssessmentTrainingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordableAssessmentTrainingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordableAssessmentTrainingsHash();

  @$internal
  @override
  $FutureProviderElement<List<Training>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Training>> create(Ref ref) {
    return recordableAssessmentTrainings(ref);
  }
}

String _$recordableAssessmentTrainingsHash() =>
    r'558ae0a727531b81e76cc4d800ccffb3d81b52d2';

/// The athlete latest result per assessment, used to turn the loads, durations
/// and reps a coach set as a percentage of an assessment into numbers.
///
/// The definitions only add names for assessments that were never measured,
/// since a result carries its own, so failing to fetch them must not cost the
/// athlete the numbers they did measure.

@ProviderFor(assessmentResults)
const assessmentResultsProvider = AssessmentResultsProvider._();

/// The athlete latest result per assessment, used to turn the loads, durations
/// and reps a coach set as a percentage of an assessment into numbers.
///
/// The definitions only add names for assessments that were never measured,
/// since a result carries its own, so failing to fetch them must not cost the
/// athlete the numbers they did measure.

final class AssessmentResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AssessmentResults>,
          AssessmentResults,
          FutureOr<AssessmentResults>
        >
    with
        $FutureModifier<AssessmentResults>,
        $FutureProvider<AssessmentResults> {
  /// The athlete latest result per assessment, used to turn the loads, durations
  /// and reps a coach set as a percentage of an assessment into numbers.
  ///
  /// The definitions only add names for assessments that were never measured,
  /// since a result carries its own, so failing to fetch them must not cost the
  /// athlete the numbers they did measure.
  const AssessmentResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assessmentResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assessmentResultsHash();

  @$internal
  @override
  $FutureProviderElement<AssessmentResults> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AssessmentResults> create(Ref ref) {
    return assessmentResults(ref);
  }
}

String _$assessmentResultsHash() => r'fc70903128ed0bf856973ebf3d8ff909818a922d';

/// Returns the list of assessments.
/// Allow to filter on the assessment measured.

@ProviderFor(Assessments)
const assessmentsProvider = AssessmentsFamily._();

/// Returns the list of assessments.
/// Allow to filter on the assessment measured.
final class AssessmentsProvider
    extends $AsyncNotifierProvider<Assessments, List<AssessmentModel>> {
  /// Returns the list of assessments.
  /// Allow to filter on the assessment measured.
  const AssessmentsProvider._({
    required AssessmentsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'assessmentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assessmentsHash();

  @override
  String toString() {
    return r'assessmentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Assessments create() => Assessments();

  @override
  bool operator ==(Object other) {
    return other is AssessmentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assessmentsHash() => r'28e7016f832e4f805495a94f9b6d7aca5d6c30fd';

/// Returns the list of assessments.
/// Allow to filter on the assessment measured.

final class AssessmentsFamily extends $Family
    with
        $ClassFamilyOverride<
          Assessments,
          AsyncValue<List<AssessmentModel>>,
          List<AssessmentModel>,
          FutureOr<List<AssessmentModel>>,
          String?
        > {
  const AssessmentsFamily._()
    : super(
        retry: null,
        name: r'assessmentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns the list of assessments.
  /// Allow to filter on the assessment measured.

  AssessmentsProvider call(String? assessmentId) =>
      AssessmentsProvider._(argument: assessmentId, from: this);

  @override
  String toString() => r'assessmentsProvider';
}

/// Returns the list of assessments.
/// Allow to filter on the assessment measured.

abstract class _$Assessments extends $AsyncNotifier<List<AssessmentModel>> {
  late final _$args = ref.$arg as String?;
  String? get assessmentId => _$args;

  FutureOr<List<AssessmentModel>> build(String? assessmentId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<AsyncValue<List<AssessmentModel>>, List<AssessmentModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AssessmentModel>>,
                List<AssessmentModel>
              >,
              AsyncValue<List<AssessmentModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
