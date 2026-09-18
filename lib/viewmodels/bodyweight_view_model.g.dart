// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bodyweight_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bodyweightService)
const bodyweightServiceProvider = BodyweightServiceProvider._();

final class BodyweightServiceProvider
    extends
        $FunctionalProvider<
          BodyweightService,
          BodyweightService,
          BodyweightService
        >
    with $Provider<BodyweightService> {
  const BodyweightServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodyweightServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodyweightServiceHash();

  @$internal
  @override
  $ProviderElement<BodyweightService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BodyweightService create(Ref ref) {
    return bodyweightService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BodyweightService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BodyweightService>(value),
    );
  }
}

String _$bodyweightServiceHash() => r'5f2abc0cd663e9ff1992e60b6d3deab73ba76ba2';

@ProviderFor(bodyweightRepository)
const bodyweightRepositoryProvider = BodyweightRepositoryProvider._();

final class BodyweightRepositoryProvider
    extends
        $FunctionalProvider<
          BodyweightRepository,
          BodyweightRepository,
          BodyweightRepository
        >
    with $Provider<BodyweightRepository> {
  const BodyweightRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodyweightRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodyweightRepositoryHash();

  @$internal
  @override
  $ProviderElement<BodyweightRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BodyweightRepository create(Ref ref) {
    return bodyweightRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BodyweightRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BodyweightRepository>(value),
    );
  }
}

String _$bodyweightRepositoryHash() =>
    r'16dc72d752997aca36fb6cbe672fb986d0213397';

/// The athlete bodyweight in kilograms, null until it is entered or measured.
///
/// The value is cached on the device because a run must not need the network,
/// and written through to the server because the coach reads the series and a
/// percent_bw prescription is frozen against it.

@ProviderFor(BodyweightController)
const bodyweightProvider = BodyweightControllerProvider._();

/// The athlete bodyweight in kilograms, null until it is entered or measured.
///
/// The value is cached on the device because a run must not need the network,
/// and written through to the server because the coach reads the series and a
/// percent_bw prescription is frozen against it.
final class BodyweightControllerProvider
    extends $AsyncNotifierProvider<BodyweightController, double?> {
  /// The athlete bodyweight in kilograms, null until it is entered or measured.
  ///
  /// The value is cached on the device because a run must not need the network,
  /// and written through to the server because the coach reads the series and a
  /// percent_bw prescription is frozen against it.
  const BodyweightControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodyweightProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodyweightControllerHash();

  @$internal
  @override
  BodyweightController create() => BodyweightController();
}

String _$bodyweightControllerHash() =>
    r'00083f9a6b96347258a403e80d62a4bf6ec43ed0';

/// The athlete bodyweight in kilograms, null until it is entered or measured.
///
/// The value is cached on the device because a run must not need the network,
/// and written through to the server because the coach reads the series and a
/// percent_bw prescription is frozen against it.

abstract class _$BodyweightController extends $AsyncNotifier<double?> {
  FutureOr<double?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<double?>, double?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<double?>, double?>,
              AsyncValue<double?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
