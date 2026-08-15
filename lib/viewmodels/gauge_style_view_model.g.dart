// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gauge_style_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gaugeStyleService)
const gaugeStyleServiceProvider = GaugeStyleServiceProvider._();

final class GaugeStyleServiceProvider
    extends
        $FunctionalProvider<
          GaugeStyleService,
          GaugeStyleService,
          GaugeStyleService
        >
    with $Provider<GaugeStyleService> {
  const GaugeStyleServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gaugeStyleServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gaugeStyleServiceHash();

  @$internal
  @override
  $ProviderElement<GaugeStyleService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GaugeStyleService create(Ref ref) {
    return gaugeStyleService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GaugeStyleService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GaugeStyleService>(value),
    );
  }
}

String _$gaugeStyleServiceHash() => r'58faf4bb3cf94466a36198446d7e9d11bb044cc2';

/// Gauge design the run screen draws, falling back to [GaugeStyle.fallback]
/// while it is still being read off the device.

@ProviderFor(GaugeStyleController)
const gaugeStyleProvider = GaugeStyleControllerProvider._();

/// Gauge design the run screen draws, falling back to [GaugeStyle.fallback]
/// while it is still being read off the device.
final class GaugeStyleControllerProvider
    extends $AsyncNotifierProvider<GaugeStyleController, GaugeStyle> {
  /// Gauge design the run screen draws, falling back to [GaugeStyle.fallback]
  /// while it is still being read off the device.
  const GaugeStyleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gaugeStyleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gaugeStyleControllerHash();

  @$internal
  @override
  GaugeStyleController create() => GaugeStyleController();
}

String _$gaugeStyleControllerHash() =>
    r'4e69dd88d5714df7d48f39d99f97d35b50c4b521';

/// Gauge design the run screen draws, falling back to [GaugeStyle.fallback]
/// while it is still being read off the device.

abstract class _$GaugeStyleController extends $AsyncNotifier<GaugeStyle> {
  FutureOr<GaugeStyle> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<GaugeStyle>, GaugeStyle>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GaugeStyle>, GaugeStyle>,
              AsyncValue<GaugeStyle>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
