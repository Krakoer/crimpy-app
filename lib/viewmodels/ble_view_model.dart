import 'dart:async';
import 'package:crimpy/database/database.dart';
import 'package:crimpy/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/config.dart';
import '../models/ble_data_model.dart';
import '../repositories/ble_repository.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Returns battery percentage (0–100) from ADC voltage in millivolts.
/// Piecewise linear interpolation from empirical discharge data.
int batteryPercentage(int voltageMv) {
  const table = [
    (mv: 2075, pct: 100),
    (mv: 2050, pct: 99),
    (mv: 2025, pct: 95),
    (mv: 2000, pct: 87),
    (mv: 1975, pct: 74),
    (mv: 1950, pct: 64),
    (mv: 1925, pct: 54),
    (mv: 1900, pct: 40),
    (mv: 1875, pct: 29),
    (mv: 1850, pct: 23),
    (mv: 1825, pct: 19),
    (mv: 1800, pct: 16),
    (mv: 1775, pct: 13),
    (mv: 1750, pct: 10),
    (mv: 1725, pct: 6),
    (mv: 1700, pct: 4),
    (mv: 1650, pct: 3),
    (mv: 1600, pct: 2),
    (mv: 1550, pct: 1),
    (mv: 1500, pct: 0),
  ];

  if (voltageMv >= table.first.mv) return 100;
  if (voltageMv <= table.last.mv) return 0;

  for (int i = 0; i < table.length - 1; i++) {
    if (voltageMv <= table[i].mv && voltageMv >= table[i + 1].mv) {
      final hi = table[i];
      final lo = table[i + 1];
      return lo.pct +
          ((voltageMv - lo.mv) * (hi.pct - lo.pct)) ~/ (hi.mv - lo.mv);
    }
  }
  return 0;
}

/// Main provider, gives access to the BLE repository.
final bleRepositoryProvider = Provider<BleRepository>((ref) {
  final repository = BleRepository();
  repository.initConfig();
  ref.onDispose(() {
    repository.dispose();
  });
  return repository;
});

/// Adapter state provider
final bleAdapterStateProvider =
    NotifierProvider<BleAdapterStateNotifier, BluetoothAdapterState>(
      BleAdapterStateNotifier.new,
    );

class BleAdapterStateNotifier extends Notifier<BluetoothAdapterState> {
  @override
  BluetoothAdapterState build() {
    final repo = ref.watch(bleRepositoryProvider);

    // set initial state
    state = repo.currentAdapterState;

    // listen to stream and update state
    repo.adapterStateStream.listen((s) {
      state = s;
    });

    return state;
  }
}

/// Returns the BLE connection state. Allows to (dis)connect to/from a BLE device.
final connectionStateProvider =
    NotifierProvider<BleConnectionNotifier, BleConnectionState>(
      BleConnectionNotifier.new,
    );

/// ConnectionState notifier
class BleConnectionNotifier extends Notifier<BleConnectionState> {
  late BleRepository _bleRepository;
  StreamSubscription<BleConnectionState>? _sub;

  @override
  BleConnectionState build() {
    _bleRepository = ref.watch(bleRepositoryProvider);
    // set initial state
    state = _bleRepository.currentConnectionState;

    // subscribe to repo stream
    _sub?.cancel();
    _sub = _bleRepository.connectionStateStream.listen((s) {
      state = s;
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return state;
  }

  Future<void> connectToDevice(BluetoothDevice device) =>
      _bleRepository.connectToDevice(device);

  Future<void> disconnect() => _bleRepository.disconnect();
}

/// Returns the connected device info, if any.
final connectedDeviceProvider = Provider<BluetoothDevice?>((ref) {
  return ref.watch(bleRepositoryProvider).connectedDevice;
});

/// Returns the results of a BLE scan.
/// TODO: Maybe convert to a Stream provider so that we don't have to wait till the end of the scan to see the results ?
final scanResultsProvider =
    AsyncNotifierProvider<ScanResultsNotifier, List<BluetoothDevice>>(
      ScanResultsNotifier.new,
    );

class ScanResultsNotifier extends AsyncNotifier<List<BluetoothDevice>> {
  @override
  Future<List<BluetoothDevice>> build() async {
    final bleRepository = ref.watch(bleRepositoryProvider);
    state = AsyncValue.loading();
    return await bleRepository.scanForDevices();
  }
}

/// Battery level as a percentage (0-100), or null if unsupported/disconnected.
final batteryLevelProvider = NotifierProvider<BatteryLevelNotifier, double?>(
  BatteryLevelNotifier.new,
);

class BatteryLevelNotifier extends Notifier<double?> {
  Timer? _timer;
  bool _supportsBattery = false;

  @override
  double? build() {
    final connectionState = ref.watch(connectionStateProvider);
    final bleRepository = ref.watch(bleRepositoryProvider);

    if (connectionState == BleConnectionState.connected) {
      // Query firmware version and start polling on connect
      _startPolling(bleRepository);
    } else {
      _stopPolling();
      _supportsBattery = false;
      return null;
    }

    ref.onDispose(() => _stopPolling());
    return null;
  }

  Future<void> _startPolling(BleRepository repo) async {
    // Wait for BLE service discovery to complete before reading characteristics
    await repo.waitForServicesDiscovered();

    // Check firmware version first
    final version = await repo.getFirmwareVersion();

    _supportsBattery = version != null && version >= 1000;

    if (!_supportsBattery) {
      state = null;
      AppLoggerHelper.warning(
        "The firmware version ($version) does not support battery level.",
      );
      return;
    }
    AppLoggerHelper.debug(
      "The firmware supports battery level, starting to poll...",
    );

    // Initial read
    await _readBattery(repo);

    // Poll every 60 seconds
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 60), (_) => _readBattery(repo));
  }

  Future<void> _readBattery(BleRepository repo) async {
    final voltage = await repo.getBatteryVoltage();
    AppLoggerHelper.debug("Battery level is $voltage");
    if (voltage == null) return;
    state = batteryPercentage(voltage).clamp(0, 100).toDouble();
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Returns a stream of calibrated BleDataPoint sent by the BLE device.
final bleDataStreamProvider =
    StreamNotifierProvider<BleDataStreamNotifier, List<BleDataPoint>>(
      BleDataStreamNotifier.new,
    );

class BleDataStreamNotifier extends StreamNotifier<List<BleDataPoint>> {
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
final bleSessionProvider =
    NotifierProvider<BleSessionNotifier, BleSessionStats>(
      BleSessionNotifier.new,
    );

class BleSessionNotifier extends Notifier<BleSessionStats> {
  late BleRepository _bleRepository;
  DateTime? _startTime;

  @override
  BleSessionStats build() {
    _bleRepository = ref.watch(bleRepositoryProvider);

    _bleRepository.dataStream.listen((p) => _update(p));

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
final bleConfigProvider = NotifierProvider<BleConfigNotifier, BleConfig>(
  BleConfigNotifier.new,
);

class BleConfigNotifier extends Notifier<BleConfig> {
  late BleRepository _bleRepository;

  @override
  BleConfig build() {
    _bleRepository = ref.watch(bleRepositoryProvider);
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

  Future<void> updateSensorConfigs(List<SensorConfigs> configs) async {
    await _bleRepository.updateSensorConfigs(configs);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteSensorConfig(int id) async {
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
