// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessments_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the list of available assessment trainings.

@ProviderFor(assessmentTrainings)
const assessmentTrainingsProvider = AssessmentTrainingsProvider._();

/// Returns the list of available assessment trainings.

final class AssessmentTrainingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AssessmentTrainingModel>>,
          List<AssessmentTrainingModel>,
          FutureOr<List<AssessmentTrainingModel>>
        >
    with
        $FutureModifier<List<AssessmentTrainingModel>>,
        $FutureProvider<List<AssessmentTrainingModel>> {
  /// Returns the list of available assessment trainings.
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
  $FutureProviderElement<List<AssessmentTrainingModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssessmentTrainingModel>> create(Ref ref) {
    return assessmentTrainings(ref);
  }
}

String _$assessmentTrainingsHash() =>
    r'e5c79ba8e910b170243ef3bef44c0797b8b317b3';

/// Return an assessment training given its type.

@ProviderFor(assessmentTraining)
const assessmentTrainingProvider = AssessmentTrainingFamily._();

/// Return an assessment training given its type.

final class AssessmentTrainingProvider
    extends
        $FunctionalProvider<
          AsyncValue<AssessmentTrainingModel>,
          AssessmentTrainingModel,
          FutureOr<AssessmentTrainingModel>
        >
    with
        $FutureModifier<AssessmentTrainingModel>,
        $FutureProvider<AssessmentTrainingModel> {
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
  $FutureProviderElement<AssessmentTrainingModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AssessmentTrainingModel> create(Ref ref) {
    final argument = this.argument as AssessmentType;
    return assessmentTraining(ref, argument);
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
    r'ba395e4aed11b969e591bda9154203140cdfa988';

/// Return an assessment training given its type.

final class AssessmentTrainingFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<AssessmentTrainingModel>,
          AssessmentType
        > {
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

/// Returns the list of assessments.
/// Allow to filter on `type`.

@ProviderFor(Assessments)
const assessmentsProvider = AssessmentsFamily._();

/// Returns the list of assessments.
/// Allow to filter on `type`.
final class AssessmentsProvider
    extends $AsyncNotifierProvider<Assessments, List<AssessmentModel>> {
  /// Returns the list of assessments.
  /// Allow to filter on `type`.
  const AssessmentsProvider._({
    required AssessmentsFamily super.from,
    required AssessmentType? super.argument,
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

String _$assessmentsHash() => r'68815418ccd654d1bf7a490b2cfda89ca360a86a';

/// Returns the list of assessments.
/// Allow to filter on `type`.

final class AssessmentsFamily extends $Family
    with
        $ClassFamilyOverride<
          Assessments,
          AsyncValue<List<AssessmentModel>>,
          List<AssessmentModel>,
          FutureOr<List<AssessmentModel>>,
          AssessmentType?
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
  /// Allow to filter on `type`.

  AssessmentsProvider call(AssessmentType? type) =>
      AssessmentsProvider._(argument: type, from: this);

  @override
  String toString() => r'assessmentsProvider';
}

/// Returns the list of assessments.
/// Allow to filter on `type`.

abstract class _$Assessments extends $AsyncNotifier<List<AssessmentModel>> {
  late final _$args = ref.$arg as AssessmentType?;
  AssessmentType? get type => _$args;

  FutureOr<List<AssessmentModel>> build(AssessmentType? type);
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
