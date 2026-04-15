// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncService)
const syncServiceProvider = SyncServiceProvider._();

final class SyncServiceProvider
    extends $FunctionalProvider<SyncService, SyncService, SyncService>
    with $Provider<SyncService> {
  const SyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncServiceHash();

  @$internal
  @override
  $ProviderElement<SyncService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncService create(Ref ref) {
    return syncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncService>(value),
    );
  }
}

String _$syncServiceHash() => r'339833d2c068dcfa965217c86d255718a746b2c4';

@ProviderFor(syncRepository)
const syncRepositoryProvider = SyncRepositoryProvider._();

final class SyncRepositoryProvider
    extends $FunctionalProvider<SyncRepository, SyncRepository, SyncRepository>
    with $Provider<SyncRepository> {
  const SyncRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncRepositoryHash();

  @$internal
  @override
  $ProviderElement<SyncRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncRepository create(Ref ref) {
    return syncRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncRepository>(value),
    );
  }
}

String _$syncRepositoryHash() => r'a7cbbcbe0aa20ffeb0833b57a4d6f6eee6e8157b';

@ProviderFor(SyncViewModel)
const syncViewModelProvider = SyncViewModelProvider._();

final class SyncViewModelProvider
    extends $AsyncNotifierProvider<SyncViewModel, SyncState> {
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
}

String _$syncViewModelHash() => r'729b3646e146b3ead8ffbe77359d4fa356ae91ae';

abstract class _$SyncViewModel extends $AsyncNotifier<SyncState> {
  FutureOr<SyncState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<SyncState>, SyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SyncState>, SyncState>,
              AsyncValue<SyncState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
