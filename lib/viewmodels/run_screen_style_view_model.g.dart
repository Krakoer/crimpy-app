// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_screen_style_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runScreenStyleService)
const runScreenStyleServiceProvider = RunScreenStyleServiceProvider._();

final class RunScreenStyleServiceProvider
    extends
        $FunctionalProvider<
          RunScreenStyleService,
          RunScreenStyleService,
          RunScreenStyleService
        >
    with $Provider<RunScreenStyleService> {
  const RunScreenStyleServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runScreenStyleServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runScreenStyleServiceHash();

  @$internal
  @override
  $ProviderElement<RunScreenStyleService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RunScreenStyleService create(Ref ref) {
    return runScreenStyleService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RunScreenStyleService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RunScreenStyleService>(value),
    );
  }
}

String _$runScreenStyleServiceHash() =>
    r'b8d10be50a722f6121e35e1ab1582d4a72544d69';

/// Layout the run screen draws, falling back to [RunScreenStyle.fallback]
/// while it is still being read off the device.

@ProviderFor(RunScreenStyleController)
const runScreenStyleProvider = RunScreenStyleControllerProvider._();

/// Layout the run screen draws, falling back to [RunScreenStyle.fallback]
/// while it is still being read off the device.
final class RunScreenStyleControllerProvider
    extends $AsyncNotifierProvider<RunScreenStyleController, RunScreenStyle> {
  /// Layout the run screen draws, falling back to [RunScreenStyle.fallback]
  /// while it is still being read off the device.
  const RunScreenStyleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runScreenStyleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runScreenStyleControllerHash();

  @$internal
  @override
  RunScreenStyleController create() => RunScreenStyleController();
}

String _$runScreenStyleControllerHash() =>
    r'4c0f6f8bb5a2e452fbe90272ee28a59b0b1b4cef';

/// Layout the run screen draws, falling back to [RunScreenStyle.fallback]
/// while it is still being read off the device.

abstract class _$RunScreenStyleController
    extends $AsyncNotifier<RunScreenStyle> {
  FutureOr<RunScreenStyle> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<RunScreenStyle>, RunScreenStyle>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RunScreenStyle>, RunScreenStyle>,
              AsyncValue<RunScreenStyle>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
