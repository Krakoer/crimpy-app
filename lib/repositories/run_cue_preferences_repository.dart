import 'package:shared_preferences/shared_preferences.dart';

/// How the run screen gives its cues, kept on the device.
abstract class RunCuePreferencesRepository {
  /// Whether the cues vibrate. On until the athlete turns it off.
  Future<bool> vibrates();

  Future<void> setVibrates(bool vibrates);
}

class SharedPreferencesRunCuePreferences extends RunCuePreferencesRepository {
  static const _vibratesKey = 'run_cues_vibrate';

  final Future<SharedPreferences> Function() _preferences;

  SharedPreferencesRunCuePreferences({
    Future<SharedPreferences> Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;

  @override
  Future<bool> vibrates() async =>
      (await _preferences()).getBool(_vibratesKey) ?? true;

  @override
  Future<void> setVibrates(bool vibrates) async =>
      (await _preferences()).setBool(_vibratesKey, vibrates);
}
