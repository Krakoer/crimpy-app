import 'dart:async';
import 'dart:math';

import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/services/sensor_link/sensor_link.dart';
import 'package:flutter/foundation.dart';

/// Whether this build talks to [SimulatedSensorLink] instead of a real sensor.
/// Set it to run on an emulator, which has no sensor to reach:
///
///     flutter run --flavor beta --dart-define=CRIMPY_SIMULATED_SENSOR=true
///
/// A release build ignores it, so a build that reaches testers or the stores
/// can never record made up force.
const bool useSimulatedSensor =
    !kReleaseMode && bool.fromEnvironment('CRIMPY_SIMULATED_SENSOR');

/// A sensor that exists only in the app. It is always found by a scan and,
/// once connected, emits the firmware's notification frames at its rate, so
/// everything past the link (decoding, tare, calibration, the run screens) runs
/// as it would against the hardware.
class SimulatedSensorLink extends SensorLink {
  SimulatedSensorLink({
    this.scanDuration = const Duration(seconds: 1),
    this.samplePeriod = const Duration(milliseconds: 100),
  });

  static const device = SensorDevice(
    id: 'SIMULATED-SENSOR',
    name: 'Crimpy simulator',
  );

  /// Long enough for the connection dialog to show that it is scanning.
  final Duration scanDuration;

  /// The firmware notifies about ten times a second.
  final Duration samplePeriod;

  @override
  bool get isAdapterOn => true;

  @override
  Stream<bool> get adapterOnChanges => const Stream.empty();

  @override
  Future<void> turnAdapterOn() async {}

  @override
  Future<List<SensorDevice>> scan() async {
    await Future.delayed(scanDuration);
    return [device];
  }

  @override
  Future<SensorChannel?> open(SensorDevice device) async =>
      SimulatedSensorChannel(samplePeriod: samplePeriod);
}

/// Replays [SimulatedHangProfile] as notification frames, every
/// [samplePeriod] from the moment it opens.
class SimulatedSensorChannel extends SensorChannel {
  SimulatedSensorChannel({
    this.samplePeriod = const Duration(milliseconds: 100),
    this.profile = const SimulatedHangProfile(),
  }) {
    _timer = Timer.periodic(samplePeriod, _emitSample);
  }

  final Duration samplePeriod;
  final SimulatedHangProfile profile;

  late final Timer _timer;
  final _notifications = StreamController<List<int>>.broadcast();
  final _connection = StreamController<bool>.broadcast();
  bool _open = true;

  @override
  Stream<bool> get connectionChanges => Stream.multi((listener) {
    listener.add(_open);
    if (!_open) {
      listener.close();
      return;
    }
    final subscription = _connection.stream.listen(
      listener.add,
      onDone: listener.close,
    );
    listener.onCancel = subscription.cancel;
  });

  @override
  Stream<List<int>> get notifications => _notifications.stream;

  void _emitSample(Timer timer) {
    final elapsed = samplePeriod * timer.tick;
    _notifications.add(
      encodeSensorFrame(profile.forceAt(elapsed), elapsed.inMilliseconds),
    );
  }

  @override
  Future<void> close() async {
    if (!_open) return;
    _open = false;
    _timer.cancel();
    _connection.add(false);
    // A broadcast controller's close only completes once a listener has taken
    // the done event, and the repository cancels its subscriptions first.
    unawaited(_connection.close());
    unawaited(_notifications.close());
  }
}

/// A climber repeating hangs: [rest] off, then [hang] on at around [load]
/// kilograms, with a small wobble so the readout and the curves move the way a
/// hand on a hold does rather than sitting on one value. It opens on the rest
/// because connecting brings up the tare dialog, which should read an unloaded
/// sensor.
class SimulatedHangProfile {
  const SimulatedHangProfile({
    this.hang = const Duration(seconds: 7),
    this.rest = const Duration(seconds: 3),
    this.load = 20,
    this.restLoad = 0.2,
    this.ramp = const Duration(milliseconds: 400),
  });

  final Duration hang;
  final Duration rest;
  final double load;
  final double restLoad;
  final Duration ramp;

  double forceAt(Duration elapsed) {
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final cycle = (hang + rest).inMicroseconds / Duration.microsecondsPerSecond;
    final hangSeconds = hang.inMicroseconds / Duration.microsecondsPerSecond;
    final restSeconds = rest.inMicroseconds / Duration.microsecondsPerSecond;
    final rampSeconds = ramp.inMicroseconds / Duration.microsecondsPerSecond;
    final inCycle = seconds % cycle - restSeconds;

    if (inCycle < 0) return restLoad;

    final wobble =
        0.6 * sin(2 * pi * 1.3 * seconds) + 0.3 * sin(2 * pi * 3.7 * seconds);
    final plateau = load + wobble;
    final rampUp = (inCycle / rampSeconds).clamp(0.0, 1.0);
    final rampDown = ((hangSeconds - inCycle) / rampSeconds).clamp(0.0, 1.0);
    final envelope = min(rampUp, rampDown);
    return restLoad + (plateau - restLoad) * envelope;
  }
}

/// One notification as the firmware frames it, see
/// [SensorChannel.notifications].
List<int> encodeSensorFrame(double reading, int millisecondsSinceBoot) {
  final frame = ByteData(10)
    ..setUint8(0, 1)
    ..setUint8(1, 8)
    ..setFloat32(2, reading, Endian.little)
    ..setUint32(6, millisecondsSinceBoot, Endian.little);
  return frame.buffer.asUint8List();
}
