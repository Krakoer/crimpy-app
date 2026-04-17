import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/ble_data_model.dart';
import '../database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BleRepository {
  // ignore: non_constant_identifier_names
  static Guid SERVICE_UUID = Guid.fromString(
    "7e4e1701-1ea6-40c9-9dcc-13d34ffead57",
  );
  // ignore: non_constant_identifier_names
  static Guid CHARACTERISTIC_UUID = Guid.fromString(
    "7e4e1702-1ea6-40c9-9dcc-13d34ffead57",
  );

  // ------------------------------------- BLE DEVICE -------------------------------------
  /// Adapter state stream that always starts with the current state
  Stream<BluetoothAdapterState> get adapterStateStream async* {
    // emit the current state immediately
    yield FlutterBluePlus.adapterStateNow;

    // then forward subsequent changes
    yield* FlutterBluePlus.adapterState;
  }

  BluetoothAdapterState get currentAdapterState =>
      FlutterBluePlus.adapterStateNow;

  final _connectionStateController =
      StreamController<BleConnectionState>.broadcast();

  Stream<BleConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  BleConnectionState get currentConnectionState =>
      _device == null
          ? BleConnectionState.disconnected
          : BleConnectionState.connected;

  /// Stores the connected device.
  BluetoothDevice? _device;

  /// Stores the connected BLE characteristic.
  BluetoothCharacteristic? _characteristic;

  /// returns whether a device is connected and a characteristic is listened to.
  bool get isConnected => _device != null && _characteristic != null;

  /// Get the current connected device.
  BluetoothDevice? get connectedDevice => _device;

  Future<List<BluetoothDevice>> scanForDevices() async {
    List<BluetoothDevice> devices = [];

    // Start scanning
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    var subscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.platformName.isNotEmpty) {
          if (!devices.any((d) => d.remoteId == r.device.remoteId)) {
            devices.add(r.device);
          }
        }
      }
    });

    // Wait for the scan to complete
    await Future.delayed(Duration(seconds: 4));
    await FlutterBluePlus.stopScan();
    await subscription.cancel();

    return devices;
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _connectionStateController.add(BleConnectionState.connecting);
      await device.connect();
      _device = device;

      // Listen to connection state updates
      device.connectionState.listen((event) {
        switch (event) {
          case BluetoothConnectionState.connected:
            _connectionStateController.add(BleConnectionState.connected);
            break;
          case BluetoothConnectionState.disconnected:
            _connectionStateController.add(BleConnectionState.disconnected);
            _device = null;
            break;
          default:
            break;
        }
      });

      // Discover services
      List<BluetoothService> services = await device.discoverServices();

      // Find our service
      for (BluetoothService service in services) {
        if (service.uuid == SERVICE_UUID) {
          // Find our characteristic
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid == CHARACTERISTIC_UUID) {
              _characteristic = characteristic;

              // Set up notification
              await characteristic.setNotifyValue(true);
              characteristic.lastValueStream.listen((value) {
                if (value.isNotEmpty) {
                  // Convert the received bytes to a numerical value
                  var (origValue, calibratedValue) = _parseValueFromBytes(
                    value,
                    tare,
                    calibrationCoef,
                  );

                  // Save last original value for calibration
                  lastOriginalValue = origValue;

                  // Create data point and add to stream
                  final dataPoint = BleDataPoint(
                    calibratedValue,
                    DateTime.now(),
                  );

                  // Store in current session data
                  if (_streamDataOn) {
                    // Add to stream
                    _dataStreamController.add(dataPoint);
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
              });
              return true;
            }
          }
        }
      }

      // If we reach here, we didn't find our service/characteristic
      await device.disconnect();
      _device = null;
      return false;
    } catch (e) {
      _device = null;
      _connectionStateController.add(BleConnectionState.failed);
      return false;
    }
  }

  Future<bool> connectToKnownDevice(String deviceId) async {
    try {
      _device = BluetoothDevice.fromId(deviceId);
      return await connectToDevice(_device!);
    } catch (e) {
      _device = null;
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_device != null) {
      if (_characteristic != null && _device!.isConnected) {
        _characteristic = null;
      }
      await _device!.disconnect();
      _device = null;
    }
    _connectionStateController.add(BleConnectionState.disconnected);
  }

  // ------------------------------------- SENSOR VALUES -------------------------------------
  /// Stream controller to broadcast received calibrated values from sensor.
  final _dataStreamController = StreamController<BleDataPoint>.broadcast();

  /// Public calibrated BLE data stream.
  Stream<BleDataPoint> get dataStream => _dataStreamController.stream;

  /// Wether the received data are streamed.
  bool _streamDataOn = true;

  void stopSession() {
    _streamDataOn = false;
  }

  /// Reset the current session data
  void resetSession() {
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

  /// Load the sensor calibration config stored on device.
  Future<void> initConfig() async {
    final prefs = await SharedPreferences.getInstance();
    tare = prefs.getDouble('tare') ?? tare;
    calibrationCoef = prefs.getDouble('calibration') ?? calibrationCoef;
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

  /// Update a list of sesnor calibration configs.
  Future<void> updateSensorConfigs(List<SensorConfigs> configs) async {
    await gDatabase.updateSensorConfigs(configs);
  }

  /// Delete a sensor config by its ID.
  Future<void> deleteSensorConfig(String id) async {
    await gDatabase.deleteSensorConfig(id);
  }

  /// Add a sensor calibration config to DB.
  Future<void> addSensorConfig(SensorConfigsCompanion config) async {
    await gDatabase.addSensorConfig(config);
  }

  /// Get all sensor calibration configs.
  Future<List<SensorConfig>> getSensorConfigs() async {
    return await gDatabase.getSensorConfigs();
  }

  /// Start to use a given calibration config.
  void loadConfig(SensorConfig config) {
    tare = config.tare;
    calibrationCoef = config.coef;
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
