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
