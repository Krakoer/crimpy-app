import 'dart:async';

import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/services/sensor_link/sensor_link.dart';
import 'package:crimpy/services/sensor_link/simulated_sensor_link.dart';

/// A sensor link whose channel only sends what the test tells it to, so a test
/// decides every reading and every disconnection, with no timer left running.
class FakeSensorLink extends SensorLink {
  static const device = SensorDevice(id: 'FAKE-SENSOR', name: 'Fake sensor');

  FakeSensorChannel? channel;

  @override
  bool get isAdapterOn => true;

  @override
  Stream<bool> get adapterOnChanges => const Stream.empty();

  @override
  Future<void> turnAdapterOn() async {}

  @override
  Future<List<SensorDevice>> scan() async => [device];

  @override
  Future<SensorChannel?> open(SensorDevice device) async =>
      channel = FakeSensorChannel();
}

class FakeSensorChannel extends SensorChannel {
  final _notifications = StreamController<List<int>>.broadcast(sync: true);
  final _connection = StreamController<bool>.broadcast(sync: true);

  @override
  Stream<bool> get connectionChanges => _connection.stream;

  @override
  Stream<List<int>> get notifications => _notifications.stream;

  /// Sends one raw reading, as the firmware frames it.
  void send(double raw) => _notifications.add(encodeSensorFrame(raw, 0));

  /// The sensor going out of reach.
  void drop() => _connection.add(false);

  @override
  Future<void> close() async {}
}
