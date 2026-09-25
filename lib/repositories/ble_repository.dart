import 'dart:async';
import 'dart:typed_data';
import '../models/ble_data_model.dart';
import '../database/database.dart';
import 'package:crimpy/models/sensor_preset.dart';
import 'package:crimpy/services/sensor_link/flutter_blue_plus_sensor_link.dart';
import 'package:crimpy/services/sensor_link/sensor_link.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BleRepository {
  BleRepository({SensorLink? link})
    : _link = link ?? FlutterBluePlusSensorLink();

  final SensorLink _link;

  // ------------------------------------- BLE DEVICE -------------------------------------
  /// Whether the Bluetooth adapter is on, starting with the current state.
  Stream<bool> get adapterOnStream async* {
    yield _link.isAdapterOn;
    yield* _link.adapterOnChanges;
  }

  bool get isAdapterOn => _link.isAdapterOn;

  Future<void> turnAdapterOn() => _link.turnAdapterOn();

  final _connectionStateController =
      StreamController<BleConnectionState>.broadcast();

  Stream<BleConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  BleConnectionState get currentConnectionState => _device == null
      ? BleConnectionState.disconnected
      : BleConnectionState.connected;

  /// Stores the connected device.
  SensorDevice? _device;

  /// The open connection to [_device].
  SensorChannel? _channel;

  /// Subscriptions to the connected device. They are held so a reconnection
  /// replaces them instead of stacking a second set on top: every extra
  /// listener re-emits the same notification, which doubles the apparent
  /// sample rate and the connection state events.
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;

  /// returns whether a device is connected and a characteristic is listened to.
  bool get isConnected => _device != null && _channel != null;

  /// Get the current connected device.
  SensorDevice? get connectedDevice => _device;

  Future<List<SensorDevice>> scanForDevices() => _link.scan();

  Future<bool> connectToDevice(SensorDevice device) async {
    try {
      _connectionStateController.add(BleConnectionState.connecting);
      final channel = await _link.open(device);
      if (channel == null) {
        _device = null;
        _connectionStateController.add(BleConnectionState.disconnected);
        return false;
      }
      _device = device;
      _channel = channel;

      await _connectionSubscription?.cancel();
      _connectionSubscription = channel.connectionChanges.listen((connected) {
        if (connected) {
          _connectionStateController.add(BleConnectionState.connected);
        } else {
          _connectionStateController.add(BleConnectionState.disconnected);
          _device = null;
          _channel = null;
        }
      });

      await _characteristicSubscription?.cancel();
      _characteristicSubscription = channel.notifications.listen(
        handleRawSample,
      );
      return true;
    } catch (e) {
      _device = null;
      _channel = null;
      _connectionStateController.add(BleConnectionState.failed);
      return false;
    }
  }

  Future<void> disconnect() async {
    final channel = _channel;
    _channel = null;
    _device = null;
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    await _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    await channel?.close();
    // Disposing the repository disconnects and closes the controller without
    // waiting for the disconnection to complete, so by the time we get here
    // there may be nothing left to notify.
    if (_connectionStateController.isClosed) return;
    _connectionStateController.add(BleConnectionState.disconnected);
  }

  // ------------------------------------- SENSOR VALUES -------------------------------------
  /// Stream controller to broadcast received calibrated values from sensor.
  final _dataStreamController = StreamController<BleDataPoint>.broadcast();

  /// Public calibrated BLE data stream.
  Stream<BleDataPoint> get dataStream => _dataStreamController.stream;

  /// Wether the received data are streamed.
  bool _streamDataOn = true;

  /// Whether incoming samples currently reach [dataStream].
  bool get isStreaming => _streamDataOn;

  /// Decodes one raw notification from the sensor characteristic and routes it
  /// to the data stream and to the running calibration. Kept apart from the
  /// subscription so the pause gate can be exercised without a BLE device.
  void handleRawSample(List<int> value) {
    if (value.isEmpty) return;

    final (origValue, calibratedValue) = _parseValueFromBytes(
      value,
      tare,
      calibrationCoef,
    );

    lastOriginalValue = origValue;

    if (_streamDataOn) {
      _dataStreamController.add(BleDataPoint(calibratedValue, DateTime.now()));
    }

    if (calibrationOn) {
      _calibrationMean =
          _calibrationMean *
              _calibrationMeanCount /
              (_calibrationMeanCount + 1) +
          origValue / (_calibrationMeanCount + 1);
      _calibrationMeanCount += 1;
    }
  }

  /// Stops feeding incoming samples to the data stream without touching what
  /// has already been recorded, so a run can be suspended and picked up again.
  void pauseStreaming() {
    _streamDataOn = false;
  }

  /// Resumes after [pauseStreaming].
  void resumeStreaming() {
    _streamDataOn = true;
  }

  /// Given a list of bytes where the 2nd to the 6th bytes represent a floating value,
  /// and a calibration tare and coef, returns the raw decoded value and (decoded-tare)*coef
  (double, double) _parseValueFromBytes(
    List<int> bytes,
    double tare,
    double calibration,
  ) {
    final floatBytes = bytes.sublist(2, 6);
    final byteData = ByteData.sublistView(Uint8List.fromList(floatBytes));
    final floatData = byteData.getFloat32(0, Endian.little);

    return (floatData, (floatData - tare) * calibration);
  }

  // ------------------------------------- CALIBRATION -------------------------------------
  /// When `true`, the mean of uncalibrated data is computed live.
  bool calibrationOn = false;

  /// Holds the last raw (uncalibrated value). Used for calibration.
  double lastOriginalValue = double.nan;

  /// Stores the mean of raw values since `calibrationOn` has been set to `true`.
  double _calibrationMean = 0;

  /// Used to compute the mean.
  int _calibrationMeanCount = 0;

  /// Current tare value to use.
  double tare = 0;

  /// Current calibration coef to use.
  double calibrationCoef = 1;

  /// Completes once `initConfig` has applied the stored config, so callers can
  /// tell the persisted values apart from the defaults.
  Future<void> get configReady => _configReady.future;
  final _configReady = Completer<void>();

  /// Whether the stored config has already been applied.
  bool get isConfigLoaded => _configReady.isCompleted;

  /// Load the sensor calibration config stored on device.
  Future<void> initConfig() async {
    final prefs = await SharedPreferences.getInstance();
    tare = prefs.getDouble('tare') ?? tare;
    calibrationCoef = prefs.getDouble('calibration') ?? calibrationCoef;
    if (!_configReady.isCompleted) {
      _configReady.complete();
    }
  }

  /// Set the calibration coef to a new value.
  Future<void> setCalibrationCoef(double newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('calibration', newValue);
    calibrationCoef = newValue;
  }

  /// Set the tare to a new value.
  Future<void> setTare(double newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tare', newValue);
    tare = newValue;
  }

  /// Delete a preset by its ID.
  Future<void> deleteSensorPreset(String id) =>
      gDatabase.deleteSensorPreset(id);

  /// Save a new calibration preset.
  Future<void> addSensorPreset(NewSensorPreset preset) =>
      gDatabase.addSensorPreset(preset);

  /// Get all saved calibration presets.
  Future<List<SensorPreset>> getSensorPresets() => gDatabase.getSensorPresets();

  /// Start to use a given calibration preset.
  void loadPreset(SensorPreset preset) {
    tare = preset.tare;
    calibrationCoef = preset.coef;
  }

  /// Activate calibration mode.
  /// This will start to compute the mean of raw data sent by the sensor.
  /// The mean can be get by calling `stopCalibration()`.
  void startCalibration() {
    calibrationOn = true;
  }

  /// Stop the calibration session.
  /// This will stop computing the mean of raw sensor data and return it.
  double stopCalibration() {
    calibrationOn = false;
    var res = _calibrationMean;
    _calibrationMean = 0;
    _calibrationMeanCount = 0;
    return res;
  }

  // ------------------------------------- MISC -------------------------------------
  void dispose() {
    disconnect();
    _dataStreamController.close();
    gDatabase.close();
    _connectionStateController.close();
  }
}
