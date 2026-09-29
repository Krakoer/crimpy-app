import 'package:crimpy/models/ble_data_model.dart';

/// How long a connection attempt waits for a device that does not answer,
/// unless the caller asks for less.
const defaultSensorConnectTimeout = Duration(seconds: 35);

/// The transport between the app and a force sensor: the Bluetooth adapter,
/// scanning, and one open connection at a time. The repository above it owns
/// decoding, calibration and connection bookkeeping, so a link only moves
/// bytes and reports whether the connection is up.
abstract class SensorLink {
  bool get isAdapterOn;

  /// Changes of [isAdapterOn] after the moment of listening.
  Stream<bool> get adapterOnChanges;

  Future<void> turnAdapterOn();

  Future<List<SensorDevice>> scan();

  /// Connects to [device] and subscribes to its force characteristic. Null when
  /// the device does not carry that characteristic. Throws when the connection
  /// itself fails, including when the device does not answer within
  /// [timeout], as a remembered sensor that is off or out of range does not.
  Future<SensorChannel?> open(
    SensorDevice device, {
    Duration timeout = defaultSensorConnectTimeout,
  });
}

/// One open connection to a sensor.
abstract class SensorChannel {
  /// True while connected, false once the connection drops. Emits the current
  /// state first.
  Stream<bool> get connectionChanges;

  /// Raw notifications from the force characteristic, in the firmware's frame:
  /// two header bytes, a little endian float32 reading, then a little endian
  /// uint32 of milliseconds since the sensor booted.
  Stream<List<int>> get notifications;

  Future<void> close();
}
