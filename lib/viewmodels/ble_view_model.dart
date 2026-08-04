import 'dart:async';
import 'package:crimpy/database/database.dart';
// Needed for the hand-written sensorConfigsProvider below; riverpod_annotation
// alone does not expose the manual provider types.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:crimpy/models/config.dart';
import '../models/ble_data_model.dart';
import '../repositories/ble_repository.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'ble_view_model.g.dart';

/// Retry policy that gives up immediately.
Duration? noRetry(int retryCount, Object error) => null;

/// Main provider, gives access to the BLE repository.
@Riverpod(keepAlive: true)
BleRepository bleRepository(Ref ref) {
  final repository = BleRepository();
  // Loads the stored calibration in the background. Consumers that need the
  // persisted values wait on `configReady` instead of blocking creation here.
  unawaited(repository.initConfig());
  ref.onDispose(repository.dispose);
  return repository;
}

/// Adapter state provider
@Riverpod(keepAlive: true)
class BleAdapterState extends _$BleAdapterState {
  @override
  BluetoothAdapterState build() {
    final repo = ref.watch(bleRepositoryProvider);

    final subscription = repo.adapterStateStream.listen((s) {
      state = s;
    });
    ref.onDispose(subscription.cancel);

    return repo.currentAdapterState;
  }
}

/// Returns the BLE connection state. Allows to (dis)connect to/from a BLE device.
@Riverpod(keepAlive: true, name: 'connectionStateProvider')
class BleConnection extends _$BleConnection {
  late BleRepository _bleRepository;

  @override
  BleConnectionState build() {
    _bleRepository = ref.watch(bleRepositoryProvider);

    final subscription = _bleRepository.connectionStateStream.listen((s) {
      state = s;
    });
    ref.onDispose(subscription.cancel);

    return _bleRepository.currentConnectionState;
  }

  Future<void> connectToDevice(BluetoothDevice device) =>
      _bleRepository.connectToDevice(device);

  Future<void> disconnect() => _bleRepository.disconnect();
}

/// Returns the connected device info, if any.
@Riverpod(keepAlive: true)
BluetoothDevice? connectedDevice(Ref ref) {
  return ref.watch(bleRepositoryProvider).connectedDevice;
}

/// Returns the results of a BLE scan.
/// A scan that fails because the adapter is off must not be retried on its own:
/// the user turns Bluetooth back on and triggers a new scan explicitly.
/// TODO: Maybe convert to a Stream provider so that we don't have to wait till the end of the scan to see the results ?
@Riverpod(keepAlive: true, retry: noRetry)
class ScanResults extends _$ScanResults {
  @override
  Future<List<BluetoothDevice>> build() {
    final bleRepository = ref.watch(bleRepositoryProvider);
    return bleRepository.scanForDevices();
  }
}

/// Returns a stream of calibrated BleDataPoint sent by the BLE device.
@Riverpod(keepAlive: true)
class BleDataStream extends _$BleDataStream {
  late BleRepository _bleRepository;
  final List<BleDataPoint> _dataPoints = [];

  @override
  Stream<List<BleDataPoint>> build() {
    _bleRepository = ref.watch(bleRepositoryProvider);

    return _bleRepository.dataStream.map((dataPoint) {
      _dataPoints.add(dataPoint);
      // Max out at 25000 to avoid mem bloating.
      if (_dataPoints.length > 25000) {
        _dataPoints.removeAt(0);
      }
      return List<BleDataPoint>.from(_dataPoints);
    });
  }

  double? lastValue() {
    if (_dataPoints.isEmpty) {
      return null;
    }
    return _dataPoints.last.value;
  }

  List<BleDataPoint> getData() {
    return _dataPoints;
  }

  void reset() {
    _dataPoints.clear();
  }
}

/// The most recent calibrated value, or null before the first sample.
/// Watching this instead of the notifier gives widgets a dependency that
/// actually changes when a sample arrives, and filters out samples that repeat
/// the previous value.
@Riverpod(keepAlive: true)
double? bleLastValue(Ref ref) {
  final points = ref.watch(bleDataStreamProvider).value;
  return (points == null || points.isEmpty) ? null : points.last.value;
}

/// Class to hold the current BLE session statistics.
class BleSessionStats {
  final Duration elapsed;
  final double avg;
  final double max;
  final int nbPoints;

  BleSessionStats({
    this.avg = 0,
    this.elapsed = Duration.zero,
    this.max = 0,
    this.nbPoints = 0,
  });
}

