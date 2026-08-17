// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Main provider, gives access to the BLE repository.

@ProviderFor(bleRepository)
const bleRepositoryProvider = BleRepositoryProvider._();

/// Main provider, gives access to the BLE repository.

final class BleRepositoryProvider
    extends $FunctionalProvider<BleRepository, BleRepository, BleRepository>
    with $Provider<BleRepository> {
  /// Main provider, gives access to the BLE repository.
  const BleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleRepositoryHash();

  @$internal
  @override
  $ProviderElement<BleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BleRepository create(Ref ref) {
    return bleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BleRepository>(value),
    );
  }
}

String _$bleRepositoryHash() => r'dd8aec7fe877bd2d4ffa782add52d9d61e54de99';

/// Adapter state provider

@ProviderFor(BleAdapterState)
const bleAdapterStateProvider = BleAdapterStateProvider._();

/// Adapter state provider
final class BleAdapterStateProvider
    extends $NotifierProvider<BleAdapterState, BluetoothAdapterState> {
  /// Adapter state provider
  const BleAdapterStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleAdapterStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleAdapterStateHash();

  @$internal
  @override
  BleAdapterState create() => BleAdapterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BluetoothAdapterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BluetoothAdapterState>(value),
    );
  }
}

String _$bleAdapterStateHash() => r'69e1ae7719a5989c24ada6ee4de1d4332c927660';

/// Adapter state provider

abstract class _$BleAdapterState extends $Notifier<BluetoothAdapterState> {
  BluetoothAdapterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<BluetoothAdapterState, BluetoothAdapterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BluetoothAdapterState, BluetoothAdapterState>,
              BluetoothAdapterState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Returns the BLE connection state. Allows to (dis)connect to/from a BLE device.

@ProviderFor(BleConnection)
const connectionStateProvider = BleConnectionProvider._();

/// Returns the BLE connection state. Allows to (dis)connect to/from a BLE device.
final class BleConnectionProvider
    extends $NotifierProvider<BleConnection, BleConnectionState> {
  /// Returns the BLE connection state. Allows to (dis)connect to/from a BLE device.
  const BleConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleConnectionHash();

  @$internal
  @override
  BleConnection create() => BleConnection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BleConnectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BleConnectionState>(value),
    );
  }
}

String _$bleConnectionHash() => r'cf944a9a7cee9427702382eee91a3252c66524c8';

/// Returns the BLE connection state. Allows to (dis)connect to/from a BLE device.

