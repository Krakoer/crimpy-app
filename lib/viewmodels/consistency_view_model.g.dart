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
    r'30bcf6740919007fba77b7403c5469c0157a7e5a';

/// What the home screen's strip draws: the program's last two weeks while a
/// program covers today, the athlete's own habits otherwise, and null when
/// there is neither, since there is then nothing to keep.

@ProviderFor(consistencyStrip)
const consistencyStripProvider = ConsistencyStripProvider._();

/// What the home screen's strip draws: the program's last two weeks while a
/// program covers today, the athlete's own habits otherwise, and null when
/// there is neither, since there is then nothing to keep.

final class ConsistencyStripProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConsistencyDay>?>,
          List<ConsistencyDay>?,
          FutureOr<List<ConsistencyDay>?>
        >
    with
        $FutureModifier<List<ConsistencyDay>?>,
        $FutureProvider<List<ConsistencyDay>?> {
  /// What the home screen's strip draws: the program's last two weeks while a
  /// program covers today, the athlete's own habits otherwise, and null when
  /// there is neither, since there is then nothing to keep.
  const ConsistencyStripProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'consistencyStripProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$consistencyStripHash();

  @$internal
  @override
  $FutureProviderElement<List<ConsistencyDay>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ConsistencyDay>?> create(Ref ref) {
    return consistencyStrip(ref);
  }
}

String _$consistencyStripHash() => r'9645ead0123aa2364340a2c1236fa39398015c2d';
