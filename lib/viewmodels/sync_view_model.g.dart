// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SyncViewModel)
const syncViewModelProvider = SyncViewModelProvider._();

final class SyncViewModelProvider
    extends $NotifierProvider<SyncViewModel, SyncState> {
  const SyncViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncViewModelHash();

  @$internal
  @override
  SyncViewModel create() => SyncViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncState>(value),
    );
  }
}

String _$syncViewModelHash() => r'8652c3e2fba11d0e690bb5a68527f07a0b150221';

abstract class _$SyncViewModel extends $Notifier<SyncState> {
  SyncState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SyncState, SyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SyncState, SyncState>,
              SyncState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
