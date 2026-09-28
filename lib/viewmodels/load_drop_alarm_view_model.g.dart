// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_drop_alarm_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the load of the running rep has dropped below its target, which
/// raises the run screen alarm. The run says which step it is on with
/// [LoadDropAlarmController.follow]; every sensor sample then feeds the rep's
/// [LoadDropAlarm]. See Krakoer/crimpy#175.

@ProviderFor(LoadDropAlarmController)
const loadDropAlarmProvider = LoadDropAlarmControllerProvider._();

/// Whether the load of the running rep has dropped below its target, which
/// raises the run screen alarm. The run says which step it is on with
/// [LoadDropAlarmController.follow]; every sensor sample then feeds the rep's
/// [LoadDropAlarm]. See Krakoer/crimpy#175.
final class LoadDropAlarmControllerProvider
    extends $NotifierProvider<LoadDropAlarmController, bool> {
  /// Whether the load of the running rep has dropped below its target, which
  /// raises the run screen alarm. The run says which step it is on with
  /// [LoadDropAlarmController.follow]; every sensor sample then feeds the rep's
  /// [LoadDropAlarm]. See Krakoer/crimpy#175.
  const LoadDropAlarmControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadDropAlarmProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadDropAlarmControllerHash();

  @$internal
  @override
  LoadDropAlarmController create() => LoadDropAlarmController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$loadDropAlarmControllerHash() =>
    r'b62c5f668b5eb5579262b480e8cda348fa225972';

/// Whether the load of the running rep has dropped below its target, which
/// raises the run screen alarm. The run says which step it is on with
/// [LoadDropAlarmController.follow]; every sensor sample then feeds the rep's
/// [LoadDropAlarm]. See Krakoer/crimpy#175.

abstract class _$LoadDropAlarmController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
