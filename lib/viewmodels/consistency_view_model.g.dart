// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consistency_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The last two weeks of the active program, day by day, for the home screen's
/// consistency strip. Null when no program covers today: what a day owes comes
/// from the program, so without one there is nothing to keep.

@ProviderFor(programConsistency)
const programConsistencyProvider = ProgramConsistencyProvider._();

/// The last two weeks of the active program, day by day, for the home screen's
/// consistency strip. Null when no program covers today: what a day owes comes
/// from the program, so without one there is nothing to keep.

final class ProgramConsistencyProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConsistencyDay>?>,
          List<ConsistencyDay>?,
          FutureOr<List<ConsistencyDay>?>
        >
    with
        $FutureModifier<List<ConsistencyDay>?>,
        $FutureProvider<List<ConsistencyDay>?> {
  /// The last two weeks of the active program, day by day, for the home screen's
  /// consistency strip. Null when no program covers today: what a day owes comes
  /// from the program, so without one there is nothing to keep.
  const ProgramConsistencyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programConsistencyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programConsistencyHash();

  @$internal
  @override
  $FutureProviderElement<List<ConsistencyDay>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ConsistencyDay>?> create(Ref ref) {
    return programConsistency(ref);
  }
}

String _$programConsistencyHash() =>
    r'3f424c7cca5f9978d96b6e5baf542fef78a1e669';
