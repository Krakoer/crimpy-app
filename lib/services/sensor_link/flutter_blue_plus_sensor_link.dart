import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/services/sensor_link/sensor_link.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// The link to a real sensor, over the phone's Bluetooth adapter.
class FlutterBluePlusSensorLink extends SensorLink {
  static final serviceUuid = Guid.fromString(
    "7e4e1701-1ea6-40c9-9dcc-13d34ffead57",
  );
  static final characteristicUuid = Guid.fromString(
    "7e4e1702-1ea6-40c9-9dcc-13d34ffead57",
  );

  static const _scanDuration = Duration(seconds: 4);

  @override
  bool get isAdapterOn =>
      FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on;

  @override
  Stream<bool> get adapterOnChanges => FlutterBluePlus.adapterState.map(
    (state) => state == BluetoothAdapterState.on,
  );

  @override
  Future<void> turnAdapterOn() => FlutterBluePlus.turnOn();

  @override
  Future<List<SensorDevice>> scan() async {
    final devices = <SensorDevice>[];

    await FlutterBluePlus.startScan(timeout: _scanDuration);

    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final device = result.device;
        if (device.platformName.isEmpty) continue;
        final id = device.remoteId.str;
        if (devices.any((known) => known.id == id)) continue;
        devices.add(SensorDevice(id: id, name: device.platformName));
      }
    });

    await Future.delayed(_scanDuration);
    await FlutterBluePlus.stopScan();
    await subscription.cancel();

    return devices;
  }

  @override
  Future<SensorChannel?> open(SensorDevice sensor) async {
    final device = BluetoothDevice.fromId(sensor.id);
    await device.connect();

    final services = await device.discoverServices();
    for (final service in services) {
      if (service.uuid != serviceUuid) continue;
      for (final characteristic in service.characteristics) {
        if (characteristic.uuid != characteristicUuid) continue;
        await characteristic.setNotifyValue(true);
        return _FlutterBluePlusSensorChannel(device, characteristic);
      }
    }

    await device.disconnect();
    return null;
  }
}

class _FlutterBluePlusSensorChannel extends SensorChannel {
  _FlutterBluePlusSensorChannel(this._device, this._characteristic);

  final BluetoothDevice _device;
  final BluetoothCharacteristic _characteristic;

  @override
  Stream<bool> get connectionChanges => _device.connectionState
      .where(
        (state) =>
            state == BluetoothConnectionState.connected ||
            state == BluetoothConnectionState.disconnected,
      )
      .map((state) => state == BluetoothConnectionState.connected);

  @override
  Stream<List<int>> get notifications => _characteristic.lastValueStream;

  @override
  Future<void> close() => _device.disconnect();
}
