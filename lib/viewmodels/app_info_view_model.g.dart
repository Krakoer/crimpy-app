// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that returns app information

@ProviderFor(appInfo)
const appInfoProvider = AppInfoProvider._();

/// Provider that returns app information

final class AppInfoProvider
    extends $FunctionalProvider<AsyncValue<AppInfo>, AppInfo, FutureOr<AppInfo>>
    with $FutureModifier<AppInfo>, $FutureProvider<AppInfo> {
  /// Provider that returns app information
  const AppInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInfoHash();

  @$internal
  @override
  $FutureProviderElement<AppInfo> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppInfo> create(Ref ref) {
    return appInfo(ref);
  }
}

String _$appInfoHash() => r'e0a46d15e0f5673a99db65557628b5e772d52a5a';

/// Provider for managing "What's New" dialog state

@ProviderFor(whatsNew)
const whatsNewProvider = WhatsNewProvider._();

/// Provider for managing "What's New" dialog state

final class WhatsNewProvider
    extends
        $FunctionalProvider<WhatsNewManager, WhatsNewManager, WhatsNewManager>
    with $Provider<WhatsNewManager> {
  /// Provider for managing "What's New" dialog state
  const WhatsNewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatsNewProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatsNewHash();

  @$internal
  @override
  $ProviderElement<WhatsNewManager> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WhatsNewManager create(Ref ref) {
    return whatsNew(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WhatsNewManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WhatsNewManager>(value),
    );
  }
}

String _$whatsNewHash() => r'05475b004e3d15d16c25a8fcc021943e9e86a7fe';
