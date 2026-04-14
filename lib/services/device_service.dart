import 'package:crimpy/database/database.dart';

class DeviceService {
  final AppDatabase _database;

  DeviceService(this._database);

  Future<String> getOrCreateDeviceId() async {
    final existing = await _database.getSyncMetaValue('device_id');
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    throw Exception(
      'Device ID not initialized. This should not happen after migration.',
    );
  }

  Future<String> getDeviceId() async {
    return await getOrCreateDeviceId();
  }
}
