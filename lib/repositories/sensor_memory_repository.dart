import 'package:crimpy/models/ble_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers, on the device, the athlete's sensor or that they have none.
abstract class SensorMemoryRepository {
  Future<SensorOwnership> read();

  /// Remembers [device] as the athlete's sensor, which also means they have
  /// one.
  Future<void> remember(SensorDevice device);

  Future<void> rememberNoSensor();

  /// Back to asking when a run starts.
  Future<void> forget();
}

class SharedPreferencesSensorMemory extends SensorMemoryRepository {
  static const _idKey = 'remembered_sensor_id';
  static const _nameKey = 'remembered_sensor_name';
  static const _noSensorKey = 'has_no_sensor';

  final Future<SharedPreferences> Function() _preferences;

  SharedPreferencesSensorMemory({
    Future<SharedPreferences> Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;

  @override
  Future<SensorOwnership> read() async {
    final prefs = await _preferences();
    final id = prefs.getString(_idKey);
    if (id != null) {
      return RememberedSensor(
        SensorDevice(id: id, name: prefs.getString(_nameKey) ?? id),
      );
    }
    if (prefs.getBool(_noSensorKey) ?? false) return const NoSensorOwned();
    return const SensorOwnershipUnknown();
  }

  @override
  Future<void> remember(SensorDevice device) async {
    final prefs = await _preferences();
    await prefs.setString(_idKey, device.id);
    await prefs.setString(_nameKey, device.name);
    await prefs.remove(_noSensorKey);
  }

  @override
  Future<void> rememberNoSensor() async {
    final prefs = await _preferences();
    await prefs.remove(_idKey);
    await prefs.remove(_nameKey);
    await prefs.setBool(_noSensorKey, true);
  }

  @override
  Future<void> forget() async {
    final prefs = await _preferences();
    await prefs.remove(_idKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_noSensorKey);
  }
}