abstract class _$BleConnection extends $Notifier<BleConnectionState> {
  BleConnectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<BleConnectionState, BleConnectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BleConnectionState, BleConnectionState>,
              BleConnectionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Returns the connected device info, if any.

@ProviderFor(connectedDevice)
const connectedDeviceProvider = ConnectedDeviceProvider._();

/// Returns the connected device info, if any.

final class ConnectedDeviceProvider
    extends
        $FunctionalProvider<
          BluetoothDevice?,
          BluetoothDevice?,
          BluetoothDevice?
        >
    with $Provider<BluetoothDevice?> {
  /// Returns the connected device info, if any.
  const ConnectedDeviceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectedDeviceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectedDeviceHash();

  @$internal
  @override
  $ProviderElement<BluetoothDevice?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BluetoothDevice? create(Ref ref) {
    return connectedDevice(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BluetoothDevice? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BluetoothDevice?>(value),
    );
  }
}

String _$connectedDeviceHash() => r'f3a9e57b47be3514a046045e8a4bb7ca17ce89b7';

/// Returns the results of a BLE scan.
/// A scan that fails because the adapter is off must not be retried on its own:
/// the user turns Bluetooth back on and triggers a new scan explicitly.
/// TODO: Maybe convert to a Stream provider so that we don't have to wait till the end of the scan to see the results ?

@ProviderFor(ScanResults)
const scanResultsProvider = ScanResultsProvider._();

/// Returns the results of a BLE scan.
/// A scan that fails because the adapter is off must not be retried on its own:
/// the user turns Bluetooth back on and triggers a new scan explicitly.
/// TODO: Maybe convert to a Stream provider so that we don't have to wait till the end of the scan to see the results ?
final class ScanResultsProvider
    extends $AsyncNotifierProvider<ScanResults, List<BluetoothDevice>> {
  /// Returns the results of a BLE scan.
  /// A scan that fails because the adapter is off must not be retried on its own:
  /// the user turns Bluetooth back on and triggers a new scan explicitly.
  /// TODO: Maybe convert to a Stream provider so that we don't have to wait till the end of the scan to see the results ?
  const ScanResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: noRetry,
        name: r'scanResultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scanResultsHash();

  @$internal
  @override
  ScanResults create() => ScanResults();
}

String _$scanResultsHash() => r'515670811cbaef78a20eb85272d2fc218bd868e5';

/// Returns the results of a BLE scan.
/// A scan that fails because the adapter is off must not be retried on its own:
/// the user turns Bluetooth back on and triggers a new scan explicitly.
/// TODO: Maybe convert to a Stream provider so that we don't have to wait till the end of the scan to see the results ?

abstract class _$ScanResults extends $AsyncNotifier<List<BluetoothDevice>> {
  FutureOr<List<BluetoothDevice>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<BluetoothDevice>>, List<BluetoothDevice>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<BluetoothDevice>>,
                List<BluetoothDevice>
              >,
              AsyncValue<List<BluetoothDevice>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Returns a stream of calibrated BleDataPoint sent by the BLE device.

@ProviderFor(BleDataStream)
const bleDataStreamProvider = BleDataStreamProvider._();

/// Returns a stream of calibrated BleDataPoint sent by the BLE device.
final class BleDataStreamProvider
    extends $StreamNotifierProvider<BleDataStream, List<BleDataPoint>> {
  /// Returns a stream of calibrated BleDataPoint sent by the BLE device.
  const BleDataStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleDataStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleDataStreamHash();

  @$internal
  @override
  BleDataStream create() => BleDataStream();
}

String _$bleDataStreamHash() => r'c21e42ffa3a8276379db86dd5161454ec5c1eeb4';

/// Returns a stream of calibrated BleDataPoint sent by the BLE device.

abstract class _$BleDataStream extends $StreamNotifier<List<BleDataPoint>> {
  Stream<List<BleDataPoint>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<BleDataPoint>>, List<BleDataPoint>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<BleDataPoint>>, List<BleDataPoint>>,
              AsyncValue<List<BleDataPoint>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// The most recent calibrated value, or null before the first sample.
/// Watching this instead of the notifier gives widgets a dependency that
/// actually changes when a sample arrives, and filters out samples that repeat
/// the previous value.

@ProviderFor(bleLastValue)
const bleLastValueProvider = BleLastValueProvider._();

/// The most recent calibrated value, or null before the first sample.
/// Watching this instead of the notifier gives widgets a dependency that
/// actually changes when a sample arrives, and filters out samples that repeat
/// the previous value.

final class BleLastValueProvider
    extends $FunctionalProvider<double?, double?, double?>
    with $Provider<double?> {
  /// The most recent calibrated value, or null before the first sample.
  /// Watching this instead of the notifier gives widgets a dependency that
  /// actually changes when a sample arrives, and filters out samples that repeat
  /// the previous value.
  const BleLastValueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleLastValueProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleLastValueHash();

  @$internal
  @override
  $ProviderElement<double?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double? create(Ref ref) {
    return bleLastValue(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double?>(value),
    );
  }
}

String _$bleLastValueHash() => r'92760af6ef22787be7bf19063b44d0d09fdbefc1';

/// Returns the current session stats.
/// Allows the session to be reset.

@ProviderFor(BleSession)
const bleSessionProvider = BleSessionProvider._();

/// Returns the current session stats.
/// Allows the session to be reset.
final class BleSessionProvider
    extends $NotifierProvider<BleSession, BleSessionStats> {
  /// Returns the current session stats.
  /// Allows the session to be reset.
  const BleSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleSessionHash();

  @$internal
  @override
  BleSession create() => BleSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BleSessionStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BleSessionStats>(value),
    );
  }
}

String _$bleSessionHash() => r'ceb99baf654de7406a35b1c35154728755edbc56';

/// Returns the current session stats.
/// Allows the session to be reset.

abstract class _$BleSession extends $Notifier<BleSessionStats> {
  BleSessionStats build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<BleSessionStats, BleSessionStats>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BleSessionStats, BleSessionStats>,
              BleSessionStats,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Returns the current BLE config state (calibration coef and tare).
/// Allows the config to be edited, either manually or through calibration.

@ProviderFor(BleConfigController)
const bleConfigProvider = BleConfigControllerProvider._();

/// Returns the current BLE config state (calibration coef and tare).
/// Allows the config to be edited, either manually or through calibration.
final class BleConfigControllerProvider
    extends $NotifierProvider<BleConfigController, BleConfig> {
  /// Returns the current BLE config state (calibration coef and tare).
  /// Allows the config to be edited, either manually or through calibration.
  const BleConfigControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleConfigControllerHash();

  @$internal
  @override
  BleConfigController create() => BleConfigController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BleConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BleConfig>(value),
    );
  }
}

String _$bleConfigControllerHash() =>
    r'7cff50cb3aa7c6c7840e76f96b4e01e02128d6b3';

/// Returns the current BLE config state (calibration coef and tare).
/// Allows the config to be edited, either manually or through calibration.

abstract class _$BleConfigController extends $Notifier<BleConfig> {
  BleConfig build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<BleConfig, BleConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BleConfig, BleConfig>,
              BleConfig,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Returns the saved calibration presets.
/// Allows the creation, edition and deletion of presets.

@ProviderFor(SensorPresets)
const sensorPresetsProvider = SensorPresetsProvider._();

/// Returns the saved calibration presets.
/// Allows the creation, edition and deletion of presets.
final class SensorPresetsProvider
    extends $AsyncNotifierProvider<SensorPresets, List<SensorPreset>> {
  /// Returns the saved calibration presets.
  /// Allows the creation, edition and deletion of presets.
  const SensorPresetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sensorPresetsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sensorPresetsHash();

  @$internal
  @override
  SensorPresets create() => SensorPresets();
}

String _$sensorPresetsHash() => r'f3f9aff39adea47b89848efd84b4e07458e39235';

/// Returns the saved calibration presets.
/// Allows the creation, edition and deletion of presets.

abstract class _$SensorPresets extends $AsyncNotifier<List<SensorPreset>> {
  FutureOr<List<SensorPreset>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<SensorPreset>>, List<SensorPreset>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SensorPreset>>, List<SensorPreset>>,
              AsyncValue<List<SensorPreset>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