/// Returns the current session stats.
/// Allows the session to be reset.
@Riverpod(keepAlive: true)
class BleSession extends _$BleSession {
  late BleRepository _bleRepository;
  DateTime? _startTime;

  @override
  BleSessionStats build() {
    _bleRepository = ref.watch(bleRepositoryProvider);

    final subscription = _bleRepository.dataStream.listen(_update);
    ref.onDispose(subscription.cancel);

    return BleSessionStats();
  }

  void _update(BleDataPoint newPoint) {
    double newAvg =
        (state.avg * state.nbPoints + newPoint.value) / (state.nbPoints + 1);
    double newMax = newPoint.value > state.max ? newPoint.value : state.max;
    _startTime ??= newPoint.timestamp;
    state = BleSessionStats(
      avg: newAvg,
      elapsed: DateTime.now().difference(_startTime!),
      max: newMax,
      nbPoints: state.nbPoints + 1,
    );
  }

  /// Reset the current BLE session statistics.
  void reset() {
    // Clear the current session data in the repository
    _bleRepository.resetSession();
    ref.read(bleDataStreamProvider.notifier).reset();
    _startTime = null;
    state = BleSessionStats();
  }
}

/// Returns the current BLE config state (calibration coef and tare).
/// Allows the config to be edited, either manually or through calibration.
@Riverpod(keepAlive: true, name: 'bleConfigProvider')
class BleConfigController extends _$BleConfigController {
  late BleRepository _bleRepository;

  @override
  BleConfig build() {
    _bleRepository = ref.watch(bleRepositoryProvider);

    // The stored config is loaded asynchronously, so the first build can only
    // see the defaults. Rebuild once the real values land.
    if (!_bleRepository.isConfigLoaded) {
      _bleRepository.configReady.then((_) {
        if (ref.mounted) ref.invalidateSelf();
      });
    }

    return BleConfig(
      tare: _bleRepository.tare,
      calibration: _bleRepository.calibrationCoef,
    );
  }

  /// Set the tare to the last BLE value.
  Future<void> tare() async {
    final tareValue = _bleRepository.lastOriginalValue;
    // If no value received by BLE, do nothing.
    if (tareValue.isNaN) {
      return;
    }

    await _bleRepository.setTare(tareValue);
    ref.invalidateSelf();
  }

  /// Starts a calibration session.
  /// Call `stopCalibration()` to end the calibration.
  void startCalibration() {
    _bleRepository.startCalibration();
  }

  /// Ends the calibration session and computes the calibration coef
  /// based on the target weight.
  void stopCalibration(double targetWeight) async {
    double calMean = _bleRepository.stopCalibration();
    double calCoef = targetWeight / (calMean - _bleRepository.tare);
    await _bleRepository.setCalibrationCoef(calCoef);

    ref.invalidateSelf();
  }

  /// Manually set the tare to a new value
  void setTare(double newValue) async {
    await _bleRepository.setTare(newValue);
    ref.invalidateSelf();
  }

  /// Manually set the calibration coef to a new value.
  void setCalibration(double newValue) async {
    await _bleRepository.setCalibrationCoef(newValue);
    ref.invalidateSelf();
  }

  /// Load a saved calibration config.
  Future<void> loadConfig(SensorConfig config) async {
    _bleRepository.loadConfig(config);
    ref.invalidateSelf();
  }
}

/// Returns the saved calibration configurations.
/// Allows the creation, edition and deletion of configurations.
/// Declared by hand rather than generated: `SensorConfig` is a drift row class
/// emitted into a part file, and riverpod_generator cannot write an import for
/// a type that has no importable library of its own.
final sensorConfigsProvider =
    AsyncNotifierProvider<SensorConfigsNotifier, List<SensorConfig>>(
      SensorConfigsNotifier.new,
    );

class SensorConfigsNotifier extends AsyncNotifier<List<SensorConfig>> {
  late BleRepository _bleRepository;

  @override
  Future<List<SensorConfig>> build() {
    _bleRepository = ref.watch(bleRepositoryProvider);
    return _bleRepository.getSensorConfigs();
  }

  Future<void> updateSensorConfigs(List<SensorConfig> configs) async {
    await _bleRepository.updateSensorConfigs(configs);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteSensorConfig(String id) async {
    await _bleRepository.deleteSensorConfig(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> addSensorConfig(SensorConfigsCompanion config) async {
    await _bleRepository.addSensorConfig(config);
    ref.invalidateSelf();
    await future;
  }
}
